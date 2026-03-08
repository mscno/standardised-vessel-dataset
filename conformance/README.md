# Conformance And Benchmark Suite

This folder contains a shared cross-implementation suite for SVD parity checks and performance sampling.

## What this gives you

- A single corpus of deterministic test cases in `conformance/cases/*.json`.
- Adapter CLIs per implementation:
  - `conformance/adapters/go`
  - `conformance/adapters/dotnet/Conformance.Adapter`
  - `conformance/adapters/elixir/adapter.exs`
  - `conformance/adapters/typescript/main.mjs`
  - `src/rust/svd` (Cargo adapter binary)
- One parity runner that executes the same cases against each adapter and compares canonicalized outputs:
  - `conformance/runner.py`
- One benchmark runner that executes the same valid cases and reports average per-operation timings:
  - `conformance/benchmark.py`

## Local usage

From repository root:

```bash
python3 conformance/runner.py --adapters go,dotnet,elixir,rust,typescript
```

```bash
python3 conformance/benchmark.py --adapters go,dotnet,elixir,rust,typescript --iterations 200
```

If one runtime is missing on your machine, run only the available adapters:

```bash
python3 conformance/runner.py --adapters go,rust,typescript
```

To target only a subset of runtimes:

```bash
python3 conformance/runner.py --adapters go,dotnet,rust,typescript
```

The Elixir implementation requires Elixir `~> 1.15` (see `src/elixir/svd/mix.exs`).

## Docker usage

Build and run parity tests:

```bash
docker build -f conformance/Dockerfile -t svd-conformance .     
docker run --rm svd-conformance
```

Run benchmark in Docker:

```bash
docker run --rm svd-conformance python3 conformance/benchmark.py --adapters go,dotnet,rust,typescript --iterations 200
```

## Docker Compose usage

From repository root:

```bash
docker compose -f conformance/docker-compose.yml run --rm conformance
```

```bash
docker compose -f conformance/docker-compose.yml run --rm benchmark
```

## Case format

Each case file must include:

- `id`: stable case identifier
- `dataset`: input payload passed to each adapter
- `expect.valid`: `true` or `false`

Optional:

- `parity.validate`: enable/disable strict cross-adapter validation parity
- `parity.exports`: enable/disable strict cross-adapter export parity
- `assertions`: adapter-agnostic assertions for valid export content
  - `assertions.json_paths`: assert JSON export values by dotted path
  - `assertions.xml_paths`: assert XML leaf values by slash path
  - `assertions.csv_fields`: assert CSV values by short field name
  - `assertions.json_equals_dataset`: when `true`, assert every JSON leaf provided in `dataset`
    matches each adapter JSON export (excluding known representational exceptions like
    `general.elapsedTime`)

## Notes

- Benchmark output is informational and should be used for regression monitoring, not hard cross-language speed gating.
- The parity runner currently normalizes known representational differences (for example, `General.ElapsedTime` formatting).
