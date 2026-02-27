defmodule SVD.Models.FuelAndBunkerInformation do
  @moduledoc false

  @fields [
    :main_engine_fuel_oil_consumption,
    :main_engine_fuel_oil_type,
    :main_engine_fuel_oil_rob,
    :auxiliary_engine_fuel_oil_consumption,
    :auxiliary_engine_fuel_oil_type,
    :auxiliary_engine_fuel_oil_rob,
    :boiler_fuel_oil_consumption,
    :boiler_fuel_oil_type,
    :boiler_fuel_oil_rob,
    :incinerator_fuel_oil_consumption,
    :gas_fuel_consumption,
    :gas_fuel_type,
    :gas_fuel_rob,
    :mgo_consumption,
    :mgo_rob,
    :hfo_consumption,
    :hfo_rob,
    :mdo_consumption,
    :mdo_rob,
    :total_fuel_oil_bunkered,
    :fuel_type,
    :fuel_type_trade_name,
    :bunker_delivery_note_number,
    :bunker_delivery_date_time,
    :fuel_proof_of_sustainability_reference,
    :fuel_bunkered,
    :fuel_mass,
    :fuel_density,
    :fuel_sulphur_content,
    :fuel_viscosity,
    :fuel_water_content,
    :fuel_higher_heating_value,
    :fuel_lower_heating_value,
    :fuel_calorific_value_reporting_scheme_code,
    :fuel_lower_calorific_value,
    :fuel_grade,
    :fuel_ghg_intensity_imo_manual,
    :fuel_ghg_intensity_imo_voyage,
    :fuel_bunker_port,
    :fuel_bunker_port_name,
    :fuel_carbon_dioxide_emission,
    :total_fuel_consumed,
    :fuel_consumed_by_main_engine,
    :fuel_consumed_by_diesel_electric_propulsion,
    :fuel_consumed_by_diesel_generator,
    :fuel_consumed_by_auxiliary_boiler,
    :fuel_consumed_by_auxiliary_engine,
    :fuel_consumed_by_cargo_heating,
    :fuel_consumed_by_reefer_containers,
    :fuel_consumed_by_discharge_pump,
    :fuel_consumed_by_other_devices,
    :fuel_remaining_on_board,
    :sludge_remaining_on_board
  ]

  @derive {Jason.Encoder, only: @fields}
  defstruct @fields

  @type t :: %__MODULE__{}

  @spec fields() :: [atom()]
  def fields, do: @fields
end
