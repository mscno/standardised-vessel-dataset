defmodule SVD.Exporters.JSONExporterTest do
  use ExUnit.Case, async: true

  alias SVD.Exporters.Formats.JSONExporter
  alias SVD.Models.StandardisedVesselDataset
  alias SVD.TestSupport.Faker
  alias SVD.Validators.{StandardisedVesselDatasetValidator, ValidatorException}

  setup do
    %{exporter: JSONExporter.new(StandardisedVesselDatasetValidator)}
  end

  test "default struct can be created" do
    exporter = struct(JSONExporter)
    assert exporter.validator == StandardisedVesselDatasetValidator
  end

  test "export nil svd", %{exporter: exporter} do
    assert {:error, "SVD cannot be nil"} = JSONExporter.export_async(exporter, nil)
  end

  test "export invalid svd", %{exporter: exporter} do
    assert {:error, %ValidatorException{} = exception} =
             JSONExporter.export_async(exporter, Faker.invalid_svd())

    assert ValidatorException.has_errors?(exception)
  end

  test "export valid svd", %{exporter: exporter} do
    assert {:ok, content} = JSONExporter.export_async(exporter, Faker.valid_svd())

    assert byte_size(content.data) > 0
    assert String.contains?(content.file_name, Faker.valid_svd().general.imo)
    assert content.content_type == "application/json"
  end

  test "export minimal valid data", %{exporter: exporter} do
    minimal = %StandardisedVesselDataset{general: Faker.valid_general_information()}
    assert {:ok, content} = JSONExporter.export_async(exporter, minimal)
    assert byte_size(content.data) > 0
  end

  test "valid json format", %{exporter: exporter} do
    assert {:ok, content} = JSONExporter.export_async(exporter, Faker.valid_svd())
    assert {:ok, payload} = Jason.decode(content.data)

    assert Map.has_key?(payload, "general")
    assert Map.has_key?(payload, "portAndRoute")
    assert Map.has_key?(payload, "arrivalTimes")
    assert Map.has_key?(payload, "speedAndDistance")
  end

  test "file name ends with json", %{exporter: exporter} do
    assert {:ok, content} = JSONExporter.export_async(exporter, Faker.valid_svd())
    assert String.ends_with?(content.file_name, ".json")
  end

  test "json round trip preserves key fields", %{exporter: exporter} do
    original = Faker.valid_svd()
    assert {:ok, content} = JSONExporter.export_async(exporter, original)
    assert {:ok, payload} = Jason.decode(content.data)

    assert get_in(payload, ["general", "imo"]) == original.general.imo
    assert get_in(payload, ["general", "shipName"]) == original.general.ship_name
    assert get_in(payload, ["general", "eventType"]) == original.general.event_type
  end

  test "json includes emissions section for dotnet/c++ parity", %{exporter: exporter} do
    assert {:ok, content} = JSONExporter.export_async(exporter, Faker.valid_svd())
    assert {:ok, payload} = Jason.decode(content.data)

    assert get_in(payload, ["emissions", "totalCo2"]) == Faker.valid_svd().emissions.total_co2
  end

  test "json uses dotnet acronym field names", %{exporter: exporter} do
    assert {:ok, content} = JSONExporter.export_async(exporter, Faker.valid_svd())
    assert {:ok, payload} = Jason.decode(content.data)

    assert Map.has_key?(payload["cargo"], "totalContainersTEU")
    assert Map.has_key?(payload["cargo"], "totalVehiclesCEU")
    assert Map.has_key?(payload["fuelAndBunker"], "fuelGHGIntensityIMOManual")
    assert Map.has_key?(payload["fuelAndBunker"], "fuelGHGIntensityIMOVoyage")
  end

  test "decode valid json payload" do
    payload = """
    {
      "general": {
        "eventType": "NOON",
        "imo": "1234567",
        "shipReportingDate": "2026-01-01T12:00:00.0000000Z"
      },
      "cargo": {
        "totalContainersTEU": 10
      }
    }
    """

    assert {:ok, dataset} = JSONExporter.decode(payload)
    assert dataset.general.event_type == "NOON"
    assert dataset.general.imo == "1234567"
    assert dataset.cargo.total_containers_teu == 10
  end

  test "decode invalid json payload" do
    assert {:error, _} = JSONExporter.decode("{invalid")
  end

  test "decode invalid non binary payload" do
    assert {:error, :invalid_json_payload} = JSONExporter.decode(:bad)
  end
end
