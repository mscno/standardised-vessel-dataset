defmodule SVD.SerializersTest do
  use ExUnit.Case, async: true

  alias SVD.Models.{GeneralInformation, StandardisedVesselDataset}
  alias SVD.Serializers

  defmodule UnknownStruct do
    defstruct [:value]
  end

  test "serialize dataset to json map" do
    dataset =
      %StandardisedVesselDataset{
        general: %GeneralInformation{
          event_type: "NOON",
          imo: "1234567",
          ship_reporting_date: DateTime.utc_now() |> DateTime.truncate(:second)
        },
        emissions: nil
      }

    payload = Serializers.to_json_map(dataset)

    assert get_in(payload, ["general", "eventType"]) == "NOON"
    assert get_in(payload, ["general", "imo"]) == "1234567"
    assert Map.has_key?(payload, "emissions")
  end

  test "serializer handles unknown struct values" do
    dataset =
      %StandardisedVesselDataset{
        general: %GeneralInformation{
          event_type: "NOON",
          imo: "1234567",
          ship_reporting_date: DateTime.utc_now()
        },
        cargo: %{__struct__: UnknownStruct, value: 1}
      }

    payload = Serializers.to_json_map(dataset)
    assert payload["cargo"] == %UnknownStruct{value: 1}
  end

  test "serializer handles list values in nested struct" do
    dataset =
      %StandardisedVesselDataset{
        general: %GeneralInformation{
          event_type: "NOON",
          imo: "1234567",
          ship_reporting_date: DateTime.utc_now(),
          ship_owner: ["A", "B"]
        }
      }

    payload = Serializers.to_json_map(dataset)
    assert get_in(payload, ["general", "shipOwner"]) == ["A", "B"]
  end

  test "serializer handles naive/date/time values" do
    dataset =
      %StandardisedVesselDataset{
        general: %GeneralInformation{
          event_type: "NOON",
          imo: "1234567",
          ship_reporting_date: DateTime.utc_now(),
          operation_description: ~N[2026-01-01 12:00:00],
          performance_report_type: ~D[2026-01-01],
          voyage_remarks: ~T[12:30:45]
        }
      }

    payload = Serializers.to_json_map(dataset)

    assert get_in(payload, ["general", "operationDescription"]) == "2026-01-01T12:00:00"
    assert get_in(payload, ["general", "performanceReportType"]) == "2026-01-01"
    assert get_in(payload, ["general", "voyageRemarks"]) == "12:30:45"
  end
end
