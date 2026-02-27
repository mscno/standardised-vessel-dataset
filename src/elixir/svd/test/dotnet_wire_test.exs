defmodule SVD.DotNetWireTest do
  use ExUnit.Case, async: true

  alias SVD.DotNetWire

  test "field names keep dotnet acronyms" do
    assert DotNetWire.xml_field_name(:event_type) == "EventType"
    assert DotNetWire.json_field_name(:event_type) == "eventType"
    assert DotNetWire.xml_field_name(:total_containers_teu) == "TotalContainersTEU"
    assert DotNetWire.json_field_name(:total_containers_teu) == "totalContainersTEU"

    assert DotNetWire.xml_field_name(:fuel_ghg_intensity_imo_manual) ==
             "FuelGHGIntensityIMOManual"

    assert DotNetWire.json_field_name(:fuel_ghg_intensity_imo_manual) ==
             "fuelGHGIntensityIMOManual"
  end

  test "csv header uses section and dotnet field name" do
    assert DotNetWire.csv_header("Cargo", :total_vehicles_ceu) == "Cargo.TotalVehiclesCEU"
  end

  test "boolean formatting differs between xml and csv like dotnet exporters" do
    assert DotNetWire.format_value(nil, :boolean, :xml) == nil
    assert DotNetWire.format_value(nil, :boolean, :csv) == ""
    assert DotNetWire.format_value(true, :boolean, :xml) == "true"
    assert DotNetWire.format_value(false, :boolean, :xml) == "false"
    assert DotNetWire.format_value(true, :boolean, :csv) == "True"
    assert DotNetWire.format_value(false, :boolean, :csv) == "False"
  end

  test "float formatting is compact and stable" do
    assert DotNetWire.format_value(nil, :float, :xml) == nil
    assert DotNetWire.format_value(nil, :float, :csv) == ""
    assert DotNetWire.format_value(120.0, :float, :xml) == "120"
    assert DotNetWire.format_value(51.5074, :float, :xml) == "51.5074"
    assert DotNetWire.format_value(10, :float, :json) == 10.0
    assert DotNetWire.format_value("invalid", :float, :json) == nil
    assert DotNetWire.format_value(:invalid, :float, :json) == nil
  end

  test "integer formatting handles nil and casts" do
    assert DotNetWire.format_value(nil, :integer, :xml) == nil
    assert DotNetWire.format_value(nil, :integer, :csv) == ""
    assert DotNetWire.format_value(10.9, :integer, :json) == 10
    assert DotNetWire.format_value("bad", :integer, :json) == nil
    assert DotNetWire.format_value(:bad, :integer, :json) == nil
  end

  test "string formatting handles date-like values and fallbacks" do
    dt = DateTime.from_naive!(~N[2026-01-01 12:00:00], "Etc/UTC")
    assert DotNetWire.format_value(dt, :string, :json) == "2026-01-01T12:00:00.0000000Z"

    assert DotNetWire.format_value(~N[2026-01-01 12:00:00], :string, :json) ==
             "2026-01-01T12:00:00"

    assert DotNetWire.format_value(~D[2026-01-01], :string, :json) == "2026-01-01"
    assert DotNetWire.format_value(~T[12:30:45], :string, :json) == "12:30:45"
    assert DotNetWire.format_value({:a, 1}, :string, :json) == "{:a, 1}"
  end

  test "datetime formatting handles naive, binary and invalid values" do
    assert DotNetWire.format_value(~N[2026-01-01 12:00:00], :datetime, :json) ==
             "2026-01-01T12:00:00.0000000Z"

    assert DotNetWire.format_value("2026-01-01T12:00:00.0000000Z", :datetime, :json) ==
             "2026-01-01T12:00:00.0000000Z"

    assert DotNetWire.format_value(:bad, :datetime, :json) == nil
  end

  test "datetime formatting falls back when timezone conversion fails" do
    bad_dt = %DateTime{
      year: 2026,
      month: 1,
      day: 1,
      hour: 12,
      minute: 0,
      second: 0,
      microsecond: {0, 0},
      std_offset: 0,
      utc_offset: 0,
      zone_abbr: "UTC",
      time_zone: "Bad/Zone",
      calendar: Calendar.ISO
    }

    assert DotNetWire.format_value(bad_dt, :datetime, :json) == "2026-01-01T12:00:00.0000000Z"
  end

  test "timespan formatting matches dotnet styles" do
    one_day_ns = 86_400_000_000_000
    assert DotNetWire.format_value(one_day_ns, :timespan, :json) == "1.00:00:00"
    assert DotNetWire.format_value(one_day_ns, :timespan, :csv) == "1.00:00:00"
    assert DotNetWire.format_value(one_day_ns, :timespan, :xml) == "P1D"
  end

  test "timespan xml formatter accepts dotnet constant input" do
    assert DotNetWire.format_value("1.12:30:15.1234567", :timespan, :xml) ==
             "P1DT12H30M15.1234567S"
  end

  test "timespan formatting handles fractional, invalid and float values" do
    assert DotNetWire.format_value(1_234_567_800, :timespan, :json) == "00:00:01.2345678"
    assert DotNetWire.format_value(1.5, :timespan, :json) == "00:00:01.5000000"
    assert DotNetWire.format_value(:bad, :timespan, :json) == nil

    assert DotNetWire.format_value("P1DT1H", :timespan, :xml) == "P1DT1H"
    assert DotNetWire.format_value("bad", :timespan, :xml) == nil
    assert DotNetWire.format_value(61_000_000_000, :timespan, :xml) == "PT1M1S"
    assert DotNetWire.format_value(1.25, :timespan, :xml) == "PT1.25S"
    assert DotNetWire.format_value(:bad, :timespan, :xml) == nil
  end

  test "parsing supports dotnet boolean and numeric text values" do
    assert DotNetWire.parse_value("True", :boolean, :csv) == true
    assert DotNetWire.parse_value("False", :boolean, :csv) == false
    assert DotNetWire.parse_value("1", :boolean, :csv) == true
    assert DotNetWire.parse_value("0", :boolean, :csv) == false
    assert DotNetWire.parse_value("bad", :boolean, :csv) == nil
    assert DotNetWire.parse_value(:bad, :boolean, :csv) == nil
    assert DotNetWire.parse_value("10", :integer, :csv) == 10
    assert DotNetWire.parse_value(10.9, :integer, :csv) == 10
    assert DotNetWire.parse_value("bad", :integer, :csv) == nil
    assert DotNetWire.parse_value(:bad, :integer, :csv) == nil
    assert DotNetWire.parse_value("10.5", :float, :csv) == 10.5
    assert DotNetWire.parse_value(10, :float, :csv) == 10.0
    assert DotNetWire.parse_value("bad", :float, :csv) == nil
    assert DotNetWire.parse_value(:bad, :float, :csv) == nil
  end

  test "datetime parsing handles all supported forms" do
    dt = DateTime.from_naive!(~N[2026-01-01 12:00:00], "Etc/UTC")
    assert DotNetWire.parse_value(nil, :datetime, :json) == nil
    assert DotNetWire.parse_value(dt, :datetime, :json) == dt
    assert DotNetWire.parse_value(~N[2026-01-01 12:00:00], :datetime, :json) == dt
    assert DotNetWire.parse_value("   ", :datetime, :json) == nil
    assert DotNetWire.parse_value("PT1H", :datetime, :json) == nil
    assert DotNetWire.parse_value("2026-01-01T12:00:00Z", :datetime, :json) == dt
    assert DotNetWire.parse_value("2026-01-01T12:00:00", :datetime, :json) == dt
    assert DotNetWire.parse_value("not-a-date", :datetime, :json) == nil
    assert DotNetWire.parse_value(123, :datetime, :json) == nil
  end

  test "string parser treats blanks as nil" do
    assert DotNetWire.parse_value("", :string, :json) == nil
    assert DotNetWire.parse_value("x", :string, :json) == "x"
  end
end
