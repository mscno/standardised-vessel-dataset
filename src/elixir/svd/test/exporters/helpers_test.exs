defmodule SVD.Exporters.HelpersTest do
  use ExUnit.Case, async: true

  alias SVD.Exporters.Helpers
  alias SVD.Models.{GeneralInformation, StandardisedVesselDataset}

  test "filename with general info" do
    date = ~U[2026-02-01 00:00:00Z]

    dataset = %StandardisedVesselDataset{
      general: %GeneralInformation{imo: "1234567", ship_reporting_date: date}
    }

    assert Helpers.file_name(dataset, "json") == "SVD_1234567_2026-02-01.json"
  end

  test "filename without general info" do
    dataset = %StandardisedVesselDataset{}
    assert String.ends_with?(Helpers.file_name(dataset, "xml"), ".xml")
    assert String.starts_with?(Helpers.file_name(dataset, "xml"), "SVD__")
  end
end
