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

    assert Enum.any?(headers, &String.contains?(&1, "general.event_type"))
    assert Enum.any?(headers, &String.contains?(&1, "general.operation_type"))
    assert Enum.any?(headers, &String.contains?(&1, "general.ship_name"))
    assert Enum.any?(headers, &String.contains?(&1, "general.imo"))

    assert Enum.any?(values, &(&1 != ""))
  end

  test "csv includes emissions columns for dotnet/c++ parity", %{exporter: exporter} do
    assert {:ok, content} = CSVExporter.export_async(exporter, Faker.valid_svd())

    [header_line | _] = content.data |> String.trim() |> String.split("\n")
    headers = parse_csv_row(header_line)

    assert "emissions.total_co2" in headers
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
