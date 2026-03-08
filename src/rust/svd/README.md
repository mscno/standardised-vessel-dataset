# Rust SVD Adapter

This package provides a Rust implementation used by the cross-language conformance suite.

## What it includes

- `StandardisedVesselDataset` parsing from JSON input.
- Validation rules aligned with existing SVD implementations for General information.
- JSON, XML, and CSV export operations used by the conformance runner.
- Benchmark operation reporting per-operation timing metrics.

## Run tests

```bash
cargo test --manifest-path src/rust/svd/Cargo.toml
```

## Run adapter manually

```bash
jq '{dataset:.dataset,operations:["validate","export_json","export_xml","export_csv"]}' conformance/cases/valid_core.json \
  | cargo run --manifest-path src/rust/svd/Cargo.toml --quiet
```
