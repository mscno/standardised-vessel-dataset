defmodule SVD.Models.GeneralInformation do
  @moduledoc false

  @fields [
    :event_type,
    :operation_type,
    :operation_description,
    :performance_report_type,
    :elapsed_time,
    :ship_latitude,
    :ship_longitude,
    :ship_reporting_date,
    :ship_flag_state,
    :ship_registry_port_code,
    :ship_registry_port_name,
    :ship_name,
    :imo,
    :call_sign,
    :mmsi,
    :ship_type,
    :ship_type_marpol_annex_vi,
    :number_of_passengers,
    :number_of_crew,
    :voyage_number,
    :voyage_remarks,
    :voyage_leg_identifier,
    :voyage_leg_remarks,
    :deadweight,
    :gross_tonnage,
    :net_tonnage,
    :ship_owner,
    :ship_manager,
    :charterer,
    :length_overall,
    :beam,
    :depth
  ]

  @derive {Jason.Encoder, only: @fields}
  defstruct @fields

  @type t :: %__MODULE__{}

  @spec fields() :: [atom()]
  def fields, do: @fields
end
