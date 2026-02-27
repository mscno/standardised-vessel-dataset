defmodule SVD.Utils.ValueFormatterTest do
  use ExUnit.Case, async: true

  alias SVD.Utils.ValueFormatter

  test "to_json handles date/time types" do
    dt = DateTime.utc_now() |> DateTime.truncate(:second)
    ndt = ~N[2026-01-01 12:00:00]
    assert ValueFormatter.to_json(dt) == DateTime.to_iso8601(dt)
    assert ValueFormatter.to_json(ndt) == NaiveDateTime.to_iso8601(ndt)
    assert ValueFormatter.to_json(~D[2026-01-01]) == "2026-01-01"
    assert ValueFormatter.to_json(~T[12:30:45]) == "12:30:45"
    assert ValueFormatter.to_json("x") == "x"
  end

  test "to_xml handles nil and primitive values" do
    dt = DateTime.from_naive!(~N[2026-01-01 12:00:00], "Etc/UTC")
    assert ValueFormatter.to_xml(nil) == nil
    assert ValueFormatter.to_xml(dt) == DateTime.to_iso8601(dt)
    assert ValueFormatter.to_xml(1) == "1"
    assert ValueFormatter.to_xml(1.5) != ""
    assert ValueFormatter.to_xml(true) == "true"
    assert ValueFormatter.to_xml("x") == "x"
    assert ValueFormatter.to_xml(~N[2026-01-01 12:00:00]) == "2026-01-01T12:00:00"
    assert ValueFormatter.to_xml(~D[2026-01-01]) == "2026-01-01"
    assert ValueFormatter.to_xml(~T[12:30:45]) == "12:30:45"
    assert ValueFormatter.to_xml({:a, 1}) == "{:a, 1}"
  end

  test "to_csv handles nil and primitive values" do
    dt = DateTime.from_naive!(~N[2026-01-01 12:00:00], "Etc/UTC")
    assert ValueFormatter.to_csv(nil) == ""
    assert ValueFormatter.to_csv(dt) == DateTime.to_iso8601(dt)
    assert ValueFormatter.to_csv(1) == "1"
    assert ValueFormatter.to_csv(1.5) != ""
    assert ValueFormatter.to_csv(false) == "false"
    assert ValueFormatter.to_csv("x") == "x"
    assert ValueFormatter.to_csv(~N[2026-01-01 12:00:00]) == "2026-01-01T12:00:00"
    assert ValueFormatter.to_csv(~D[2026-01-01]) == "2026-01-01"
    assert ValueFormatter.to_csv(~T[12:30:45]) == "12:30:45"
    assert ValueFormatter.to_csv({:a, 1}) == "{:a, 1}"
  end
end
