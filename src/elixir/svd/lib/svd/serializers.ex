defmodule SVD.Serializers do
  @moduledoc false

  alias SVD.DotNetWire
  alias SVD.Models.StandardisedVesselDataset

  @spec to_json_map(StandardisedVesselDataset.t()) :: map()
  def to_json_map(%StandardisedVesselDataset{} = dataset) do
    DotNetWire.sections()
    |> Enum.reduce(%{}, fn section, acc ->
      section_data = Map.get(dataset, section.field)

      json_section =
        if is_nil(section_data) do
          nil
        else
          section.fields
          |> Enum.reduce(%{}, fn {field, type}, section_acc ->
            value = Map.get(section_data, field)

            Map.put(
              section_acc,
              DotNetWire.json_field_name(field),
              DotNetWire.format_value(value, type, :json)
            )
          end)
        end

      Map.put(acc, section.json, json_section)
    end)
  end

  @spec from_json_map(map()) :: {:ok, StandardisedVesselDataset.t()} | {:error, term()}
  def from_json_map(payload) when is_map(payload) do
    attrs =
      DotNetWire.sections()
      |> Enum.reduce(%{}, fn section, acc ->
        section_payload =
          Map.get(payload, section.json) ||
            Map.get(payload, section.xml) ||
            Map.get(payload, section.field)

        section_value = parse_json_section(section_payload, section)
        Map.put(acc, section.field, section_value)
      end)

    {:ok, StandardisedVesselDataset.new(attrs)}
  end

  def from_json_map(_), do: {:error, :invalid_json_payload}

  defp parse_json_section(nil, _section), do: nil

  defp parse_json_section(section_payload, %{module: module, fields: fields})
       when is_map(section_payload) do
    values =
      fields
      |> Enum.reduce(%{}, fn {field, type}, acc ->
        json_key = DotNetWire.json_field_name(field)
        xml_key = DotNetWire.xml_field_name(field)

        raw_value =
          first_present_map_value(section_payload, [
            json_key,
            xml_key,
            field,
            Atom.to_string(field)
          ])

        Map.put(acc, field, DotNetWire.parse_value(raw_value, type, :json))
      end)

    struct(module, values)
  end

  defp parse_json_section(_section_payload, _section), do: nil

  defp first_present_map_value(map, keys) do
    keys
    |> Enum.find_value(fn key ->
      if Map.has_key?(map, key) do
        {:present, Map.get(map, key)}
      else
        nil
      end
    end)
    |> case do
      {:present, value} -> value
      nil -> nil
    end
  end
end
