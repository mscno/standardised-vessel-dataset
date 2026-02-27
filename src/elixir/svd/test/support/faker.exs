defmodule SVD.TestSupport.Faker do
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

  @spec valid_svd() :: StandardisedVesselDataset.t()
  def valid_svd do
    %StandardisedVesselDataset{
      general: valid_general_information(),
      port_and_route: valid_port_information(),
      arrival_times: valid_arrival_times(),
      deviation_from_planned: valid_deviation_from_planned(),
      speed_and_distance: valid_speed_and_distance(),
      weather: valid_weather_information(),
      fresh_water: valid_fresh_water(),
      electricity_consumption: valid_electricity_consumption(),
      cargo: valid_cargo_information(),
      fuel_and_bunker: valid_fuel_and_bunker_information(),
      emissions: valid_emissions(),
      cylinder_lube_oil: valid_cylinder_lube_oil_information()
    }
  end

  @spec invalid_svd() :: StandardisedVesselDataset.t()
  def invalid_svd do
    %StandardisedVesselDataset{
      general: %GeneralInformation{
        event_type: "",
        operation_type: "",
        ship_name: "",
        imo: "",
        ship_latitude: 200,
        ship_longitude: 200,
        ship_reporting_date: nil,
        number_of_crew: -10
      }
    }
  end

  @spec valid_general_information() :: GeneralInformation.t()
  def valid_general_information do
    %GeneralInformation{
      event_type: "NOON",
      operation_type: "SAILING",
      operation_description: "Normal sailing operations",
      elapsed_time: 86_400_000_000_000,
      ship_latitude: 51.5074,
      ship_longitude: -0.1278,
      ship_reporting_date: DateTime.add(DateTime.utc_now(), -24 * 60 * 60, :second),
      ship_name: "MV Ocean Explorer",
      imo: "9876543",
      mmsi: "123456789",
      ship_type: "Container Ship",
      number_of_crew: 25,
      voyage_number: "VOY2024001",
      voyage_remarks: "On schedule",
      voyage_leg_identifier: "LEG001",
      voyage_leg_remarks: "Normal progress"
    }
  end

  @spec valid_port_information() :: PortInformation.t()
  def valid_port_information do
    %PortInformation{
      departure_port_code: "SGSIN",
      departure_port_name: "Singapore, Singapore",
      arrival_port_code: "NLRTM",
      arrival_port_name: "Rotterdam, Netherlands",
      pilot_boarding_place_name: "Pilot Station Alpha",
      pilot_boarding_place_location: "51.95N, 4.10E",
      berth_name: "Berth 42"
    }
  end

  @spec valid_arrival_times() :: ArrivalTimes.t()
  def valid_arrival_times do
    now = DateTime.utc_now()

    %ArrivalTimes{
      arrival: DateTime.add(now, -12 * 60 * 60, :second),
      departure: DateTime.add(now, -24 * 60 * 60, :second),
      location_eta: DateTime.add(now, 72 * 60 * 60, :second),
      location_actual: DateTime.add(now, -1 * 60 * 60, :second),
      pilot_boarding_place_eta: DateTime.add(now, 71 * 60 * 60, :second),
      pilot_boarding_place_actual: DateTime.add(now, -2 * 60 * 60, :second),
      vts_eta: DateTime.add(now, 68 * 60 * 60, :second),
      vts_actual: DateTime.add(now, -3 * 60 * 60, :second),
      next_port_eta: DateTime.add(now, 96 * 60 * 60, :second),
      voyage_time: 72
    }
  end

  @spec valid_deviation_from_planned() :: DeviationFromPlanned.t()
  def valid_deviation_from_planned do
    %DeviationFromPlanned{
      reason: "Weather avoidance",
      latitude: 52.0,
      longitude: 2.1,
      ship_deviation_started_time: DateTime.add(DateTime.utc_now(), -5 * 60 * 60, :second),
      ship_deviation_stopped_time: DateTime.add(DateTime.utc_now(), -4 * 60 * 60, :second)
    }
  end

  @spec valid_speed_and_distance() :: SpeedAndDistance.t()
  def valid_speed_and_distance do
    %SpeedAndDistance{
      distance_through_water: 280.5,
      distance_over_ground: 275.3,
      distance_sailed_in_ice: 0.0,
      distance_to_next_port: 1250.0,
      distance_to_next_waypoint: 120.5,
      total_distance_on_sea_passage: 1500.0,
      distance_excluded: 2.2,
      speed_over_ground: 15.5,
      speed_through_water: 14.8,
      speed_propeller: 78.5,
      speed_projected: 15.0,
      speed_order: 15.5,
      slip: 3.5,
      course_over_ground: 182.0,
      ship_true_heading: 180.0,
      ship_draught: "11.2",
      draught_forward: 10.8,
      draught_aft: 11.2,
      ship_actual_deadweight_tonnage: 98_000.0,
      ship_maximum_deadweight: 100_000.0,
      laden_indicator: true,
      total_ballast_water_onboard: 1200.0
    }
  end

  @spec valid_weather_information() :: WeatherInformation.t()
  def valid_weather_information do
    %WeatherInformation{
      weather_remarks: "Moderate sea state",
      bad_weather_hours: 1.5,
      bad_weather_distance: 12.0,
      wind_force: 4,
      wind_speed: "12.5",
      wind_direction: "225",
      wind_direction_estimated_relative: 45.0,
      wind_direction_estimated: 225.0,
      air_temperature: 22.5,
      atmospheric_pressure: 1013.25,
      state_of_sea: "3",
      sea_direction_relative: 30.0,
      sea_direction: 210.0,
      sea_height: 2.5,
      swell_direction_relative: 20.0,
      swell_height: 1.8,
      swell_direction: 200.0,
      ocean_current_direction_relative: 10.0,
      ocean_current_direction: 180.0,
      ocean_current_direction_weather_provider: 185.0
    }
  end

  @spec valid_fresh_water() :: FreshWater.t()
  def valid_fresh_water do
    %FreshWater{
      fresh_water_bunkered: 2.0,
      fresh_water_produced: 12.5,
      fresh_water_consumed: 8.3,
      technical_water_produced: 4.0,
      technical_water_consumed: 3.0,
      wash_water_consumed: 1.5,
      fresh_water_remaining: 250.0
    }
  end

  @spec valid_electricity_consumption() :: ElectricityConsumption.t()
  def valid_electricity_consumption do
    %ElectricityConsumption{
      boiler_electricity_consumption: 300.0,
      generator_production: 2500.0,
      offset_electricity_consumption: 50.0,
      power_consumption_for_plant: 600.0,
      electrical_for_cargo_cooling: 400.0,
      electrical_for_discharge_pump: 150.0,
      electrical_for_reefer_containers: 320.0,
      electrical_from_on_shore_power_supply: 0.0,
      electrical_from_zero_emissions_technologies: 10.0,
      fuel_type_used_for_cargo_cooling: "VLSFO",
      fuel_type_used_for_discharge_pump: "MGO",
      fuel_type_used_for_reefer_containers: "MGO",
      fuel_oil_consumption_for_cargo_cooling: 1.2,
      fuel_oil_consumption_for_discharge_pump: 0.8,
      fuel_oil_consumption_for_reefer_containers: 0.6
    }
  end

  @spec valid_cargo_information() :: CargoInformation.t()
  def valid_cargo_information do
    %CargoInformation{
      cargo_description: "Mixed general cargo",
      gross_weight: 25_000.0,
      gross_volume: 18_200.0,
      bill_of_lading_reference: "BOL-001",
      bill_of_lading_issued_date: DateTime.add(DateTime.utc_now(), -48 * 60 * 60, :second),
      total_containers_teu: 2500,
      total_full_containers_teu: 2000,
      total_full_reefer_containers_teu: 400,
      reefer_sockets_in_use: 210,
      chilled_20_ft_reefer_containers: 100,
      chilled_40_ft_reefer_containers: 60,
      frozen_20_ft_reefer_containers: 80,
      frozen_40_ft_reefer_containers: 40,
      total_vehicles_ceu: 0
    }
  end

  @spec valid_fuel_and_bunker_information() :: FuelAndBunkerInformation.t()
  def valid_fuel_and_bunker_information do
    %FuelAndBunkerInformation{
      fuel_type: "VLSFO",
      fuel_type_trade_name: "Very Low Sulphur Fuel Oil",
      bunker_delivery_note_number: "BDN-123",
      bunker_delivery_date_time: DateTime.add(DateTime.utc_now(), -72 * 60 * 60, :second),
      fuel_proof_of_sustainability_reference: "POS-ABC",
      fuel_bunkered: 200.0,
      fuel_mass: 198.0,
      fuel_density: 0.94,
      fuel_sulphur_content: 0.5,
      fuel_viscosity: 380.0,
      fuel_water_content: 0.1,
      fuel_higher_heating_value: 42.5,
      fuel_lower_heating_value: 40.2,
      fuel_calorific_value_reporting_scheme_code: "IMO",
      fuel_lower_calorific_value: 39.8,
      fuel_grade: "RMG380",
      fuel_ghg_intensity_imo_manual: 91.0,
      fuel_ghg_intensity_imo_voyage: 90.5,
      fuel_bunker_port: "SGSIN",
      fuel_bunker_port_name: "Singapore",
      fuel_carbon_dioxide_emission: 3.114,
      total_fuel_consumed: 54.0,
      fuel_consumed_by_main_engine: 45.5,
      fuel_consumed_by_diesel_electric_propulsion: 0.0,
      fuel_consumed_by_diesel_generator: 8.5,
      fuel_consumed_by_auxiliary_boiler: 0.0,
      fuel_consumed_by_auxiliary_engine: 0.0,
      fuel_consumed_by_cargo_heating: 0.0,
      fuel_consumed_by_reefer_containers: 0.0,
      fuel_consumed_by_discharge_pump: 0.0,
      fuel_consumed_by_other_devices: 0.0,
      fuel_remaining_on_board: 1250.0,
      sludge_remaining_on_board: 15.0
    }
  end

  @spec valid_cylinder_lube_oil_information() :: CylinderLubeOilInformation.t()
  def valid_cylinder_lube_oil_information do
    %CylinderLubeOilInformation{
      remaining_on_board: 8.5,
      feed_rate: 1.4,
      consumption: 0.3,
      received_during_bunkering: 2.0
    }
  end

  @spec valid_emissions() :: Emissions.t()
  def valid_emissions do
    %Emissions{
      total_co2: 120.0,
      total_co2_percentage: 95.0,
      total_co2_tank_to_wake: 110.0,
      total_co2_captured: 10.0,
      total_ch4: 0.5,
      total_ch4_converted_to_co2: 14.0,
      total_n2o: 0.2,
      total_n2o_converted_to_co2: 53.0,
      ch4_emission_conversion_factor: 0.01,
      n2o_emission_conversion_factor: 0.02
    }
  end
end
