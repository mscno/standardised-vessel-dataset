# Standardised Vessel Dataset (SVD) Elixir Library

Elixir implementation of the Standardised Vessel Dataset with parity-focused behavior across existing `.NET`, `C++`, and `Go` libraries.

## Features

- Complete SVD model surface (including `Emissions`)
- Validation for required general fields and domain constraints
- Exporters for JSON, XML, and CSV
- Service provider module for validator/exporter wiring
- High automated test coverage

## Installation

Add to `mix.exs`:

```elixir
defp deps do
  [
    {:svd, path: "../path/to/standardised-vessel-dataset/src/elixir/svd"}
  ]
end
```

## Usage

```elixir
alias SVD.Extensions.ServiceProvider
alias SVD.Exporters.Formats.JSONExporter

provider = ServiceProvider.new()

svd = %SVD.Models.StandardisedVesselDataset{
  general: %SVD.Models.GeneralInformation{
    event_type: "NOON",
    operation_type: "SAILING",
    ship_name: "MV Ocean Explorer",
    imo: "1234567",
    ship_reporting_date: DateTime.utc_now()
  }
}

exporter = ServiceProvider.get_json_exporter(provider)
{:ok, result} = JSONExporter.export_async(exporter, svd)
```

## Validation

```elixir
validator = ServiceProvider.get_validator(provider)
errors = validator.validate(svd)
```

## Testing

```bash
mix test
mix test --cover
```
