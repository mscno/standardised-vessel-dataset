defmodule SVD.Validators.ValidatorException do
  @moduledoc false

  alias SVD.Validators.ValidationError

  defexception [:errors]

  @type t :: %__MODULE__{errors: [ValidationError.t()]}

  @impl true
  def message(%__MODULE__{errors: []}), do: "validation failed"

  def message(%__MODULE__{errors: errors}) do
    formatted =
      errors
      |> Enum.map_join("; ", fn %ValidationError{field: field, message: message} ->
        "#{field}: #{message}"
      end)

    "validation failed: #{formatted}"
  end

  @spec has_errors?(t()) :: boolean()
  def has_errors?(%__MODULE__{errors: errors}), do: errors != []
end
