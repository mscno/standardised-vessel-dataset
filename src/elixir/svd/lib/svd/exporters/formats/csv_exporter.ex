defmodule SVD.Exporters.Formats.CSVExporter do
  @moduledoc false

  alias SVD.DotNetWire
  alias SVD.Exporters.{BaseExporter, Helpers, StandardisedVesselDatasetContent}
  alias SVD.Models.StandardisedVesselDataset
  alias SVD.Validators.StandardisedVesselDatasetValidator

  defstruct validator: StandardisedVesselDatasetValidator

  @type t :: %__MODULE__{validator: module() | nil}

  @spec new(module() | nil) :: t()
  def new(validator_module), do: %__MODULE__{validator: validator_module}

  @spec export_async(t(), term(), term()) ::
          {:ok, StandardisedVesselDatasetContent.t()} | {:error, term()}
  def export_async(%__MODULE__{validator: validator_module}, svd, _ctx \\ nil) do
    BaseExporter.validate_and_export(validator_module, svd, fn dataset ->
      {headers, values} = rows_for(dataset)

      csv =
        [
          Enum.map_join(headers, ",", &csv_escape/1),
          Enum.map_join(values, ",", &csv_escape/1)
        ]
        |> Enum.join("\n")
        |> Kernel.<>("\n")

      {:ok,
       StandardisedVesselDatasetContent.new(csv, Helpers.file_name(dataset, "csv"), "text/csv")}
    end)
  end

  @spec decode(binary()) :: {:ok, StandardisedVesselDataset.t()} | {:error, term()}
  def decode(payload) when is_binary(payload) do
    with {:ok, rows} <- parse_csv(payload),
         [headers, values | _] <- rows do
      header_index =
        headers
        |> Enum.with_index()
        |> Map.new()

      dataset =
        DotNetWire.sections()
        |> Enum.reduce(%{}, fn section, acc ->
          section_value = parse_section(section, values, header_index)
          Map.put(acc, section.field, section_value)
        end)
        |> StandardisedVesselDataset.new()

      {:ok, dataset}
    else
      _ -> {:error, :invalid_csv_payload}
    end
  end

  def decode(_), do: {:error, :invalid_csv_payload}

  defp rows_for(dataset) do
    headers =
      DotNetWire.sections()
      |> Enum.flat_map(fn section ->
        Enum.map(section.fields, fn {field, _type} ->
          DotNetWire.csv_header(section.csv, field)
        end)
      end)

    values =
      DotNetWire.sections()
      |> Enum.flat_map(fn section ->
        section_data = Map.get(dataset, section.field)

        Enum.map(section.fields, fn {field, type} ->
          value = if section_data, do: Map.get(section_data, field), else: nil
          DotNetWire.format_value(value, type, :csv)
        end)
      end)

    {headers, values}
  end

  defp parse_section(section, row_values, header_index) do
    values =
      section.fields
      |> Enum.reduce(%{}, fn {field, type}, acc ->
        header = DotNetWire.csv_header(section.csv, field)
        raw_value = csv_value(row_values, header_index, header) |> normalize_raw_value()
        parsed = DotNetWire.parse_value(raw_value, type, :csv)
        Map.put(acc, field, parsed)
      end)

    if Enum.any?(values, fn {_field, value} -> not is_nil(value) end) do
      struct(section.module, values)
    else
      nil
    end
  end

  defp csv_value(row_values, header_index, header) do
    case Map.fetch(header_index, header) do
      {:ok, index} -> Enum.at(row_values, index)
      :error -> nil
    end
  end

  defp normalize_raw_value(nil), do: nil
  defp normalize_raw_value(value), do: value

  defp csv_escape(value) do
    needs_quotes = String.contains?(value, [",", "\n", "\""])

    if needs_quotes do
      escaped = String.replace(value, "\"", "\"\"")
      "\"#{escaped}\""
    else
      value
    end
  end

  defp parse_csv(payload) do
    case parse_charlist(String.to_charlist(payload), [], [], [], false) do
      {:ok, rows} ->
        sanitized_rows =
          rows
          |> Enum.reject(&(&1 == [""]))

        if length(sanitized_rows) >= 2 do
          {:ok, sanitized_rows}
        else
          {:error, :invalid_csv_payload}
        end

      error ->
        error
    end
  end

  defp parse_charlist([], _field_chars, _row_fields, _rows, true),
    do: {:error, :invalid_csv_payload}

  defp parse_charlist([], field_chars, row_fields, rows, false) do
    final_row = finalize_row(field_chars, row_fields)
    {:ok, Enum.reverse([final_row | rows])}
  end

  defp parse_charlist([?", ?" | rest], field_chars, row_fields, rows, true) do
    parse_charlist(rest, [?" | field_chars], row_fields, rows, true)
  end

  defp parse_charlist([?" | rest], field_chars, row_fields, rows, true) do
    parse_charlist(rest, field_chars, row_fields, rows, false)
  end

  defp parse_charlist([?" | rest], [], row_fields, rows, false) do
    parse_charlist(rest, [], row_fields, rows, true)
  end

  defp parse_charlist([?, | rest], field_chars, row_fields, rows, false) do
    parse_charlist(rest, [], [finalize_field(field_chars) | row_fields], rows, false)
  end

  defp parse_charlist([?\r, ?\n | rest], field_chars, row_fields, rows, false) do
    next_row = finalize_row(field_chars, row_fields)
    parse_charlist(rest, [], [], [next_row | rows], false)
  end

  defp parse_charlist([?\n | rest], field_chars, row_fields, rows, false) do
    next_row = finalize_row(field_chars, row_fields)
    parse_charlist(rest, [], [], [next_row | rows], false)
  end

  defp parse_charlist([?\r | rest], field_chars, row_fields, rows, false) do
    next_row = finalize_row(field_chars, row_fields)
    parse_charlist(rest, [], [], [next_row | rows], false)
  end

  defp parse_charlist([char | rest], field_chars, row_fields, rows, quoted) do
    parse_charlist(rest, [char | field_chars], row_fields, rows, quoted)
  end

  defp finalize_row(field_chars, row_fields) do
    row_fields
    |> List.insert_at(0, finalize_field(field_chars))
    |> Enum.reverse()
  end

  defp finalize_field(field_chars) do
    field_chars
    |> Enum.reverse()
    |> List.to_string()
  end
end
