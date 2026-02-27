# Conformance And Benchmark Suite

This folder contains a shared cross-implementation suite for SVD parity checks and performance sampling.

## What this gives you

- A single corpus of deterministic test cases in `conformance/cases/*.json`.
- Adapter CLIs per implementation:
  - `conformance/adapters/go`
  - `conformance/adapters/dotnet/Conformance.Adapter`
- One parity runner that executes the same cases against each adapter and compares canonicalized outputs:
  - `conformance/runner.py`
- One benchmark runner that executes the same valid cases and reports average per-operation timings:
  - `conformance/benchmark.py`

## Local usage

From repository root:

```bash
python3 conformance/runner.py --adapters go,dotnet
```

```bash
python3 conformance/benchmark.py --adapters go,dotnet --iterations 200
```

If one runtime is missing on your machine, run only the available adapter:

```bash
python3 conformance/runner.py --adapters go
```

## Docker usage

Build and run parity tests:

```bash
docker build -f conformance/Dockerfile -t svd-conformance .     
docker run --rm svd-conformance
```

Run benchmark in Docker:

```bash
docker run --rm svd-conformance python3 conformance/benchmark.py --adapters go,dotnet --iterations 200
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

- `expect.expected_errors`: exact validator parity expectations for invalid cases

## Notes

- Benchmark output is informational and should be used for regression monitoring, not hard cross-language speed gating.
- The parity runner currently normalizes known representational differences (for example, `General.ElapsedTime` formatting).
