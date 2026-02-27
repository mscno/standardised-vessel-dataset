defmodule SVD.Exporters.Formats.JSONExporter do
  @moduledoc false

  alias SVD.Exporters.{BaseExporter, Helpers, StandardisedVesselDatasetContent}
  alias SVD.Serializers
  alias SVD.Validators.StandardisedVesselDatasetValidator

  defstruct validator: StandardisedVesselDatasetValidator

  @type t :: %__MODULE__{validator: module() | nil}

  @spec new(module() | nil) :: t()
  def new(validator_module), do: %__MODULE__{validator: validator_module}

  @spec export_async(t(), term(), term()) ::
          {:ok, StandardisedVesselDatasetContent.t()} | {:error, term()}
  def export_async(%__MODULE__{validator: validator_module}, svd, _ctx \\ nil) do
    BaseExporter.validate_and_export(validator_module, svd, fn dataset ->
      case Jason.encode(Serializers.to_json_map(dataset), pretty: true) do
        {:ok, json} ->
          {:ok,
           StandardisedVesselDatasetContent.new(
             json,
             Helpers.file_name(dataset, "json"),
             "application/json"
           )}

        {:error, error} ->
          {:error, error}
      end
    end)
  end

  @spec decode(binary()) :: {:ok, SVD.Models.StandardisedVesselDataset.t()} | {:error, term()}
  def decode(payload) when is_binary(payload) do
    with {:ok, json_payload} <- Jason.decode(payload),
         {:ok, dataset} <- Serializers.from_json_map(json_payload) do
      {:ok, dataset}
    end
  end

  def decode(_), do: {:error, :invalid_json_payload}
end
