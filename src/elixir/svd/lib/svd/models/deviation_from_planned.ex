defmodule SVD.Models.DeviationFromPlanned do
  @moduledoc false

  @fields [
    :deviation_reason,
    :deviation_description,
    :deviation_distance,
    :deviation_time,
    :reason,
    :latitude,
    :longitude,
    :ship_deviation_started_time,
    :ship_deviation_stopped_time
  ]

  @derive {Jason.Encoder, only: @fields}
  defstruct @fields

  @type t :: %__MODULE__{}

  @spec fields() :: [atom()]
  def fields, do: @fields
end
