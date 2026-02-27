defmodule SVD.Exporters.BaseExporterTest do
  use ExUnit.Case, async: true

  alias SVD.Exporters.BaseExporter
  alias SVD.Models.StandardisedVesselDataset

  defmodule AlwaysInvalidValidator do
    alias SVD.Validators.ValidationError

    def validate(_), do: [%ValidationError{field: "x", message: "y"}]
  end

  test "validate and export with nil svd" do
    assert {:error, "SVD cannot be nil"} =
             BaseExporter.validate_and_export(nil, nil, fn _ -> :ok end)
  end

  test "validate and export with invalid normalized dataset" do
    assert {:error, "SVD cannot be nil"} =
             BaseExporter.validate_and_export(nil, :invalid, fn _ -> :ok end)
  end

  test "validate and export with nil validator" do
    dataset = %StandardisedVesselDataset{}

    assert {:ok, :exported} =
             BaseExporter.validate_and_export(nil, dataset, fn _ ->
               {:ok, :exported}
             end)
  end

  test "validate and export with validation errors" do
    dataset = %StandardisedVesselDataset{}

    assert {:error, %SVD.Validators.ValidatorException{}} =
             BaseExporter.validate_and_export(AlwaysInvalidValidator, dataset, fn _ ->
               {:ok, :exported}
             end)
  end
end
