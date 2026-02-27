defmodule SVD.Extensions.ServiceProviderTest do
  use ExUnit.Case, async: true

  alias SVD.Extensions.ServiceProvider
  alias SVD.TestSupport.Faker
  alias SVD.Validators.StandardisedVesselDatasetValidator

  defmodule CustomValidator do
    def validate(_), do: []
  end

  test "new service provider" do
    provider = ServiceProvider.new()

    assert provider != nil
    assert ServiceProvider.get_validator(provider) != nil
    assert ServiceProvider.get_json_exporter(provider) != nil
    assert ServiceProvider.get_csv_exporter(provider) != nil
    assert ServiceProvider.get_xml_exporter(provider) != nil
  end

  test "new service provider with custom validator" do
    provider = ServiceProvider.new_with_custom_validator(CustomValidator)

    assert provider != nil
    assert ServiceProvider.get_validator(provider) == CustomValidator
  end

  test "set validator" do
    provider = ServiceProvider.new()
    original = ServiceProvider.get_validator(provider)

    updated = ServiceProvider.set_validator(provider, CustomValidator)

    assert original != ServiceProvider.get_validator(updated)
    assert ServiceProvider.get_validator(updated) == CustomValidator
  end

  test "set specific exporters" do
    provider = ServiceProvider.new()

    json = SVD.Exporters.Formats.JSONExporter.new(CustomValidator)
    csv = SVD.Exporters.Formats.CSVExporter.new(CustomValidator)
    xml = SVD.Exporters.Formats.XMLExporter.new(CustomValidator)

    provider =
      provider
      |> ServiceProvider.set_json_exporter(json)
      |> ServiceProvider.set_csv_exporter(csv)
      |> ServiceProvider.set_xml_exporter(xml)

    assert ServiceProvider.get_json_exporter(provider) == json
    assert ServiceProvider.get_csv_exporter(provider) == csv
    assert ServiceProvider.get_xml_exporter(provider) == xml
  end

  test "export with json exporter" do
    provider = ServiceProvider.new()
    exporter = ServiceProvider.get_json_exporter(provider)

    assert {:ok, result} =
             SVD.Exporters.Formats.JSONExporter.export_async(exporter, Faker.valid_svd())

    assert byte_size(result.data) > 0
  end

  test "export with csv exporter" do
    provider = ServiceProvider.new()
    exporter = ServiceProvider.get_csv_exporter(provider)

    assert {:ok, result} =
             SVD.Exporters.Formats.CSVExporter.export_async(exporter, Faker.valid_svd())

    assert byte_size(result.data) > 0
  end

  test "export with xml exporter" do
    provider = ServiceProvider.new()
    exporter = ServiceProvider.get_xml_exporter(provider)

    assert {:ok, result} =
             SVD.Exporters.Formats.XMLExporter.export_async(exporter, Faker.valid_svd())

    assert byte_size(result.data) > 0
  end

  test "validate with validator" do
    provider = ServiceProvider.new()
    validator = ServiceProvider.get_validator(provider)

    assert validator.validate(Faker.valid_svd()) == []
    assert validator.validate(Faker.invalid_svd()) != []
  end

  test "all exporters use provided validator" do
    provider = ServiceProvider.new_with_custom_validator(StandardisedVesselDatasetValidator)
    invalid = Faker.invalid_svd()

    assert {:error, _} =
             provider
             |> ServiceProvider.get_json_exporter()
             |> SVD.Exporters.Formats.JSONExporter.export_async(invalid)

    assert {:error, _} =
             provider
             |> ServiceProvider.get_csv_exporter()
             |> SVD.Exporters.Formats.CSVExporter.export_async(invalid)

    assert {:error, _} =
             provider
             |> ServiceProvider.get_xml_exporter()
             |> SVD.Exporters.Formats.XMLExporter.export_async(invalid)
  end
end
