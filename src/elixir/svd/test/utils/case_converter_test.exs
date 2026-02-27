defmodule SVD.Utils.CaseConverterTest do
  use ExUnit.Case, async: true

  alias SVD.Utils.CaseConverter

  test "camel conversion" do
    assert CaseConverter.camel(:ship_reporting_date) == "shipReportingDate"
  end

  test "pascal conversion with acronyms" do
    assert CaseConverter.pascal(:imo) == "IMO"
    assert CaseConverter.pascal(:mgo_rob) == "MGOROB"
    assert CaseConverter.pascal(:total_co2) == "TotalCO2"
  end

  test "snake conversion" do
    assert CaseConverter.snake(:ship_name) == "ship_name"
  end

  test "camel conversion handles empty atom name" do
    assert CaseConverter.camel(:"") == ""
  end
end
