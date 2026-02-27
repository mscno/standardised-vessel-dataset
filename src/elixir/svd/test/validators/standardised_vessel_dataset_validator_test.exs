defmodule SVD.Validators.StandardisedVesselDatasetValidatorTest do
  use ExUnit.Case, async: true

  alias SVD.Models.StandardisedVesselDataset
  alias SVD.TestSupport.Faker
  alias SVD.Validators.StandardisedVesselDatasetValidator

  test "validate nil svd" do
    errors = StandardisedVesselDatasetValidator.validate(nil)

    assert length(errors) == 1
    assert Enum.any?(errors, &(&1.message == "SVD cannot be nil"))
  end

  test "validate svd without general" do
    errors = StandardisedVesselDatasetValidator.validate(%StandardisedVesselDataset{})

    assert Enum.any?(
             errors,
             &(&1.field == "General" and &1.message == "General information is required")
           )
  end

  test "validate valid svd" do
    assert StandardisedVesselDatasetValidator.validate(Faker.valid_svd()) == []
  end

  test "validate invalid svd" do
    errors = StandardisedVesselDatasetValidator.validate(Faker.invalid_svd())
    messages = Enum.map(errors, & &1.message)

    assert "EventType is required" in messages
    assert "OperationType is required" in messages
    assert "ShipName is required" in messages
    assert "IMO is required" in messages
  end

  test "validate minimal valid svd" do
    minimal = %StandardisedVesselDataset{general: Faker.valid_general_information()}
    assert StandardisedVesselDatasetValidator.validate(minimal) == []
  end

  test "validate unsupported payload falls back to nil error path" do
    errors = StandardisedVesselDatasetValidator.validate(:unsupported_payload)
    assert Enum.any?(errors, &(&1.message == "SVD cannot be nil"))
  end

  test "validate map payload by normalization" do
    payload = %{
      "general" => %{
        event_type: "NOON",
        operation_type: "SAILING",
        ship_name: "Ship",
        imo: "1234567",
        ship_reporting_date: DateTime.utc_now()
      }
    }

    assert StandardisedVesselDatasetValidator.validate(payload) == []
  end
end
