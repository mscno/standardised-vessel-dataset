defmodule SVD.Validators.GeneralInformationValidatorTest do
  use ExUnit.Case, async: true

  alias SVD.TestSupport.Faker
  alias SVD.Validators.GeneralInformationValidator

  test "validate nil general information" do
    errors = GeneralInformationValidator.validate(nil)

    assert length(errors) == 1
    assert hd(errors).message == "General information cannot be nil"
  end

  test "validate unsupported general type" do
    errors = GeneralInformationValidator.validate(:invalid)
    assert length(errors) == 1
    assert hd(errors).message == "General information cannot be nil"
  end

  test "validate valid general information" do
    errors = Faker.valid_general_information() |> GeneralInformationValidator.validate()
    assert errors == []
  end

  test "validate required fields" do
    general = %{
      Faker.valid_general_information()
      | event_type: "",
        operation_type: "",
        ship_name: ""
    }

    errors = GeneralInformationValidator.validate(general)
    messages = Enum.map(errors, &{&1.field, &1.message})

    assert {"General.EventType", "EventType is required"} in messages
    assert {"General.OperationType", "OperationType is required"} in messages
    assert {"General.ShipName", "ShipName is required"} in messages
  end

  test "validate imo variations" do
    invalid_imos = ["", "12345", "12345678", "ABC1234"]

    for imo <- invalid_imos do
      errors =
        Faker.valid_general_information()
        |> Map.put(:imo, imo)
        |> GeneralInformationValidator.validate()

      assert Enum.any?(errors, &(&1.field == "General.IMO"))
    end

    errors =
      Faker.valid_general_information()
      |> Map.put(:imo, "1234567")
      |> GeneralInformationValidator.validate()

    refute Enum.any?(errors, &(&1.field == "General.IMO"))
  end

  test "validate ship latitude boundaries" do
    valid_values = [-90.0, 0.0, 90.0]
    invalid_values = [-90.01, 90.01]

    for value <- valid_values do
      errors =
        Faker.valid_general_information()
        |> Map.put(:ship_latitude, value)
        |> GeneralInformationValidator.validate()

      refute Enum.any?(errors, &(&1.field == "General.ShipLatitude"))
    end

    for value <- invalid_values do
      errors =
        Faker.valid_general_information()
        |> Map.put(:ship_latitude, value)
        |> GeneralInformationValidator.validate()

      assert Enum.any?(
               errors,
               &(&1.field == "General.ShipLatitude" and
                   &1.message == "ShipLatitude must be between -90 and 90")
             )
    end
  end

  test "validate ship longitude boundaries" do
    valid_values = [-180.0, 0.0, 180.0]
    invalid_values = [-180.01, 180.01]

    for value <- valid_values do
      errors =
        Faker.valid_general_information()
        |> Map.put(:ship_longitude, value)
        |> GeneralInformationValidator.validate()

      refute Enum.any?(errors, &(&1.field == "General.ShipLongitude"))
    end

    for value <- invalid_values do
      errors =
        Faker.valid_general_information()
        |> Map.put(:ship_longitude, value)
        |> GeneralInformationValidator.validate()

      assert Enum.any?(
               errors,
               &(&1.field == "General.ShipLongitude" and
                   &1.message == "ShipLongitude must be between -180 and 180")
             )
    end
  end

  test "validate reporting date" do
    zero_date_errors =
      Faker.valid_general_information()
      |> Map.put(:ship_reporting_date, nil)
      |> GeneralInformationValidator.validate()

    assert Enum.any?(
             zero_date_errors,
             &(&1.field == "General.ShipReportingDate" and
                 &1.message == "ShipReportingDate is required")
           )

    future_date = DateTime.add(DateTime.utc_now(), 48 * 60 * 60, :second)

    future_errors =
      Faker.valid_general_information()
      |> Map.put(:ship_reporting_date, future_date)
      |> GeneralInformationValidator.validate()

    assert Enum.any?(
             future_errors,
             &(&1.field == "General.ShipReportingDate" and
                 &1.message == "ShipReportingDate cannot be in the future")
           )
  end

  test "validate negative crew" do
    errors =
      Faker.valid_general_information()
      |> Map.put(:number_of_crew, -5)
      |> GeneralInformationValidator.validate()

    assert Enum.any?(
             errors,
             &(&1.field == "General.NumberOfCrew" and
                 &1.message == "NumberOfCrew cannot be negative")
           )
  end

  test "validate ignores unsupported types for optional numeric fields" do
    errors =
      Faker.valid_general_information()
      |> Map.put(:ship_latitude, "not-a-number")
      |> Map.put(:ship_longitude, "not-a-number")
      |> Map.put(:ship_reporting_date, "not-a-date")
      |> Map.put(:number_of_crew, "not-an-int")
      |> GeneralInformationValidator.validate()

    refute Enum.any?(errors, &(&1.field == "General.ShipLatitude"))
    refute Enum.any?(errors, &(&1.field == "General.ShipLongitude"))
    refute Enum.any?(errors, &(&1.field == "General.ShipReportingDate"))
    refute Enum.any?(errors, &(&1.field == "General.NumberOfCrew"))
  end
end
