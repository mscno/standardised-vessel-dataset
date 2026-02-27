defmodule SVD.DotNetWire do
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
    WeatherInformation
  }

  @field_name_overrides %{
    total_containers_teu: "TotalContainersTEU",
    total_full_containers_teu: "TotalFullContainersTEU",
    total_full_reefer_containers_teu: "TotalFullReeferContainersTEU",
    total_vehicles_ceu: "TotalVehiclesCEU",
    fuel_ghg_intensity_imo_manual: "FuelGHGIntensityIMOManual",
    fuel_ghg_intensity_imo_voyage: "FuelGHGIntensityIMOVoyage"
  }

  @sections [
    %{
      field: :general,
      json: "general",
      xml: "General",
      csv: "General",
      module: GeneralInformation,
      fields: [
        {:event_type, :string},
        {:operation_type, :string},
        {:operation_description, :string},
        {:performance_report_type, :string},
        {:elapsed_time, :timespan},
        {:ship_latitude, :float},
        {:ship_longitude, :float},
        {:ship_reporting_date, :datetime},
        {:ship_flag_state, :string},
        {:ship_registry_port_code, :string},
        {:ship_registry_port_name, :string},
        {:ship_name, :string},
        {:imo, :string},
        {:mmsi, :string},
        {:ship_type, :string},
        {:ship_type_marpol_annex_vi, :string},
        {:number_of_passengers, :integer},
        {:number_of_crew, :integer},
        {:voyage_number, :string},
        {:voyage_remarks, :string},
        {:voyage_leg_identifier, :string},
        {:voyage_leg_remarks, :string}
      ]
    },
    %{
      field: :port_and_route,
      json: "portAndRoute",
      xml: "PortAndRoute",
      csv: "PortAndRoute",
      module: PortInformation,
      fields: [
        {:departure_port_code, :string},
        {:departure_port_name, :string},
        {:arrival_port_code, :string},
        {:arrival_port_name, :string},
        {:inbound_port_jurisdiction_code, :string},
        {:outbound_port_jurisdiction_code, :string},
        {:pilot_boarding_place_name, :string},
        {:pilot_boarding_place_location, :string},
        {:berth_name, :string}
      ]
    },
    %{
      field: :arrival_times,
      json: "arrivalTimes",
      xml: "ArrivalTimes",
      csv: "ArrivalTimes",
      module: ArrivalTimes,
      fields: [
        {:arrival, :datetime},
        {:departure, :datetime},
        {:location_eta, :datetime},
        {:location_actual, :datetime},
        {:pilot_boarding_place_eta, :datetime},
        {:pilot_boarding_place_actual, :datetime},
        {:vts_eta, :datetime},
        {:vts_actual, :datetime},
        {:next_port_eta, :datetime},
        {:voyage_time, :integer}
      ]
    },
    %{
      field: :deviation_from_planned,
      json: "deviationFromPlanned",
      xml: "DeviationFromPlanned",
      csv: "DeviationFromPlanned",
      module: DeviationFromPlanned,
      fields: [
        {:reason, :string},
        {:latitude, :float},
        {:longitude, :float},
        {:ship_deviation_started_time, :datetime},
        {:ship_deviation_stopped_time, :datetime}
      ]
    },
    %{
      field: :speed_and_distance,
      json: "speedAndDistance",
      xml: "SpeedAndDistance",
      csv: "SpeedAndDistance",
      module: SpeedAndDistance,
      fields: [
        {:distance_through_water, :float},
        {:distance_over_ground, :float},
        {:distance_sailed_in_ice, :float},
        {:distance_to_next_port, :float},
        {:distance_to_next_waypoint, :float},
        {:total_distance_on_sea_passage, :float},
        {:distance_excluded, :float},
        {:speed_over_ground, :float},
        {:speed_through_water, :float},
        {:speed_propeller, :float},
        {:speed_projected, :float},
        {:speed_order, :float},
        {:slip, :float},
        {:course_over_ground, :float},
        {:ship_true_heading, :float},
        {:ship_draught, :string},
        {:draught_forward, :float},
        {:draught_aft, :float},
        {:ship_actual_deadweight_tonnage, :float},
        {:ship_maximum_deadweight, :float},
        {:laden_indicator, :boolean},
        {:total_ballast_water_onboard, :float}
      ]
    },
    %{
      field: :weather,
      json: "weather",
      xml: "Weather",
      csv: "Weather",
      module: WeatherInformation,
      fields: [
        {:weather_remarks, :string},
        {:bad_weather_hours, :float},
        {:bad_weather_distance, :float},
        {:wind_force, :integer},
        {:wind_speed, :string},
        {:wind_direction, :string},
        {:wind_direction_estimated_relative, :float},
        {:wind_direction_estimated, :float},
        {:air_temperature, :float},
        {:atmospheric_pressure, :float},
        {:state_of_sea, :string},
        {:sea_direction_relative, :float},
        {:sea_direction, :float},
        {:sea_height, :float},
        {:swell_direction_relative, :float},
        {:swell_direction, :float},
        {:swell_height, :float},
        {:ocean_current_direction_relative, :float},
        {:ocean_current_direction, :float},
        {:ocean_current_direction_weather_provider, :float}
      ]
    },
    %{
      field: :fresh_water,
      json: "freshWater",
      xml: "FreshWater",
      csv: "FreshWater",
      module: FreshWater,
      fields: [
        {:fresh_water_bunkered, :float},
        {:fresh_water_produced, :float},
        {:fresh_water_consumed, :float},
        {:technical_water_produced, :float},
        {:technical_water_consumed, :float},
        {:wash_water_consumed, :float},
        {:fresh_water_remaining, :float}
      ]
    },
    %{
      field: :electricity_consumption,
      json: "electricityConsumption",
      xml: "ElectricityConsumption",
      csv: "ElectricityConsumption",
      module: ElectricityConsumption,
      fields: [
        {:boiler_electricity_consumption, :float},
        {:generator_production, :float},
        {:offset_electricity_consumption, :float},
        {:power_consumption_for_plant, :float},
        {:electrical_for_cargo_cooling, :float},
        {:electrical_for_discharge_pump, :float},
        {:electrical_for_reefer_containers, :float},
        {:electrical_from_on_shore_power_supply, :float},
        {:electrical_from_zero_emissions_technologies, :float},
        {:fuel_type_used_for_cargo_cooling, :string},
        {:fuel_type_used_for_discharge_pump, :string},
        {:fuel_type_used_for_reefer_containers, :string},
        {:fuel_oil_consumption_for_cargo_cooling, :float},
        {:fuel_oil_consumption_for_discharge_pump, :float},
        {:fuel_oil_consumption_for_reefer_containers, :float}
      ]
    },
    %{
      field: :cargo,
      json: "cargo",
      xml: "Cargo",
      csv: "Cargo",
      module: CargoInformation,
      fields: [
        {:cargo_description, :string},
        {:gross_weight, :float},
        {:gross_volume, :float},
        {:bill_of_lading_reference, :string},
        {:bill_of_lading_issued_date, :datetime},
        {:total_containers_teu, :integer},
        {:total_full_containers_teu, :integer},
        {:total_full_reefer_containers_teu, :integer},
        {:reefer_sockets_in_use, :integer},
        {:chilled_20_ft_reefer_containers, :integer},
        {:chilled_40_ft_reefer_containers, :integer},
        {:frozen_20_ft_reefer_containers, :integer},
        {:frozen_40_ft_reefer_containers, :integer},
        {:total_vehicles_ceu, :integer}
      ]
    },
    %{
      field: :fuel_and_bunker,
      json: "fuelAndBunker",
      xml: "FuelAndBunker",
      csv: "FuelAndBunker",
      module: FuelAndBunkerInformation,
      fields: [
        {:fuel_type, :string},
        {:fuel_type_trade_name, :string},
        {:bunker_delivery_note_number, :string},
        {:bunker_delivery_date_time, :datetime},
        {:fuel_proof_of_sustainability_reference, :string},
        {:fuel_bunkered, :float},
        {:fuel_mass, :float},
        {:fuel_density, :float},
        {:fuel_sulphur_content, :float},
        {:fuel_viscosity, :float},
        {:fuel_water_content, :float},
        {:fuel_higher_heating_value, :float},
        {:fuel_lower_heating_value, :float},
        {:fuel_calorific_value_reporting_scheme_code, :string},
        {:fuel_lower_calorific_value, :float},
        {:fuel_grade, :string},
        {:fuel_ghg_intensity_imo_manual, :float},
        {:fuel_ghg_intensity_imo_voyage, :float},
        {:fuel_bunker_port, :string},
        {:fuel_bunker_port_name, :string},
        {:fuel_carbon_dioxide_emission, :float},
        {:total_fuel_consumed, :float},
        {:fuel_consumed_by_main_engine, :float},
        {:fuel_consumed_by_diesel_electric_propulsion, :float},
        {:fuel_consumed_by_diesel_generator, :float},
        {:fuel_consumed_by_auxiliary_boiler, :float},
        {:fuel_consumed_by_auxiliary_engine, :float},
        {:fuel_consumed_by_cargo_heating, :float},
        {:fuel_consumed_by_reefer_containers, :float},
        {:fuel_consumed_by_discharge_pump, :float},
        {:fuel_consumed_by_other_devices, :float},
        {:fuel_remaining_on_board, :float},
        {:sludge_remaining_on_board, :float}
      ]
    },
    %{
      field: :emissions,
      json: "emissions",
      xml: "Emissions",
      csv: "Emissions",
      module: Emissions,
      fields: [
        {:total_co2, :float},
        {:total_co2_percentage, :float},
        {:total_co2_tank_to_wake, :float},
        {:total_co2_captured, :float},
        {:total_ch4, :float},
        {:total_ch4_converted_to_co2, :float},
        {:total_n2o, :float},
        {:total_n2o_converted_to_co2, :float},
        {:ch4_emission_conversion_factor, :float},
        {:n2o_emission_conversion_factor, :float}
      ]
    },
    %{
      field: :cylinder_lube_oil,
      json: "cylinderLubeOil",
      xml: "CylinderLubeOil",
      csv: "CylinderLubeOil",
      module: CylinderLubeOilInformation,
      fields: [
        {:remaining_on_board, :float},
        {:feed_rate, :float},
        {:consumption, :float},
        {:received_during_bunkering, :float}
      ]
    }
  ]

  @spec sections() :: [map()]
  def sections, do: @sections

  @spec json_field_name(atom()) :: String.t()
  def json_field_name(field) when is_atom(field) do
    field
    |> xml_field_name()
    |> decapitalize_first()
  end

  @spec xml_field_name(atom()) :: String.t()
  def xml_field_name(field) when is_atom(field) do
    Map.get(@field_name_overrides, field, field |> Atom.to_string() |> Macro.camelize())
  end

  @spec csv_header(String.t(), atom()) :: String.t()
  def csv_header(section_name, field), do: "#{section_name}.#{xml_field_name(field)}"

  @spec format_value(term(), atom(), :json | :xml | :csv) :: term()
  def format_value(nil, _type, :json), do: nil
  def format_value(nil, _type, :xml), do: nil
  def format_value(nil, _type, :csv), do: ""

  def format_value(value, :string, format) when format in [:json, :xml, :csv] do
    format_string(value)
  end

  def format_value(value, :integer, :json), do: cast_integer(value)
  def format_value(value, :float, :json), do: cast_float(value)
  def format_value(value, :boolean, :json), do: cast_boolean(value)

  def format_value(value, :integer, format) when format in [:xml, :csv] do
    case cast_integer(value) do
      nil -> if(format == :xml, do: nil, else: "")
      integer -> Integer.to_string(integer)
    end
  end

  def format_value(value, :float, format) when format in [:xml, :csv] do
    case cast_float(value) do
      nil -> if(format == :xml, do: nil, else: "")
      float -> format_float(float)
    end
  end

  def format_value(value, :boolean, :xml) do
    case cast_boolean(value) do
      nil -> nil
      boolean -> Atom.to_string(boolean)
    end
  end

  def format_value(value, :boolean, :csv) do
    case cast_boolean(value) do
      nil -> ""
      true -> "True"
      false -> "False"
    end
  end

  def format_value(value, :datetime, :json), do: format_datetime_iso(value)
  def format_value(value, :datetime, :xml), do: format_datetime_iso(value)
  def format_value(value, :datetime, :csv), do: format_datetime_csv(value)

  def format_value(value, :timespan, :json), do: format_timespan_constant(value)
  def format_value(value, :timespan, :csv), do: format_timespan_constant(value) || ""
  def format_value(value, :timespan, :xml), do: format_timespan_duration(value)

  @spec parse_value(term(), atom(), :json | :xml | :csv) :: term()
  def parse_value(value, :string, _format), do: blank_to_nil(value)
  def parse_value(value, :integer, _format), do: cast_integer(blank_to_nil(value))
  def parse_value(value, :float, _format), do: cast_float(blank_to_nil(value))
  def parse_value(value, :boolean, _format), do: cast_boolean(blank_to_nil(value))
  def parse_value(value, :datetime, _format), do: parse_datetime(value)
  def parse_value(value, :timespan, _format), do: blank_to_nil(value)

  defp blank_to_nil(nil), do: nil
  defp blank_to_nil(""), do: nil
  defp blank_to_nil(value), do: value

  defp cast_integer(nil), do: nil
  defp cast_integer(value) when is_integer(value), do: value
  defp cast_integer(value) when is_float(value), do: trunc(value)

  defp cast_integer(value) when is_binary(value) do
    case Integer.parse(String.trim(value)) do
      {parsed, ""} -> parsed
      _ -> nil
    end
  end

  defp cast_integer(_), do: nil

  defp cast_float(nil), do: nil
  defp cast_float(value) when is_float(value), do: value
  defp cast_float(value) when is_integer(value), do: value * 1.0

  defp cast_float(value) when is_binary(value) do
    case Float.parse(String.trim(value)) do
      {parsed, ""} -> parsed
      _ -> nil
    end
  end

  defp cast_float(_), do: nil

  defp cast_boolean(nil), do: nil
  defp cast_boolean(value) when is_boolean(value), do: value

  defp cast_boolean(value) when is_binary(value) do
    case String.downcase(String.trim(value)) do
      "true" -> true
      "false" -> false
      "1" -> true
      "0" -> false
      _ -> nil
    end
  end

  defp cast_boolean(_), do: nil

  defp format_string(value) when is_binary(value), do: value
  defp format_string(%DateTime{} = value), do: format_datetime_iso(value)
  defp format_string(%NaiveDateTime{} = value), do: NaiveDateTime.to_iso8601(value)
  defp format_string(%Date{} = value), do: Date.to_iso8601(value)
  defp format_string(%Time{} = value), do: Time.to_iso8601(value)
  defp format_string(value), do: inspect(value)

  defp format_float(value) do
    value
    |> :erlang.float_to_binary([:short])
    |> trim_decimal_zero()
  end

  defp trim_decimal_zero(value) when is_binary(value) do
    if String.ends_with?(value, ".0") do
      String.slice(value, 0..-3//1)
    else
      value
    end
  end

  defp format_datetime_iso(%DateTime{} = value), do: value |> to_utc() |> datetime_7_digits()

  defp format_datetime_iso(%NaiveDateTime{} = value),
    do: value |> DateTime.from_naive!("Etc/UTC") |> datetime_7_digits()

  defp format_datetime_iso(value) when is_binary(value), do: value
  defp format_datetime_iso(_), do: nil

  defp format_datetime_csv(value), do: format_datetime_iso(value) || ""

  defp datetime_7_digits(%DateTime{} = value) do
    utc = to_utc(value)
    base = Calendar.strftime(utc, "%Y-%m-%dT%H:%M:%S")
    {microseconds, _precision} = utc.microsecond
    fraction = microseconds |> Integer.to_string() |> String.pad_leading(6, "0") |> Kernel.<>("0")
    "#{base}.#{fraction}Z"
  end

  defp to_utc(%DateTime{} = value) do
    case DateTime.shift_zone(value, "Etc/UTC") do
      {:ok, utc} -> utc
      _ -> DateTime.from_naive!(DateTime.to_naive(value), "Etc/UTC")
    end
  end

  defp format_timespan_constant(value) when is_binary(value), do: value

  defp format_timespan_constant(value) when is_integer(value) do
    format_timespan_from_nanoseconds(value)
  end

  defp format_timespan_constant(value) when is_float(value) do
    format_timespan_from_nanoseconds(round(value * 1_000_000_000))
  end

  defp format_timespan_constant(_), do: nil

  defp format_timespan_from_nanoseconds(nanoseconds) do
    sign = if nanoseconds < 0, do: "-", else: ""
    absolute_nanoseconds = abs(nanoseconds)

    total_seconds = div(absolute_nanoseconds, 1_000_000_000)
    remaining_nanoseconds = rem(absolute_nanoseconds, 1_000_000_000)

    days = div(total_seconds, 86_400)
    remaining_seconds = rem(total_seconds, 86_400)

    hours = div(remaining_seconds, 3_600)
    minutes = div(rem(remaining_seconds, 3_600), 60)
    seconds = rem(remaining_seconds, 60)

    fraction =
      div(remaining_nanoseconds, 100) |> Integer.to_string() |> String.pad_leading(7, "0")

    hh = hours |> Integer.to_string() |> String.pad_leading(2, "0")
    mm = minutes |> Integer.to_string() |> String.pad_leading(2, "0")
    ss = seconds |> Integer.to_string() |> String.pad_leading(2, "0")

    time_part =
      if fraction == "0000000" do
        "#{hh}:#{mm}:#{ss}"
      else
        "#{hh}:#{mm}:#{ss}.#{fraction}"
      end

    if days > 0 do
      "#{sign}#{days}.#{time_part}"
    else
      "#{sign}#{time_part}"
    end
  end

  defp format_timespan_duration(value) when is_binary(value) do
    cond do
      String.starts_with?(value, "P") ->
        value

      true ->
        case parse_timespan_constant(value) do
          {:ok, nanoseconds} -> format_duration_from_nanoseconds(nanoseconds)
          :error -> nil
        end
    end
  end

  defp format_timespan_duration(value) when is_integer(value),
    do: format_duration_from_nanoseconds(value)

  defp format_timespan_duration(value) when is_float(value),
    do: format_duration_from_nanoseconds(round(value * 1_000_000_000))

  defp format_timespan_duration(_), do: nil

  defp format_duration_from_nanoseconds(nanoseconds) do
    sign = if nanoseconds < 0, do: "-", else: ""
    absolute_nanoseconds = abs(nanoseconds)

    total_seconds = div(absolute_nanoseconds, 1_000_000_000)
    remaining_nanoseconds = rem(absolute_nanoseconds, 1_000_000_000)

    days = div(total_seconds, 86_400)
    remaining_seconds = rem(total_seconds, 86_400)
    hours = div(remaining_seconds, 3_600)
    minutes = div(rem(remaining_seconds, 3_600), 60)
    seconds = rem(remaining_seconds, 60)

    date_part = if days > 0, do: "#{days}D", else: ""

    time_parts =
      []
      |> maybe_add_duration_part(hours, "H")
      |> maybe_add_duration_part(minutes, "M")
      |> maybe_add_seconds_duration_part(seconds, remaining_nanoseconds, date_part == "")

    time_part =
      case time_parts do
        [] -> ""
        parts -> "T" <> Enum.join(parts)
      end

    "#{sign}P#{date_part}#{time_part}"
  end

  defp maybe_add_duration_part(parts, 0, _unit), do: parts
  defp maybe_add_duration_part(parts, value, unit), do: parts ++ ["#{value}#{unit}"]

  defp maybe_add_seconds_duration_part(parts, seconds, nanoseconds, force_zero_seconds) do
    fraction =
      nanoseconds
      |> div(100)
      |> Integer.to_string()
      |> String.pad_leading(7, "0")
      |> String.trim_trailing("0")

    include_seconds = seconds > 0 or fraction != "" or (force_zero_seconds and parts == [])

    if include_seconds do
      seconds_part =
        if fraction == "" do
          "#{seconds}S"
        else
          "#{seconds}.#{fraction}S"
        end

      parts ++ [seconds_part]
    else
      parts
    end
  end

  defp parse_timespan_constant(value) do
    case Regex.run(
           ~r/^(-)?(?:(\d+)\.)?(\d{2}):(\d{2}):(\d{2})(?:\.(\d{1,7}))?$/,
           String.trim(value)
         ) do
      [_, sign, days, hours, minutes, seconds, fractions] ->
        days_value = parse_integer(days)
        hours_value = parse_integer(hours)
        minutes_value = parse_integer(minutes)
        seconds_value = parse_integer(seconds)

        ticks_fraction =
          fractions
          |> to_string()
          |> String.pad_trailing(7, "0")
          |> parse_integer()

        total_seconds =
          days_value * 86_400 + hours_value * 3_600 + minutes_value * 60 + seconds_value

        total_nanoseconds = total_seconds * 1_000_000_000 + ticks_fraction * 100
        signed_nanoseconds = if sign == "-", do: -total_nanoseconds, else: total_nanoseconds
        {:ok, signed_nanoseconds}

      _ ->
        :error
    end
  end

  defp parse_integer(nil), do: 0
  defp parse_integer(value) when is_binary(value), do: String.to_integer(value)

  defp parse_datetime(nil), do: nil
  defp parse_datetime(%DateTime{} = value), do: value

  defp parse_datetime(%NaiveDateTime{} = value) do
    DateTime.from_naive!(value, "Etc/UTC")
  end

  defp parse_datetime(value) when is_binary(value) do
    trimmed = String.trim(value)

    cond do
      trimmed == "" ->
        nil

      String.starts_with?(trimmed, "P") ->
        nil

      true ->
        case DateTime.from_iso8601(trimmed) do
          {:ok, date_time, _offset} ->
            date_time

          _ ->
            case NaiveDateTime.from_iso8601(trimmed) do
              {:ok, naive_date_time} -> DateTime.from_naive!(naive_date_time, "Etc/UTC")
              _ -> nil
            end
        end
    end
  end

  defp parse_datetime(_), do: nil

  defp decapitalize_first(<<first::utf8, rest::binary>>) do
    <<String.downcase(<<first::utf8>>)::binary, rest::binary>>
  end
end
