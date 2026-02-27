defmodule SVD.SerializersTest do
  use ExUnit.Case, async: true

  alias SVD.Models.{CargoInformation, GeneralInformation, StandardisedVesselDataset}
  alias SVD.Serializers

  test "serialize dataset to json map" do
    dataset =
      %StandardisedVesselDataset{
        general: %GeneralInformation{
          event_type: "NOON",
          imo: "1234567",
          ship_reporting_date: DateTime.utc_now() |> DateTime.truncate(:second)
        },
        cargo: %CargoInformation{
          total_containers_teu: 10,
          total_vehicles_ceu: 5
        }
      }

    payload = Serializers.to_json_map(dataset)

    assert get_in(payload, ["general", "eventType"]) == "NOON"
    assert get_in(payload, ["general", "imo"]) == "1234567"
    assert get_in(payload, ["cargo", "totalContainersTEU"]) == 10
    assert get_in(payload, ["cargo", "totalVehiclesCEU"]) == 5
  end

  test "deserialize dotnet-shaped json map to dataset" do
    payload = %{
      "general" => %{
        "eventType" => "NOON",
        "imo" => "1234567",
        "shipReportingDate" => "2026-01-01T12:00:00.0000000Z"
      },
      "cargo" => %{
        "totalContainersTEU" => 10,
        "totalVehiclesCEU" => 5
      },
      "fuelAndBunker" => %{
        "fuelGHGIntensityIMOManual" => 1.2,
        "fuelGHGIntensityIMOVoyage" => 1.1
      }
    }

    assert {:ok, dataset} = Serializers.from_json_map(payload)

    assert dataset.general.event_type == "NOON"
    assert dataset.general.imo == "1234567"
    assert %DateTime{} = dataset.general.ship_reporting_date
    assert dataset.cargo.total_containers_teu == 10
    assert dataset.cargo.total_vehicles_ceu == 5
    assert dataset.fuel_and_bunker.fuel_ghg_intensity_imo_manual == 1.2
    assert dataset.fuel_and_bunker.fuel_ghg_intensity_imo_voyage == 1.1
  end

  test "deserialize supports pascal case keys" do
    payload = %{
      "General" => %{
        "EventType" => "NOON",
        "Imo" => "1234567"
      }
    }

    assert {:ok, dataset} = Serializers.from_json_map(payload)
    assert dataset.general.event_type == "NOON"
    assert dataset.general.imo == "1234567"
  end

  test "deserialize rejects non map payload" do
    assert {:error, :invalid_json_payload} = Serializers.from_json_map("bad")
  end

  test "deserialize treats non-map section payloads as nil" do
    payload = %{"general" => "bad-section"}
    assert {:ok, dataset} = Serializers.from_json_map(payload)
    assert dataset.general == nil
  end
end
