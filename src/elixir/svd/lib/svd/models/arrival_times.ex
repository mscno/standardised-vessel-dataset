defmodule SVD.Models.ArrivalTimes do
  @moduledoc false

  @fields [
    :estimated_time_of_arrival,
    :estimated_time_of_completion,
    :estimated_time_of_pilot_boarding,
    :estimated_time_of_berth,
    :arrival,
    :departure,
    :location_eta,
    :location_actual,
    :pilot_boarding_place_eta,
    :pilot_boarding_place_actual,
    :vts_eta,
    :vts_actual,
    :next_port_eta,
    :voyage_time
  ]

  @derive {Jason.Encoder, only: @fields}
  defstruct @fields

  @type t :: %__MODULE__{}

  @spec fields() :: [atom()]
  def fields, do: @fields
end
