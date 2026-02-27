defmodule SVD.Exporters.Formats.CSVExporter do
  @moduledoc false

  alias SVD.Exporters.{BaseExporter, Helpers, StandardisedVesselDatasetContent}
  alias SVD.Models
  alias SVD.Utils.{CaseConverter, ValueFormatter}
  alias SVD.Validators.StandardisedVesselDatasetValidator

  defstruct validator: StandardisedVesselDatasetValidator

  @type t :: %__MODULE__{validator: module() | nil}

  @spec new(module() | nil) :: t()
  def new(validator_module), do: %__MODULE__{validator: validator_module}

  @spec export_async(t(), term(), term()) ::
          {:ok, StandardisedVesselDatasetContent.t()} | {:error, term()}
  def export_async(%__MODULE__{validator: validator_module}, svd, _ctx \\ nil) do
    BaseExporter.validate_and_export(validator_module, svd, fn dataset ->
      flat_data = flatten(dataset)
      headers = flat_data |> Map.keys() |> Enum.sort()
      values = Enum.map(headers, fn header -> flat_data[header] end)

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

  defp flatten(dataset) do
    Models.sections()
    |> Enum.reduce(%{}, fn {field, json_prefix, _xml_key, module}, acc ->
      case Map.get(dataset, field) do
        nil ->
          acc

        section ->
          Enum.reduce(module.fields(), acc, fn section_field, section_acc ->
            key = "#{json_prefix}.#{CaseConverter.snake(section_field)}"
            value = section |> Map.get(section_field) |> ValueFormatter.to_csv()
            Map.put(section_acc, key, value)
          end)
      end
    end)
  end

  defp csv_escape(value) do
    needs_quotes = String.contains?(value, [",", "\n", "\""])

    if needs_quotes do
      escaped = String.replace(value, "\"", "\"\"")
      "\"#{escaped}\""
    else
      value
    end
  end
end
