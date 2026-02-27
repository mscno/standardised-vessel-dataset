defmodule SVD.Exporters.StandardisedVesselDatasetContent do
  @moduledoc false

  @enforce_keys [:data, :file_name, :content_type]
  defstruct [:data, :file_name, :content_type]

  @type t :: %__MODULE__{
          data: binary(),
          file_name: String.t(),
          content_type: String.t()
        }

  @spec new(binary(), String.t(), String.t()) :: t()
  def new(data, file_name, content_type) do
    %__MODULE__{
      data: data,
      file_name: file_name,
      content_type: content_type
    }
  end
end
