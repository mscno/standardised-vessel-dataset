# Standardised Vessel Dataset (Go)

Go implementation of the Standardised Vessel Dataset with parity-focused models and exporters aligned to the .NET and C++ implementations in this repository.

## Install

```bash
go get github.com/WMS-Ceataec/standardised-vessel-dataset/src/go/svd
```

## Packages

- `models`: SVD model types
- `validators`: SVD validators and validation errors
- `exporters`: export contracts and shared base exporter
- `exporters/formats/json`: JSON exporter
- `exporters/formats/xml`: XML exporter
- `exporters/formats/csv`: CSV exporter
- `extensions`: service-provider style wiring helpers

## Usage

```go
provider := extensions.NewServiceProvider()
validator := provider.GetValidator()
jsonExporter := provider.GetJSONExporter()
```

## Testing

Run unit tests:

```bash
go test ./...
```

Generate coverage report:

```bash
go test ./... -coverprofile=coverage.out
go tool cover -func=coverage.out
```

## Example Program

The example is intentionally excluded from default library builds.

```bash
go run -tags example ./example
```
