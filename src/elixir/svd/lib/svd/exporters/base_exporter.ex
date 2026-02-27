defmodule SVD.Exporters.BaseExporter do
  @moduledoc false

  alias SVD.Models
  alias SVD.Validators.ValidatorException

  @spec validate_and_export(
          module() | nil,
          term(),
          (struct() -> {:ok, term()} | {:error, term()})
        ) ::
          {:ok, term()} | {:error, term()}
  def validate_and_export(_validator_module, nil, _export_fun), do: {:error, "SVD cannot be nil"}

  def validate_and_export(validator_module, svd, export_fun) do
    case Models.normalize_dataset(svd) do
      nil ->
        {:error, "SVD cannot be nil"}

      dataset ->
        errors =
          if is_nil(validator_module) do
            []
          else
            validator_module.validate(dataset)
          end

        if errors == [] do
          export_fun.(dataset)
        else
          {:error, %ValidatorException{errors: errors}}
        end
    end
  end
end
