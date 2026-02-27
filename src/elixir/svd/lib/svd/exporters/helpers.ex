defmodule SVD.Exporters.Helpers do
  @moduledoc false

  alias SVD.Models.StandardisedVesselDataset

  @spec file_name(StandardisedVesselDataset.t(), String.t()) :: String.t()
  def file_name(%StandardisedVesselDataset{general: general}, extension) do
    date = report_date(general && general.ship_reporting_date)
    imo = if general, do: general.imo || "", else: ""
    "SVD_#{imo}_#{date}.#{extension}"
  end

  defp report_date(%DateTime{} = dt), do: dt |> DateTime.to_date() |> Date.to_iso8601()
  defp report_date(_), do: Date.utc_today() |> Date.to_iso8601()
end
