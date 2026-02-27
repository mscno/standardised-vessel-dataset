defmodule SVD.Models do
  @moduledoc false

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
    StandardisedVesselDataset,
    WeatherInformation
  }

  @sections [
    {:general, "general", "General", GeneralInformation},
    {:port_and_route, "portAndRoute", "PortAndRoute", PortInformation},
    {:arrival_times, "arrivalTimes", "ArrivalTimes", ArrivalTimes},
    {:deviation_from_planned, "deviationFromPlanned", "DeviationFromPlanned",
     DeviationFromPlanned},
    {:speed_and_distance, "speedAndDistance", "SpeedAndDistance", SpeedAndDistance},
    {:weather, "weather", "Weather", WeatherInformation},
    {:fresh_water, "freshWater", "FreshWater", FreshWater},
    {:electricity_consumption, "electricityConsumption", "ElectricityConsumption",
     ElectricityConsumption},
    {:cargo, "cargo", "Cargo", CargoInformation},
    {:fuel_and_bunker, "fuelAndBunker", "FuelAndBunker", FuelAndBunkerInformation},
    {:emissions, "emissions", "Emissions", Emissions},
    {:cylinder_lube_oil, "cylinderLubeOil", "CylinderLubeOil", CylinderLubeOilInformation}
  ]

  @spec sections() :: [{atom(), String.t(), String.t(), module()}]
  def sections, do: @sections

  @spec section(atom()) :: {atom(), String.t(), String.t(), module()} | nil
  def section(name), do: Enum.find(@sections, fn {field, _, _, _} -> field == name end)

  @spec normalize_dataset(term()) :: StandardisedVesselDataset.t() | nil
  def normalize_dataset(%StandardisedVesselDataset{} = dataset), do: dataset

  def normalize_dataset(dataset) when is_map(dataset) do
    StandardisedVesselDataset.new(dataset)
  end

  def normalize_dataset(_), do: nil
end
