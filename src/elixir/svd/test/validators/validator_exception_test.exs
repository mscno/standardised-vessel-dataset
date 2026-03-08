defmodule SVD.Validators.ValidatorExceptionTest do
  use ExUnit.Case, async: true

  alias SVD.Validators.{ValidationError, ValidatorException}

  test "empty exception message" do
    exception = %ValidatorException{errors: []}
    assert Exception.message(exception) == "validation failed"
    refute ValidatorException.has_errors?(exception)
  end

  test "formatted exception message" do
    exception =
      %ValidatorException{
        errors: [
          %ValidationError{field: "General.Imo", message: "Imo is required"},
          %ValidationError{field: "General.ShipName", message: "Ship Name is required"}
        ]
      }

    message = Exception.message(exception)
    assert String.contains?(message, "General.Imo: Imo is required")
    assert String.contains?(message, "General.ShipName: Ship Name is required")
    assert ValidatorException.has_errors?(exception)
  end
end
