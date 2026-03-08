defmodule SVD.Validators.GeneralInformationValidatorTest do
  use ExUnit.Case, async: true

  alias SVD.TestSupport.Faker
  alias SVD.Validators.GeneralInformationValidator

  test "validate nil general information" do
    errors = GeneralInformationValidator.validate(nil)

    assert length(errors) == 1
    assert hd(errors).field == "General"
    assert hd(errors).message == "General is required"
  end

  test "validate unsupported general type" do
    errors = GeneralInformationValidator.validate(:invalid)
    assert length(errors) == 1
    assert hd(errors).message == "General is required"
  end

  test "validate valid general information" do
    errors = Faker.valid_general_information() |> GeneralInformationValidator.validate()
    assert errors == []
  end

  test "validate required fields" do
    general = %{
      Faker.valid_general_information()
      | imo: "",
        ship_name: "",
        ship_reporting_date: nil
    }

    errors = GeneralInformationValidator.validate(general)
    messages = Enum.map(errors, &{&1.field, &1.message})

    assert {"General.Imo", "Imo is required"} in messages
    assert {"General.ShipName", "Ship Name is required"} in messages

    assert {"General.ShipReportingDate",
            "Ship Reporting Date (Datetime) must be greater than default."} in messages
  end

  test "validate imo must be seven digits" do
    invalid_imos = ["12345", "12345678", "12A4567"]

    for imo <- invalid_imos do
      errors =
        Faker.valid_general_information()
        |> Map.put(:imo, imo)
        |> GeneralInformationValidator.validate()

      assert Enum.any?(
               errors,
               &(&1.field == "General.Imo" and &1.message == "Imo must be seven digits.")
             )
    end

    errors =
      Faker.valid_general_information()
      |> Map.put(:imo, "1234567")
      |> GeneralInformationValidator.validate()

    refute Enum.any?(errors, &(&1.field == "General.Imo"))
  end

  test "validate ship reporting date accepts ISO8601 string and datetime" do
    dt_errors =
      Faker.valid_general_information()
      |> Map.put(:ship_reporting_date, DateTime.utc_now())
      |> GeneralInformationValidator.validate()

    assert dt_errors == []

    string_errors =
      Faker.valid_general_information()
      |> Map.put(:ship_reporting_date, "2025-01-02T15:04:05Z")
      |> GeneralInformationValidator.validate()

    assert string_errors == []
  end

  test "validate ship reporting date must be greater than default and parseable" do
    default_date_errors =
      Faker.valid_general_information()
      |> Map.put(:ship_reporting_date, "0001-01-01T00:00:00Z")
      |> GeneralInformationValidator.validate()

    assert Enum.any?(
             default_date_errors,
             &(&1.field == "General.ShipReportingDate" and
                 &1.message == "Ship Reporting Date (Datetime) must be greater than default.")
           )

    bad_format_errors =
      Faker.valid_general_information()
      |> Map.put(:ship_reporting_date, "not-a-date")
      |> GeneralInformationValidator.validate()

    assert Enum.any?(
             bad_format_errors,
             &(&1.field == "General.ShipReportingDate" and
                 &1.message == "Ship Reporting Date (Datetime) must be greater than default.")
           )
  end
end
