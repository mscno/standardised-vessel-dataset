defmodule SVD.Utils.CaseConverter do
  @moduledoc false

  @acronyms %{
    "imo" => "IMO",
    "mmsi" => "MMSI",
    "mgo" => "MGO",
    "hfo" => "HFO",
    "mdo" => "MDO",
    "rob" => "ROB",
    "teu" => "TEU",
    "feu" => "FEU",
    "ceu" => "CEU",
    "vts" => "VTS",
    "ghg" => "GHG",
    "co2" => "CO2",
    "ch4" => "CH4",
    "n2o" => "N2O"
  }

  @spec camel(atom()) :: String.t()
  def camel(field) when is_atom(field) do
    field
    |> Atom.to_string()
    |> Macro.camelize()
    |> decapitalize_first()
  end

  @spec pascal(atom()) :: String.t()
  def pascal(field) when is_atom(field) do
    field
    |> Atom.to_string()
    |> String.split("_", trim: true)
    |> Enum.map_join(&pascal_part/1)
  end

  @spec snake(atom()) :: String.t()
  def snake(field) when is_atom(field), do: Atom.to_string(field)

  defp pascal_part(part) do
    Map.get(@acronyms, part, Macro.camelize(part))
  end

  defp decapitalize_first(<<first::utf8, rest::binary>>) do
    <<String.downcase(<<first::utf8>>)::binary, rest::binary>>
  end

  defp decapitalize_first(<<>>), do: ""
end
