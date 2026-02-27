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
      voyage_leg_remarks: "Normal progress",
      call_sign: "ABCD",
      deadweight: 100_000.0
    }
  end

  @spec valid_port_information() :: PortInformation.t()
  def valid_port_information do
    %PortInformation{
      departure_port_code: "SGSIN",
      departure_port_description: "Singapore, Singapore",
      arrival_port_code: "NLRTM",
      arrival_port_description: "Rotterdam, Netherlands",
      pilot_boarding_place_name: "Pilot Station Alpha",
      pilot_boarding_place_location: "51.95N, 4.10E",
      berth_name: "Berth 42"
    }
  end

  @spec valid_arrival_times() :: ArrivalTimes.t()
  def valid_arrival_times do
    now = DateTime.utc_now()

    %ArrivalTimes{
      estimated_time_of_arrival: DateTime.add(now, 72 * 60 * 60, :second),
      estimated_time_of_completion: DateTime.add(now, 96 * 60 * 60, :second),
      estimated_time_of_pilot_boarding: DateTime.add(now, 71 * 60 * 60, :second),
      estimated_time_of_berth: DateTime.add(now, 73 * 60 * 60, :second)
    }
  end

  @spec valid_deviation_from_planned() :: DeviationFromPlanned.t()
  def valid_deviation_from_planned do
    %DeviationFromPlanned{
      deviation_reason: "Weather avoidance",
      deviation_description: "Avoiding tropical storm",
      deviation_distance: 45.0,
      deviation_time: 5.0
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
      speed_over_ground: 15.5,
      speed_through_water: 14.8,
      speed_propeller: 78.5,
      speed_projected: 15.0,
      speed_order: 15.5,
      slip_ratio: 3.5,
      speed_stopping: 0.0
    }
  end

  @spec valid_weather_information() :: WeatherInformation.t()
  def valid_weather_information do
    %WeatherInformation{
      wind_speed: 12.5,
      wind_direction: 225.0,
      wind_force: 4,
      wave_height: 2.5,
      wave_direction: 210.0,
      swell_height: 1.8,
      swell_direction: 200.0,
      sea_state: 3,
      air_temperature: 22.5,
      water_temperature: 21.0,
      atmospheric_pressure: 1013.25,
      visibility: 10.0,
      current_speed: 1.5,
      current_direction: 180.0
    }
  end

  @spec valid_fresh_water() :: FreshWater.t()
  def valid_fresh_water do
    %FreshWater{
      fresh_water_produced: 12.5,
      fresh_water_consumed: 8.3,
      fresh_water_received: 0.0,
      fresh_water_discharged: 0.0,
      fresh_water_rob: 250.0
    }
  end

  @spec valid_electricity_consumption() :: ElectricityConsumption.t()
  def valid_electricity_consumption do
    %ElectricityConsumption{
      total_power_consumption: 2500.0,
      auxiliary_engine_consumption: 1200.0,
      boiler_consumption: 300.0,
      shore_power_consumption: 0.0,
      other_consumption: 1000.0
    }
  end

  @spec valid_cargo_information() :: CargoInformation.t()
  def valid_cargo_information do
    %CargoInformation{
      cargo_type: "Container",
      cargo_description: "Mixed general cargo",
      cargo_quantity: 25_000.0,
      cargo_loaded: 0.0,
      cargo_discharged: 0.0,
      cargo_rob: 25_000.0,
      teu_count: 2500,
      feu_count: 1250,
      passenger_count: 0,
      vehicle_count: 0
    }
  end

  @spec valid_fuel_and_bunker_information() :: FuelAndBunkerInformation.t()
  def valid_fuel_and_bunker_information do
    %FuelAndBunkerInformation{
      main_engine_fuel_oil_consumption: 45.5,
      main_engine_fuel_oil_type: "VLSFO",
      main_engine_fuel_oil_rob: 1250.0,
      auxiliary_engine_fuel_oil_consumption: 8.5,
      auxiliary_engine_fuel_oil_type: "MGO",
      auxiliary_engine_fuel_oil_rob: 250.0,
      boiler_fuel_oil_consumption: 0.0,
      boiler_fuel_oil_type: "",
      boiler_fuel_oil_rob: 0.0,
      incinerator_fuel_oil_consumption: 0.0,
      gas_fuel_consumption: 0.0,
      gas_fuel_type: "",
      gas_fuel_rob: 0.0,
      mgo_consumption: 8.5,
      mgo_rob: 250.0,
      hfo_consumption: 45.5,
      hfo_rob: 1250.0,
      mdo_consumption: 0.0,
      mdo_rob: 0.0,
      total_fuel_oil_bunkered: 0.0
    }
  end

  @spec valid_cylinder_lube_oil_information() :: CylinderLubeOilInformation.t()
  def valid_cylinder_lube_oil_information do
    %CylinderLubeOilInformation{
      main_engine_cylinder_oil_consumption: 250.0,
      main_engine_cylinder_oil_type: "BN100",
      main_engine_cylinder_oil_rob: 8500.0,
      main_engine_system_oil_consumption: 25.0,
      main_engine_system_oil_type: "SAE 30",
      main_engine_system_oil_rob: 2500.0,
      auxiliary_engine_lube_oil_consumption: 0.0,
      auxiliary_engine_lube_oil_type: "",
      auxiliary_engine_lube_oil_rob: 0.0,
      total_lube_oil_bunkered: 0.0
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
