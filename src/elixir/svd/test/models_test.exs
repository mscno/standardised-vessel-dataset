defmodule SVD.ModelsTest do
  use ExUnit.Case, async: true

  alias SVD.Models
  alias SVD.Models.{GeneralInformation, StandardisedVesselDataset}

  test "sections and section lookup" do
    sections = Models.sections()
    assert is_list(sections)
    assert Models.section(:general)
    assert Models.section(:missing) == nil
    assert StandardisedVesselDataset.fields() != []
  end

  test "normalize dataset from struct" do
    dataset = %StandardisedVesselDataset{}
    assert Models.normalize_dataset(dataset) == dataset
  end

  test "normalize dataset from map and string keys" do
    dataset =
      Models.normalize_dataset(%{
        "general" => %{"imo" => "1234567", "ship_name" => "x"},
        "portAndRoute" => %{"departure_port_code" => "SGSIN"}
      })

    assert %StandardisedVesselDataset{} = dataset
    assert %GeneralInformation{} = dataset.general
    assert dataset.port_and_route.departure_port_code == "SGSIN"
  end

  test "normalize dataset invalid" do
    assert Models.normalize_dataset(:invalid) == nil
  end

  test "standardised vessel dataset new with mixed keys" do
    dataset =
      StandardisedVesselDataset.new(%{
        "arrivalTimes" => %{estimated_time_of_arrival: DateTime.utc_now()},
        "deviation_from_planned" => %{deviation_reason: "x"},
        "speedAndDistance" => %{speed_over_ground: 10.0},
        "freshWater" => %{fresh_water_rob: 1.0},
        "electricity_consumption" => %{total_power_consumption: 1.0},
        "fuelAndBunker" => %{hfo_rob: 1.0},
        "cylinder_lube_oil" => %{total_lube_oil_bunkered: 1.0},
        general: %GeneralInformation{imo: "1234567"}
      })

    assert dataset.general.imo == "1234567"
    assert dataset.arrival_times.estimated_time_of_arrival != nil
    assert dataset.deviation_from_planned.deviation_reason == "x"
    assert dataset.speed_and_distance.speed_over_ground == 10.0
    assert dataset.fresh_water.fresh_water_rob == 1.0
    assert dataset.electricity_consumption.total_power_consumption == 1.0
    assert dataset.fuel_and_bunker.hfo_rob == 1.0
    assert dataset.cylinder_lube_oil.total_lube_oil_bunkered == 1.0
  end

  test "standardised vessel dataset new handles unsupported section values" do
    dataset = StandardisedVesselDataset.new(%{general: :unsupported})
    assert dataset.general == nil
  end
end
