defmodule SVD.Models.ElectricityConsumption do
  @moduledoc false

  @fields [
    :total_power_consumption,
    :auxiliary_engine_consumption,
    :boiler_consumption,
    :shore_power_consumption,
    :other_consumption,
    :boiler_electricity_consumption,
    :generator_production,
    :offset_electricity_consumption,
    :power_consumption_for_plant,
    :electrical_for_cargo_cooling,
    :electrical_for_discharge_pump,
    :electrical_for_reefer_containers,
    :electrical_from_on_shore_power_supply,
    :electrical_from_zero_emissions_technologies,
    :fuel_type_used_for_cargo_cooling,
    :fuel_type_used_for_discharge_pump,
    :fuel_type_used_for_reefer_containers,
    :fuel_oil_consumption_for_cargo_cooling,
    :fuel_oil_consumption_for_discharge_pump,
    :fuel_oil_consumption_for_reefer_containers
  ]

  @derive {Jason.Encoder, only: @fields}
  defstruct @fields

  @type t :: %__MODULE__{}

  @spec fields() :: [atom()]
  def fields, do: @fields
end
