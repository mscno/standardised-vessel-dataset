defmodule SVD.Validators.ValidationError do
  @moduledoc false

  @enforce_keys [:field, :message]
  defstruct [:field, :message, :value]

  @type t :: %__MODULE__{
          field: String.t(),
          message: String.t(),
          value: term()
        }
end
