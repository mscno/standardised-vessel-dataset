defmodule SVD.Validators.GeneralInformationValidator do
  @moduledoc false

  alias SVD.Models.GeneralInformation
  alias SVD.Validators.ValidationError

  @spec validate(GeneralInformation.t() | nil) :: [ValidationError.t()]
  def validate(nil) do
    [
      %ValidationError{
        field: "GeneralInformation",
        message: "General information cannot be nil"
      }
    ]
  end

  def validate(%GeneralInformation{} = general) do
    []
    |> validate_required_string(general.event_type, "General.EventType", "EventType is required")
    |> validate_required_string(
      general.operation_type,
      "General.OperationType",
      "OperationType is required"
    )
    |> validate_required_string(general.ship_name, "General.ShipName", "ShipName is required")
    |> validate_imo(general.imo)
    |> validate_ship_latitude(general.ship_latitude)
    |> validate_ship_longitude(general.ship_longitude)
    |> validate_ship_reporting_date(general.ship_reporting_date)
    |> validate_number_of_crew(general.number_of_crew)
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
        errors ++
          [%ValidationError{field: "General.IMO", message: "IMO is required", value: value}]

      String.length(value) != 7 ->
        errors ++
          [
            %ValidationError{
              field: "General.IMO",
              message: "IMO must be exactly 7 characters",
              value: value
            }
          ]

      !Regex.match?(~r/^\d+$/, value) ->
        errors ++
          [%ValidationError{field: "General.IMO", message: "IMO must be numeric", value: value}]

      true ->
        errors
    end
  end

  defp validate_ship_latitude(errors, nil), do: errors

  defp validate_ship_latitude(errors, value) when is_number(value) do
    if value < -90 or value > 90 do
      errors ++
        [
          %ValidationError{
            field: "General.ShipLatitude",
            message: "ShipLatitude must be between -90 and 90",
            value: value
          }
        ]
    else
      errors
    end
  end

  defp validate_ship_latitude(errors, _), do: errors

  defp validate_ship_longitude(errors, nil), do: errors

  defp validate_ship_longitude(errors, value) when is_number(value) do
    if value < -180 or value > 180 do
      errors ++
        [
          %ValidationError{
            field: "General.ShipLongitude",
            message: "ShipLongitude must be between -180 and 180",
            value: value
          }
        ]
    else
      errors
    end
  end

  defp validate_ship_longitude(errors, _), do: errors

  defp validate_ship_reporting_date(errors, nil) do
    errors ++
      [
        %ValidationError{
          field: "General.ShipReportingDate",
          message: "ShipReportingDate is required",
          value: nil
        }
      ]
  end

  defp validate_ship_reporting_date(errors, %DateTime{} = dt) do
    threshold = DateTime.add(DateTime.utc_now(), 24 * 60 * 60, :second)

    if DateTime.compare(dt, threshold) == :gt do
      errors ++
        [
          %ValidationError{
            field: "General.ShipReportingDate",
            message: "ShipReportingDate cannot be in the future",
            value: dt
          }
        ]
    else
      errors
    end
  end

  defp validate_ship_reporting_date(errors, _), do: errors

  defp validate_number_of_crew(errors, nil), do: errors

  defp validate_number_of_crew(errors, value) when is_integer(value) do
    if value < 0 do
      errors ++
        [
          %ValidationError{
            field: "General.NumberOfCrew",
            message: "NumberOfCrew cannot be negative",
            value: value
          }
        ]
    else
      errors
    end
  end

  defp validate_number_of_crew(errors, _), do: errors
end
