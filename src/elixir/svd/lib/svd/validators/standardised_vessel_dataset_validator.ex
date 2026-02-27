defmodule SVD.Validators.StandardisedVesselDatasetValidator do
  @moduledoc false

  alias SVD.Models
  alias SVD.Validators.{GeneralInformationValidator, ValidationError}

  @spec validate(term()) :: [ValidationError.t()]
  def validate(nil) do
    [
      %ValidationError{field: "SVD", message: "SVD cannot be nil"}
    ]
  end

  def validate(dataset) do
    case Models.normalize_dataset(dataset) do
      nil ->
        validate(nil)

      normalized ->
        errors = []

        if is_nil(normalized.general) do
          errors ++
            [
              %ValidationError{
                field: "General",
                message: "General information is required"
              }
            ]
        else
          errors ++ GeneralInformationValidator.validate(normalized.general)
        end
    end
  end
end
