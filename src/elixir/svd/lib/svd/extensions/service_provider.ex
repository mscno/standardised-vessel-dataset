defmodule SVD.Extensions.ServiceProvider do
  @moduledoc false

  alias SVD.Exporters.Formats.{CSVExporter, JSONExporter, XMLExporter}
  alias SVD.Validators.StandardisedVesselDatasetValidator

  @enforce_keys [:validator, :json_exporter, :csv_exporter, :xml_exporter]
  defstruct [:validator, :json_exporter, :csv_exporter, :xml_exporter]

  @type t :: %__MODULE__{}

  @spec new() :: t()
  def new do
    new_with_custom_validator(StandardisedVesselDatasetValidator)
  end

  @spec new_with_custom_validator(module()) :: t()
  def new_with_custom_validator(validator_module) when is_atom(validator_module) do
    %__MODULE__{
      validator: validator_module,
      json_exporter: JSONExporter.new(validator_module),
      csv_exporter: CSVExporter.new(validator_module),
      xml_exporter: XMLExporter.new(validator_module)
    }
  end

  @spec get_validator(t()) :: module()
  def get_validator(%__MODULE__{validator: validator}), do: validator

  @spec get_json_exporter(t()) :: JSONExporter.t()
  def get_json_exporter(%__MODULE__{json_exporter: exporter}), do: exporter

  @spec get_csv_exporter(t()) :: CSVExporter.t()
  def get_csv_exporter(%__MODULE__{csv_exporter: exporter}), do: exporter

  @spec get_xml_exporter(t()) :: XMLExporter.t()
  def get_xml_exporter(%__MODULE__{xml_exporter: exporter}), do: exporter

  @spec set_validator(t(), module()) :: t()
  def set_validator(%__MODULE__{} = provider, validator_module) when is_atom(validator_module) do
    %{
      provider
      | validator: validator_module,
        json_exporter: JSONExporter.new(validator_module),
        csv_exporter: CSVExporter.new(validator_module),
        xml_exporter: XMLExporter.new(validator_module)
    }
  end

  @spec set_json_exporter(t(), JSONExporter.t()) :: t()
  def set_json_exporter(%__MODULE__{} = provider, exporter),
    do: %{provider | json_exporter: exporter}

  @spec set_csv_exporter(t(), CSVExporter.t()) :: t()
  def set_csv_exporter(%__MODULE__{} = provider, exporter),
    do: %{provider | csv_exporter: exporter}

  @spec set_xml_exporter(t(), XMLExporter.t()) :: t()
  def set_xml_exporter(%__MODULE__{} = provider, exporter),
    do: %{provider | xml_exporter: exporter}
end
