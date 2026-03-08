defmodule SVD.Validators.GeneralInformationValidator do
  @moduledoc false

  alias SVD.Models.GeneralInformation
  alias SVD.Validators.ValidationError

  @minimum_ship_reporting_date ~U[0001-01-01 00:00:00Z]

  @spec validate(GeneralInformation.t() | nil) :: [ValidationError.t()]
  def validate(nil) do
    [
      %ValidationError{
        field: "General",
        message: "General is required"
      }
    ]
  end

  def validate(%GeneralInformation{} = general) do
    []
    |> validate_required_string(general.imo, "General.Imo", "Imo is required")
    |> validate_imo(general.imo)
    |> validate_required_string(general.ship_name, "General.ShipName", "Ship Name is required")
    |> validate_ship_reporting_date(general.ship_reporting_date)
  end

  def validate(_), do: validate(nil)

  defp validate_required_string(errors, value, field, message) do
    if is_binary(value) and String.trim(value) != "" do
      errors
    else
      errors ++ [%ValidationError{field: field, message: message, value: value}]
    end
  end

  defp validate_imo(errors, value) do
    cond do
      !is_binary(value) or String.trim(value) == "" ->
        errors

      Regex.match?(~r/^\d{7}$/, value) ->
        errors

      true ->
        errors ++
          [
            %ValidationError{
              field: "General.Imo",
              message: "Imo must be seven digits.",
              value: value
            }
          ]
    end
  end

  defp validate_ship_reporting_date(errors, value) do
    case normalize_datetime(value) do
      nil ->
        errors ++
          [
            %ValidationError{
              field: "General.ShipReportingDate",
              message: "Ship Reporting Date (Datetime) must be greater than default.",
              value: value
            }
          ]

      %DateTime{} = dt ->
        if DateTime.compare(dt, @minimum_ship_reporting_date) == :gt do
          errors
        else
          errors ++
            [
              %ValidationError{
                field: "General.ShipReportingDate",
                message: "Ship Reporting Date (Datetime) must be greater than default.",
                value: value
              }
            ]
        end
    end
  end

  defp normalize_datetime(%DateTime{} = value), do: value

  defp normalize_datetime(%NaiveDateTime{} = value) do
    case DateTime.from_naive(value, "Etc/UTC") do
      {:ok, dt} -> dt
      _ -> nil
    end
  end

  defp normalize_datetime(value) when is_binary(value) do
    case DateTime.from_iso8601(String.trim(value)) do
      {:ok, dt, _offset} -> dt
      _ -> nil
    end
  end

  defp normalize_datetime(_), do: nil
end
