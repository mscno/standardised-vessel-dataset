defmodule SVD.Models.WeatherInformation do
  @moduledoc false

  @fields [
    :wind_speed,
    :wind_direction,
    :wind_force,
    :wave_height,
    :wave_direction,
    :swell_height,
    :swell_direction,
    :sea_state,
    :air_temperature,
    :water_temperature,
    :atmospheric_pressure,
    :visibility,
    :current_speed,
    :current_direction,
    :weather_remarks,
    :bad_weather_hours,
    :bad_weather_distance,
    :wind_direction_estimated_relative,
    :wind_direction_estimated,
    :state_of_sea,
    :sea_direction_relative,
    :sea_direction,
    :sea_height,
    :swell_direction_relative,
    :ocean_current_direction_relative,
    :ocean_current_direction,
    :ocean_current_direction_weather_provider
  ]

  @derive {Jason.Encoder, only: @fields}
  defstruct @fields

  @type t :: %__MODULE__{}

  @spec fields() :: [atom()]
  def fields, do: @fields
end
