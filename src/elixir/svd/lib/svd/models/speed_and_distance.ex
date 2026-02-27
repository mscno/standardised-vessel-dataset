defmodule SVD.Models.SpeedAndDistance do
  @moduledoc false

  @fields [
    :distance_through_water,
    :distance_over_ground,
    :distance_sailed_in_ice,
    :distance_to_next_port,
    :distance_to_next_waypoint,
    :total_distance_on_sea_passage,
    :distance_excluded,
    :speed_over_ground,
    :speed_through_water,
    :speed_propeller,
    :speed_projected,
    :speed_order,
    :slip_ratio,
    :slip,
    :speed_stopping,
    :course_over_ground,
    :ship_true_heading,
    :ship_draught,
    :draught_forward,
    :draught_aft,
    :ship_actual_deadweight_tonnage,
    :ship_maximum_deadweight,
    :laden_indicator,
    :total_ballast_water_onboard
  ]

  @derive {Jason.Encoder, only: @fields}
  defstruct @fields

  @type t :: %__MODULE__{}

  @spec fields() :: [atom()]
  def fields, do: @fields
end
