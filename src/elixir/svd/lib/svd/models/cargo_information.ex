defmodule SVD.Models.CargoInformation do
  @moduledoc false

  @fields [
    :cargo_type,
    :cargo_description,
    :cargo_quantity,
    :cargo_loaded,
    :cargo_discharged,
    :cargo_rob,
    :teu_count,
    :feu_count,
    :passenger_count,
    :vehicle_count,
    :gross_weight,
    :gross_volume,
    :bill_of_lading_reference,
    :bill_of_lading_issued_date,
    :total_containers_teu,
    :total_full_containers_teu,
    :total_full_reefer_containers_teu,
    :reefer_sockets_in_use,
    :chilled_20_ft_reefer_containers,
    :chilled_40_ft_reefer_containers,
    :frozen_20_ft_reefer_containers,
    :frozen_40_ft_reefer_containers,
    :total_vehicles_ceu
  ]

  @derive {Jason.Encoder, only: @fields}
  defstruct @fields

  @type t :: %__MODULE__{}

  @spec fields() :: [atom()]
  def fields, do: @fields
end
