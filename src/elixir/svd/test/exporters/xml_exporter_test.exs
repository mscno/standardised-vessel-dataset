defmodule SVD.Exporters.XMLExporterTest do
  use ExUnit.Case, async: true

  alias SVD.Exporters.Formats.XMLExporter
  alias SVD.Models.StandardisedVesselDataset
  alias SVD.TestSupport.Faker
  alias SVD.Validators.{StandardisedVesselDatasetValidator, ValidatorException}

  setup do
    %{exporter: XMLExporter.new(StandardisedVesselDatasetValidator)}
  end

  test "default struct can be created" do
    exporter = struct(XMLExporter)
    assert exporter.validator == StandardisedVesselDatasetValidator
  end

  test "export nil svd", %{exporter: exporter} do
    assert {:error, "SVD cannot be nil"} = XMLExporter.export_async(exporter, nil)
  end

  test "export invalid svd", %{exporter: exporter} do
    assert {:error, %ValidatorException{} = exception} =
             XMLExporter.export_async(exporter, Faker.invalid_svd())

    assert ValidatorException.has_errors?(exception)
  end

  test "export valid svd", %{exporter: exporter} do
    assert {:ok, content} = XMLExporter.export_async(exporter, Faker.valid_svd())

    assert byte_size(content.data) > 0
    assert String.contains?(content.file_name, Faker.valid_svd().general.imo)
    assert content.content_type == "application/xml"
  end

  test "export minimal valid data", %{exporter: exporter} do
    minimal = %StandardisedVesselDataset{general: Faker.valid_general_information()}
    assert {:ok, content} = XMLExporter.export_async(exporter, minimal)
    assert byte_size(content.data) > 0
  end

  test "valid xml format", %{exporter: exporter} do
    assert {:ok, content} = XMLExporter.export_async(exporter, Faker.valid_svd())

    xml_chars = String.to_charlist(content.data)

    assert {{:xmlElement, :StandardisedVesselDataset, _, _, _, _, _, _, _, _, _, _}, _} =
             :xmerl_scan.string(xml_chars)
  end

  test "file name ends with xml", %{exporter: exporter} do
    assert {:ok, content} = XMLExporter.export_async(exporter, Faker.valid_svd())
    assert String.ends_with?(content.file_name, ".xml")
  end

  test "xml declaration present", %{exporter: exporter} do
    assert {:ok, content} = XMLExporter.export_async(exporter, Faker.valid_svd())

    assert String.starts_with?(content.data, "<?xml")
    assert String.contains?(content.data, ~s(version="1.0"))
    assert String.contains?(content.data, ~s(encoding="UTF-8"))
  end

  test "xml contains key general fields", %{exporter: exporter} do
    valid = Faker.valid_svd()
    assert {:ok, content} = XMLExporter.export_async(exporter, valid)

    assert String.contains?(content.data, "<Imo>#{valid.general.imo}</Imo>")
    assert String.contains?(content.data, "<ShipName>#{valid.general.ship_name}</ShipName>")
    assert String.contains?(content.data, "<EventType>#{valid.general.event_type}</EventType>")
  end

  test "xml includes emissions section for dotnet/c++ parity", %{exporter: exporter} do
    assert {:ok, content} = XMLExporter.export_async(exporter, Faker.valid_svd())
    assert String.contains?(content.data, "<Emissions>")
    assert String.contains?(content.data, "<TotalCo2>")
  end

  test "xml renders empty section tags when section has no values", %{exporter: exporter} do
    svd = %StandardisedVesselDataset{
      general: Faker.valid_general_information(),
      port_and_route: %SVD.Models.PortInformation{}
    }

    assert {:ok, content} = XMLExporter.export_async(exporter, svd)
    assert String.contains?(content.data, "<PortAndRoute></PortAndRoute>")
  end

  test "decode valid xml payload" do
    payload = """
    <?xml version="1.0" encoding="UTF-8"?>
    <StandardisedVesselDataset>
      <General>
        <EventType>NOON</EventType>
        <Imo>1234567</Imo>
        <ShipReportingDate>2026-01-01T12:00:00.0000000Z</ShipReportingDate>
      </General>
      <Cargo>
        <TotalContainersTEU>10</TotalContainersTEU>
      </Cargo>
    </StandardisedVesselDataset>
    """

    assert {:ok, dataset} = XMLExporter.decode(payload)
    assert dataset.general.event_type == "NOON"
    assert dataset.general.imo == "1234567"
    assert dataset.cargo.total_containers_teu == 10
  end

  test "decode invalid xml payload" do
    assert {:error, _} = XMLExporter.decode("<bad>")
  end

  test "decode invalid xml root" do
    assert {:error, :invalid_xml_root} = XMLExporter.decode("<Root></Root>")
  end

  test "decode invalid non binary payload" do
    assert {:error, :invalid_xml_payload} = XMLExporter.decode(:bad)
  end

  test "xml escaping encodes reserved characters", %{exporter: exporter} do
    svd = Faker.valid_svd()
    escaped = %{svd | general: %{svd.general | operation_description: ~s(A&B<>"')}}

    assert {:ok, content} = XMLExporter.export_async(exporter, escaped)
    assert String.contains?(content.data, "&amp;")
    assert String.contains?(content.data, "&lt;")
    assert String.contains?(content.data, "&gt;")
    assert String.contains?(content.data, "&quot;")
    assert String.contains?(content.data, "&apos;")
  end

  test "decode ignores nested non-text children in value nodes" do
    payload = """
    <?xml version="1.0" encoding="UTF-8"?>
    <StandardisedVesselDataset>
      <General>
        <EventType><Inner /></EventType>
        <Imo>1234567</Imo>
      </General>
    </StandardisedVesselDataset>
    """

    assert {:ok, dataset} = XMLExporter.decode(payload)
    assert dataset.general.event_type == nil
    assert dataset.general.imo == "1234567"
  end
end
