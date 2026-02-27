defmodule SVD.Models.CylinderLubeOilInformation do
  @moduledoc false

  @fields [
    :main_engine_cylinder_oil_consumption,
    :main_engine_cylinder_oil_type,
    :main_engine_cylinder_oil_rob,
    :main_engine_system_oil_consumption,
    :main_engine_system_oil_type,
    :main_engine_system_oil_rob,
    :auxiliary_engine_lube_oil_consumption,
    :auxiliary_engine_lube_oil_type,
    :auxiliary_engine_lube_oil_rob,
    :total_lube_oil_bunkered,
    :remaining_on_board,
    :feed_rate,
    :consumption,
    :received_during_bunkering
  ]

  @derive {Jason.Encoder, only: @fields}
  defstruct @fields

  @type t :: %__MODULE__{}

  @spec fields() :: [atom()]
  def fields, do: @fields
end
