defmodule SVD.Models.Emissions do
  @moduledoc false

  @fields [
    :total_co2,
    :total_co2_percentage,
    :total_co2_tank_to_wake,
    :total_co2_captured,
    :total_ch4,
    :total_ch4_converted_to_co2,
    :total_n2o,
    :total_n2o_converted_to_co2,
    :ch4_emission_conversion_factor,
    :n2o_emission_conversion_factor
  ]

  @derive {Jason.Encoder, only: @fields}
  defstruct @fields

  @type t :: %__MODULE__{}

  @spec fields() :: [atom()]
  def fields, do: @fields
end
