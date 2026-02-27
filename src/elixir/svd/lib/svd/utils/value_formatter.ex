defmodule SVD.Utils.ValueFormatter do
  @moduledoc false

  @spec to_json(term()) :: term()
  def to_json(%DateTime{} = dt), do: DateTime.to_iso8601(dt)
  def to_json(%NaiveDateTime{} = dt), do: NaiveDateTime.to_iso8601(dt)
  def to_json(%Time{} = t), do: Time.to_iso8601(t)
  def to_json(%Date{} = d), do: Date.to_iso8601(d)
  def to_json(value), do: value

  @spec to_xml(term()) :: String.t() | nil
  def to_xml(nil), do: nil
  def to_xml(%DateTime{} = dt), do: DateTime.to_iso8601(dt)
  def to_xml(%NaiveDateTime{} = dt), do: NaiveDateTime.to_iso8601(dt)
  def to_xml(%Time{} = t), do: Time.to_iso8601(t)
  def to_xml(%Date{} = d), do: Date.to_iso8601(d)

  def to_xml(value) when is_float(value),
    do: :io_lib.format("~g", [value]) |> IO.iodata_to_binary()

  def to_xml(value) when is_integer(value), do: Integer.to_string(value)
  def to_xml(value) when is_boolean(value), do: Atom.to_string(value)
  def to_xml(value) when is_binary(value), do: value
  def to_xml(value), do: inspect(value)

  @spec to_csv(term()) :: String.t()
  def to_csv(nil), do: ""
  def to_csv(%DateTime{} = dt), do: DateTime.to_iso8601(dt)
  def to_csv(%NaiveDateTime{} = dt), do: NaiveDateTime.to_iso8601(dt)
  def to_csv(%Time{} = t), do: Time.to_iso8601(t)
  def to_csv(%Date{} = d), do: Date.to_iso8601(d)

  def to_csv(value) when is_float(value),
    do: :io_lib.format("~g", [value]) |> IO.iodata_to_binary()

  def to_csv(value) when is_integer(value), do: Integer.to_string(value)
  def to_csv(value) when is_boolean(value), do: Atom.to_string(value)
  def to_csv(value) when is_binary(value), do: value
  def to_csv(value), do: inspect(value)
end
