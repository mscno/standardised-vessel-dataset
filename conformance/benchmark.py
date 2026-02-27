#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import subprocess
import sys
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_CASES_DIR = ROOT / "conformance" / "cases"

ADAPTER_COMMANDS: dict[str, dict[str, Any]] = {
    "go": {
        "cmd": ["go", "run", "."],
        "cwd": ROOT / "conformance" / "adapters" / "go",
    },
    "dotnet": {
        "cmd": [
            "dotnet",
            "run",
            "--project",
            "./conformance/adapters/dotnet/Conformance.Adapter/Conformance.Adapter.csproj",
        ],
        "cwd": ROOT,
    },
    "elixir": {
        "cmd": [
            "mix",
            "run",
            "--no-start",
            "../../../conformance/adapters/elixir/adapter.exs",
        ],
        "cwd": ROOT / "src" / "elixir" / "svd",
    },
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Run conformance benchmark suite across implementations.")
    parser.add_argument("--cases-dir", default=str(DEFAULT_CASES_DIR), help="Directory containing conformance cases.")
    parser.add_argument("--adapters", default="go,dotnet", help="Comma separated adapter names.")
    parser.add_argument("--iterations", type=int, default=100, help="Benchmark iterations per case and operation.")
    parser.add_argument(
        "--allow-missing-adapters",
        action="store_true",
        help="Skip adapters that cannot be executed instead of failing the run.",
    )
    return parser.parse_args()


def load_cases(cases_dir: Path) -> list[dict[str, Any]]:
    cases: list[dict[str, Any]] = []
    for path in sorted(cases_dir.glob("*.json")):
        with path.open("r", encoding="utf-8") as f:
            case = json.load(f)
        if case.get("expect", {}).get("valid") is True:
            cases.append(case)
    if not cases:
        raise RuntimeError(f"No valid benchmark cases found in {cases_dir}")
    return cases


def run_adapter(adapter: str, case: dict[str, Any], iterations: int) -> dict[str, Any]:
    if adapter not in ADAPTER_COMMANDS:
        return {"adapter": adapter, "invoke_error": f"Unknown adapter: {adapter}"}

    request_payload = {
        "dataset": case["dataset"],
        "operations": ["benchmark"],
        "benchmark": {
            "iterations": iterations,
        },
    }

    try:
        adapter_config = ADAPTER_COMMANDS[adapter]
        proc = subprocess.run(
            adapter_config["cmd"],
            cwd=adapter_config["cwd"],
            input=json.dumps(request_payload),
            text=True,
            capture_output=True,
            check=False,
        )
    except FileNotFoundError as exc:
        return {"adapter": adapter, "invoke_error": str(exc)}

    if proc.returncode != 0:
        return {
            "adapter": adapter,
            "invoke_error": f"exit={proc.returncode}",
            "stdout": proc.stdout,
            "stderr": proc.stderr,
        }

    stdout = proc.stdout.strip()
    if not stdout:
        return {"adapter": adapter, "invoke_error": "adapter returned empty stdout"}

    response = None
    for line in reversed([line.strip() for line in stdout.splitlines() if line.strip()]):
        try:
            response = json.loads(line)
            break
        except json.JSONDecodeError:
            continue

    if response is None:
        try:
            response = json.loads(stdout)
        except json.JSONDecodeError as exc:
            return {
                "adapter": adapter,
                "invoke_error": f"invalid json from adapter: {exc}",
                "stdout": proc.stdout,
                "stderr": proc.stderr,
            }

    response["adapter"] = adapter
    return response


def main() -> int:
    args = parse_args()
    adapters = [name.strip() for name in args.adapters.split(",") if name.strip()]
    cases = load_cases(Path(args.cases_dir))

    aggregate: dict[str, dict[str, float]] = {}
    counts: dict[str, int] = {}

    for adapter in adapters:
        aggregate[adapter] = {
            "validate_avg_ms": 0.0,
            "export_json_avg_ms": 0.0,
            "export_xml_avg_ms": 0.0,
            "export_csv_avg_ms": 0.0,
        }
        counts[adapter] = 0

    for case in cases:
        case_id = case.get("id", "<unknown>")
        print(f"CASE {case_id}")

        for adapter in adapters:
            response = run_adapter(adapter, case, args.iterations)
            if "invoke_error" in response:
                if args.allow_missing_adapters:
                    print(f"  SKIP {adapter}: {response['invoke_error']}")
                    continue
                print(f"  FAIL {adapter}: {response['invoke_error']}")
                return 1

            benchmark_result = response.get("results", {}).get("benchmark", {})
            if not benchmark_result.get("ok", False):
                print(f"  FAIL {adapter}: benchmark op failed: {benchmark_result.get('error', 'unknown error')}")
                return 1

            metrics = benchmark_result.get("metrics", {})
            print(
                f"  {adapter}: "
                f"validate={metrics.get('validate', {}).get('avg_ms', 0.0):.4f}ms, "
                f"json={metrics.get('export_json', {}).get('avg_ms', 0.0):.4f}ms, "
                f"xml={metrics.get('export_xml', {}).get('avg_ms', 0.0):.4f}ms, "
                f"csv={metrics.get('export_csv', {}).get('avg_ms', 0.0):.4f}ms"
            )

            aggregate[adapter]["validate_avg_ms"] += float(metrics.get("validate", {}).get("avg_ms", 0.0))
            aggregate[adapter]["export_json_avg_ms"] += float(metrics.get("export_json", {}).get("avg_ms", 0.0))
            aggregate[adapter]["export_xml_avg_ms"] += float(metrics.get("export_xml", {}).get("avg_ms", 0.0))
            aggregate[adapter]["export_csv_avg_ms"] += float(metrics.get("export_csv", {}).get("avg_ms", 0.0))
            counts[adapter] += 1

    print("-")
    print(f"Iterations per case: {args.iterations}")
    print("Average across valid cases:")

    for adapter in adapters:
        if counts[adapter] == 0:
            print(f"  {adapter}: no data")
            continue

        n = counts[adapter]
        print(
            f"  {adapter}: "
            f"validate={aggregate[adapter]['validate_avg_ms'] / n:.4f}ms, "
            f"json={aggregate[adapter]['export_json_avg_ms'] / n:.4f}ms, "
            f"xml={aggregate[adapter]['export_xml_avg_ms'] / n:.4f}ms, "
            f"csv={aggregate[adapter]['export_csv_avg_ms'] / n:.4f}ms"
        )

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
