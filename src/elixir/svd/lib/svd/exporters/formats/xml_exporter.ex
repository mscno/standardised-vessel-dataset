defmodule SVD.Exporters.Formats.XMLExporter do
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
      xml_content = to_xml(dataset)

      {:ok,
       StandardisedVesselDatasetContent.new(
         xml_content,
         Helpers.file_name(dataset, "xml"),
         "application/xml"
       )}
    end)
  end

  @spec decode(binary()) :: {:ok, StandardisedVesselDataset.t()} | {:error, term()}
  def decode(payload) when is_binary(payload) do
    with {:ok, root} <- parse_xml(payload) do
      dataset =
        DotNetWire.sections()
        |> Enum.reduce(%{}, fn section, acc ->
          section_element = find_child_element(root, String.to_atom(section.xml))
          section_value = parse_section(section_element, section)
          Map.put(acc, section.field, section_value)
        end)
        |> StandardisedVesselDataset.new()

      {:ok, dataset}
    end
  end

  def decode(_), do: {:error, :invalid_xml_payload}

  defp to_xml(dataset) do
    sections =
      DotNetWire.sections()
      |> Enum.map(fn section ->
        case Map.get(dataset, section.field) do
          nil -> nil
          section_data -> render_section(section, section_data)
        end
      end)
      |> Enum.reject(&is_nil/1)
      |> Enum.join("\n")

    body = if sections == "", do: "", else: "\n" <> sections <> "\n"

    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<StandardisedVesselDataset>#{body}</StandardisedVesselDataset>"
  end

  defp render_section(section, section_data) do
    fields =
      section.fields
      |> Enum.map(fn {field, type} ->
        value = section_data |> Map.get(field) |> DotNetWire.format_value(type, :xml)

        if is_nil(value) do
          nil
        else
          tag = DotNetWire.xml_field_name(field)
          "    <#{tag}>#{xml_escape(value)}</#{tag}>"
        end
      end)
      |> Enum.reject(&is_nil/1)
      |> Enum.join("\n")

    if fields == "" do
      "  <#{section.xml}></#{section.xml}>"
    else
      "  <#{section.xml}>\n#{fields}\n  </#{section.xml}>"
    end
  end

  defp parse_xml(payload) do
    case :xmerl_scan.string(String.to_charlist(payload)) do
      {{:xmlElement, :StandardisedVesselDataset, _, _, _, _, _, _, _, _, _, _} = root, _} ->
        {:ok, root}

      {{:xmlElement, _, _, _, _, _, _, _, _, _, _, _}, _} ->
        {:error, :invalid_xml_root}

      _ ->
        {:error, :invalid_xml_payload}
    end
  rescue
    _ -> {:error, :invalid_xml_payload}
  end

  defp parse_section(nil, _section), do: nil

  defp parse_section(section_element, section) do
    values =
      section.fields
      |> Enum.reduce(%{}, fn {field, type}, acc ->
        tag_atom = field |> DotNetWire.xml_field_name() |> String.to_atom()

        raw_value =
          section_element
          |> find_child_element(tag_atom)
          |> extract_element_text()

        Map.put(acc, field, DotNetWire.parse_value(raw_value, type, :xml))
      end)

    struct(section.module, values)
  end

  defp find_child_element(nil, _name), do: nil

  defp find_child_element({:xmlElement, _, _, _, _, _, _, _, children, _, _, _}, name) do
    Enum.find(children, fn
      {:xmlElement, ^name, _, _, _, _, _, _, _, _, _, _} -> true
      _ -> false
    end)
  end

  defp extract_element_text(nil), do: nil

  defp extract_element_text({:xmlElement, _, _, _, _, _, _, _, children, _, _, _}) do
    children
    |> Enum.reduce([], fn
      {:xmlText, _, _, _, value, _}, acc -> [value | acc]
      _, acc -> acc
    end)
    |> Enum.reverse()
    |> IO.iodata_to_binary()
    |> String.trim()
    |> case do
      "" -> nil
      value -> value
    end
  end

  defp xml_escape(value) do
    value
    |> String.replace("&", "&amp;")
    |> String.replace("<", "&lt;")
    |> String.replace(">", "&gt;")
    |> String.replace("\"", "&quot;")
    |> String.replace("'", "&apos;")
  end
end
