defmodule SVD.Models.FreshWater do
  @moduledoc false

  @fields [
    :fresh_water_produced,
    :fresh_water_consumed,
    :fresh_water_received,
    :fresh_water_discharged,
    :fresh_water_rob,
    :fresh_water_bunkered,
    :technical_water_produced,
    :technical_water_consumed,
    :wash_water_consumed,
    :fresh_water_remaining
  ]

  @derive {Jason.Encoder, only: @fields}
  defstruct @fields

  @type t :: %__MODULE__{}

  @spec fields() :: [atom()]
  def fields, do: @fields
end
