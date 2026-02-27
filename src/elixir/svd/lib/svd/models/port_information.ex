defmodule SVD.Models.PortInformation do
  @moduledoc false

  @fields [
    :departure_port_code,
    :departure_port_description,
    :departure_port_name,
    :arrival_port_code,
    :arrival_port_description,
    :arrival_port_name,
    :inbound_port_jurisdiction_code,
    :outbound_port_jurisdiction_code,
    :pilot_boarding_place_name,
    :pilot_boarding_place_location,
    :berth_name
  ]

  @derive {Jason.Encoder, only: @fields}
  defstruct @fields

  @type t :: %__MODULE__{}

  @spec fields() :: [atom()]
  def fields, do: @fields
end
