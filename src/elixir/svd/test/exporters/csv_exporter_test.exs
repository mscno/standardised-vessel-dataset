defmodule SVD.Exporters.CSVExporterTest do
  use ExUnit.Case, async: true

  alias SVD.Exporters.Formats.CSVExporter
  alias SVD.Models.StandardisedVesselDataset
  alias SVD.TestSupport.Faker
  alias SVD.Validators.{StandardisedVesselDatasetValidator, ValidatorException}

  setup do
    %{exporter: CSVExporter.new(StandardisedVesselDatasetValidator)}
  end

  test "default struct can be created" do
    exporter = struct(CSVExporter)
    assert exporter.validator == StandardisedVesselDatasetValidator
  end

  test "export nil svd", %{exporter: exporter} do
    assert {:error, "SVD cannot be nil"} = CSVExporter.export_async(exporter, nil)
  end

  test "export invalid svd", %{exporter: exporter} do
    assert {:error, %ValidatorException{} = exception} =
             CSVExporter.export_async(exporter, Faker.invalid_svd())

    assert ValidatorException.has_errors?(exception)
  end

  test "export valid svd", %{exporter: exporter} do
    assert {:ok, content} = CSVExporter.export_async(exporter, Faker.valid_svd())

    assert byte_size(content.data) > 0
    assert String.contains?(content.file_name, Faker.valid_svd().general.imo)
    assert content.content_type == "text/csv"
  end

  test "export minimal valid data", %{exporter: exporter} do
    minimal = %StandardisedVesselDataset{general: Faker.valid_general_information()}
    assert {:ok, content} = CSVExporter.export_async(exporter, minimal)
    assert byte_size(content.data) > 0
  end

  test "valid csv format", %{exporter: exporter} do
    assert {:ok, content} = CSVExporter.export_async(exporter, Faker.valid_svd())

    lines = content.data |> String.trim() |> String.split("\n")
    assert length(lines) >= 2

    [header_line, data_line | _] = lines
    headers = parse_csv_row(header_line)
    values = parse_csv_row(data_line)

    assert length(headers) == length(values)
  end

  test "file name ends with csv", %{exporter: exporter} do
    assert {:ok, content} = CSVExporter.export_async(exporter, Faker.valid_svd())
    assert String.ends_with?(content.file_name, ".csv")
  end

  test "csv contains expected headers", %{exporter: exporter} do
    assert {:ok, content} = CSVExporter.export_async(exporter, Faker.valid_svd())

    [header_line, data_line | _] = content.data |> String.trim() |> String.split("\n")
    headers = parse_csv_row(header_line)
    values = parse_csv_row(data_line)

    assert "General.EventType" in headers
    assert "General.OperationType" in headers
    assert "General.ShipName" in headers
    assert "General.Imo" in headers

    assert Enum.any?(values, &(&1 != ""))
  end

  test "csv includes emissions columns for dotnet/c++ parity", %{exporter: exporter} do
    assert {:ok, content} = CSVExporter.export_async(exporter, Faker.valid_svd())

    [header_line | _] = content.data |> String.trim() |> String.split("\n")
    headers = parse_csv_row(header_line)

    assert "Emissions.TotalCo2" in headers
  end

  test "csv uses dotnet acronym field names", %{exporter: exporter} do
    assert {:ok, content} = CSVExporter.export_async(exporter, Faker.valid_svd())

    [header_line | _] = content.data |> String.trim() |> String.split("\n")
    headers = parse_csv_row(header_line)

    assert "Cargo.TotalContainersTEU" in headers
    assert "Cargo.TotalVehiclesCEU" in headers
    assert "FuelAndBunker.FuelGHGIntensityIMOManual" in headers
    assert "FuelAndBunker.FuelGHGIntensityIMOVoyage" in headers
  end

  test "decode valid csv payload" do
    payload = """
    General.EventType,General.Imo,General.ShipReportingDate,Cargo.TotalContainersTEU
    NOON,1234567,2026-01-01T12:00:00.0000000Z,10
    """

    assert {:ok, dataset} = CSVExporter.decode(payload)
    assert dataset.general.event_type == "NOON"
    assert dataset.general.imo == "1234567"
    assert dataset.cargo.total_containers_teu == 10
  end

  test "decode invalid csv payload" do
    assert {:error, :invalid_csv_payload} = CSVExporter.decode("header-only")
  end

  test "decode invalid non-binary payload" do
    assert {:error, :invalid_csv_payload} = CSVExporter.decode(:bad)
  end

  test "decode handles quoted values with commas and escaped quotes" do
    payload = """
    General.EventType,General.OperationDescription,General.Imo
    NOON,"Heavy weather, rerouted ""north\""",1234567
    """

    assert {:ok, dataset} = CSVExporter.decode(payload)
    assert dataset.general.operation_description == ~s(Heavy weather, rerouted "north")
    assert dataset.general.imo == "1234567"
  end

  test "decode supports CRLF and CR line endings" do
    crlf = "General.EventType,General.Imo\r\nNOON,1234567\r\n"
    assert {:ok, dataset_crlf} = CSVExporter.decode(crlf)
    assert dataset_crlf.general.event_type == "NOON"

    cr = "General.EventType,General.Imo\rNOON,1234567\r"
    assert {:ok, dataset_cr} = CSVExporter.decode(cr)
    assert dataset_cr.general.event_type == "NOON"
  end

  test "decode rejects unterminated quoted field" do
    payload = "General.EventType\n\"NOON"
    assert {:error, :invalid_csv_payload} = CSVExporter.decode(payload)
  end

  defp parse_csv_row(row) do
    do_parse(String.to_charlist(row), [], [], false)
    |> Enum.map(&to_string/1)
  end

  defp do_parse([], current, acc, _quoted) do
    Enum.reverse([Enum.reverse(current) | acc])
  end

  defp do_parse([?" | rest], current, acc, false), do: do_parse(rest, current, acc, true)
  defp do_parse([?" | rest], current, acc, true), do: do_parse(rest, current, acc, false)

  defp do_parse([?, | rest], current, acc, false) do
    do_parse(rest, [], [Enum.reverse(current) | acc], false)
  end

  defp do_parse([char | rest], current, acc, quoted) do
    do_parse(rest, [char | current], acc, quoted)
  end
end
