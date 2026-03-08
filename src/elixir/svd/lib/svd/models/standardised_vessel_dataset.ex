defmodule SVD.Models.StandardisedVesselDataset do
  @moduledoc false

  alias SVD.Utils.CaseConverter

  alias SVD.Models.{
    ArrivalTimes,
    CargoInformation,
    CylinderLubeOilInformation,
    DeviationFromPlanned,
    ElectricityConsumption,
    Emissions,
    FreshWater,
    FuelAndBunkerInformation,
    GeneralInformation,
    PortInformation,
    SpeedAndDistance,
    WeatherInformation
  }

  @fields [
    :general,
    :port_and_route,
    :arrival_times,
    :deviation_from_planned,
    :speed_and_distance,
    :weather,
    :fresh_water,
    :electricity_consumption,
    :cargo,
    :fuel_and_bunker,
    :emissions,
    :cylinder_lube_oil
  ]

  @derive {Jason.Encoder, only: @fields}
  defstruct @fields

  @type t :: %__MODULE__{}

  @spec fields() :: [atom()]
  def fields, do: @fields

  @spec new(map()) :: t()
  def new(attrs) when is_map(attrs) do
    %__MODULE__{
      general: struct_or_nil(GeneralInformation, attrs[:general] || attrs["general"]),
      port_and_route:
        struct_or_nil(
          PortInformation,
          attrs[:port_and_route] || attrs["portAndRoute"] || attrs["port_and_route"]
        ),
      arrival_times:
        struct_or_nil(
          ArrivalTimes,
          attrs[:arrival_times] || attrs["arrivalTimes"] || attrs["arrival_times"]
        ),
      deviation_from_planned:
        struct_or_nil(
          DeviationFromPlanned,
          attrs[:deviation_from_planned] || attrs["deviationFromPlanned"] ||
            attrs["deviation_from_planned"]
        ),
      speed_and_distance:
        struct_or_nil(
          SpeedAndDistance,
          attrs[:speed_and_distance] || attrs["speedAndDistance"] || attrs["speed_and_distance"]
        ),
      weather: struct_or_nil(WeatherInformation, attrs[:weather] || attrs["weather"]),
      fresh_water:
        struct_or_nil(
          FreshWater,
          attrs[:fresh_water] || attrs["freshWater"] || attrs["fresh_water"]
        ),
      electricity_consumption:
        struct_or_nil(
          ElectricityConsumption,
          attrs[:electricity_consumption] || attrs["electricityConsumption"] ||
            attrs["electricity_consumption"]
        ),
      cargo: struct_or_nil(CargoInformation, attrs[:cargo] || attrs["cargo"]),
      fuel_and_bunker:
        struct_or_nil(
          FuelAndBunkerInformation,
          attrs[:fuel_and_bunker] || attrs["fuelAndBunker"] || attrs["fuel_and_bunker"]
        ),
      emissions: struct_or_nil(Emissions, attrs[:emissions] || attrs["emissions"]),
      cylinder_lube_oil:
        struct_or_nil(
          CylinderLubeOilInformation,
          attrs[:cylinder_lube_oil] || attrs["cylinderLubeOil"] || attrs["cylinder_lube_oil"]
        )
    }
  end

  defp struct_or_nil(_module, nil), do: nil
  defp struct_or_nil(module, %module{} = value), do: value

  defp struct_or_nil(module, value) when is_map(value),
    do: struct(module, normalize_struct_attrs(module, value))

  defp struct_or_nil(_module, _value), do: nil

  defp normalize_struct_attrs(module, value) do
    Enum.reduce(module.fields(), %{}, fn field, acc ->
      snake_key = Atom.to_string(field)
      camel_key = CaseConverter.camel(field)
      pascal_key = CaseConverter.pascal(field)
      acronym_camel_key = decapitalize_first(pascal_key)

      normalized_value =
        first_present_map_value(value, [
          field,
          snake_key,
          camel_key,
          acronym_camel_key,
          pascal_key
        ])

      if is_nil(normalized_value) do
        acc
      else
        Map.put(acc, field, normalized_value)
      end
    end)
  end

  defp decapitalize_first(<<first::utf8, rest::binary>>) do
    <<String.downcase(<<first::utf8>>)::binary, rest::binary>>
  end

  defp decapitalize_first(<<>>), do: ""

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
