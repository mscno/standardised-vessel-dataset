defmodule SVD.Exporters.ContentTest do
  use ExUnit.Case, async: true

  alias SVD.Exporters.StandardisedVesselDatasetContent

  test "build content struct" do
    content = StandardisedVesselDatasetContent.new("data", "file.json", "application/json")

    assert content.data == "data"
    assert content.file_name == "file.json"
    assert content.content_type == "application/json"
  end

  test "default struct can be created" do
    content = struct(StandardisedVesselDatasetContent)
    assert content.data == nil
    assert content.file_name == nil
    assert content.content_type == nil
  end
end
