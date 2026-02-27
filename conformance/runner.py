#!/usr/bin/env python3
from __future__ import annotations

import argparse
import csv
import io
import json
import re
import subprocess
import sys
import xml.etree.ElementTree as ET
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

IGNORE_JSON_PATHS = {
    "general.elapsedTime",
}

IGNORE_XML_PATHS = {
    "StandardisedVesselDataset/General/ElapsedTime",
}

IGNORE_CSV_HEADERS = {
    "General.ElapsedTime",
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Run cross-implementation SVD conformance checks.")
    parser.add_argument(
        "--cases-dir",
        default=str(DEFAULT_CASES_DIR),
        help="Directory containing *.json conformance case files.",
    )
    parser.add_argument(
        "--adapters",
        default="go,dotnet",
        help="Comma separated adapter names to run. Known: go,dotnet,elixir",
    )
    parser.add_argument(
        "--allow-missing-adapters",
        action="store_true",
        help="Skip adapters that cannot be executed instead of failing the run.",
    )
    return parser.parse_args()


def normalize_token(value: str) -> str:
    return re.sub(r"[^a-z0-9]+", ".", value.lower()).strip(".")


def normalize_message(value: str) -> str:
    return re.sub(r"\s+", " ", value.strip().lower())


def normalize_error_code(field: str, message: str) -> str:
    return f"{normalize_token(field)}:{normalize_message(message)}"


def load_cases(cases_dir: Path) -> list[dict[str, Any]]:
    case_files = sorted(cases_dir.glob("*.json"))
    if not case_files:
        raise RuntimeError(f"No case files found in: {cases_dir}")

    cases: list[dict[str, Any]] = []
    for case_file in case_files:
        with case_file.open("r", encoding="utf-8") as f:
            case = json.load(f)
        if "id" not in case:
            raise RuntimeError(f"Case missing 'id': {case_file}")
        if "dataset" not in case:
            raise RuntimeError(f"Case missing 'dataset': {case_file}")
        if "expect" not in case or "valid" not in case["expect"]:
            raise RuntimeError(f"Case missing 'expect.valid': {case_file}")
        case["_file"] = str(case_file)
        cases.append(case)
    return cases


def run_adapter(adapter: str, case: dict[str, Any]) -> dict[str, Any]:
    if adapter not in ADAPTER_COMMANDS:
        return {"adapter": adapter, "invoke_error": f"Unknown adapter: {adapter}"}

    request_payload = {
        "dataset": case["dataset"],
        "operations": ["validate", "export_json", "export_xml", "export_csv"],
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
        return {"adapter": adapter, "invoke_error": f"{exc}"}

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


def normalize_json_value(value: Any, path: str = "") -> Any:
    if isinstance(value, dict):
        out: dict[str, Any] = {}
        for key in sorted(value.keys()):
            child_path = f"{path}.{key}" if path else key
            if child_path in IGNORE_JSON_PATHS:
                continue
            out[key] = normalize_json_value(value[key], child_path)
        return out
    if isinstance(value, list):
        return [normalize_json_value(v, path) for v in value]
    return value


def canonicalize_validation(result: dict[str, Any]) -> dict[str, Any]:
    if not result.get("ok", False):
        return {
            "ok": False,
            "error": normalize_message(str(result.get("error", "unknown validation failure"))),
        }

    errors = result.get("errors", [])
    normalized = sorted(
        normalize_error_code(str(err.get("field", "")), str(err.get("message", "")))
        for err in errors
    )
    return {
        "ok": True,
        "errors": normalized,
    }


def canonicalize_export_json(result: dict[str, Any]) -> dict[str, Any]:
    if not result.get("ok", False):
        return {
            "ok": False,
            "error": normalize_message(str(result.get("error", "json export failed"))),
        }

    raw_data = str(result.get("data", ""))
    try:
        payload = json.loads(raw_data)
    except json.JSONDecodeError as exc:
        return {
            "ok": False,
            "error": f"invalid json output: {exc}",
        }

    return {
        "ok": True,
        "content_type": result.get("content_type", ""),
        "file_name": result.get("file_name", ""),
        "data": normalize_json_value(payload),
    }


def strip_xml_ns(tag: str) -> str:
    if "}" in tag:
        return tag.split("}", 1)[1]
    return tag


def collect_xml_leaf_nodes(element: ET.Element, path: list[str], out: list[tuple[str, str]]) -> None:
    tag = strip_xml_ns(element.tag)
    next_path = path + [tag]

    child_elements = [child for child in list(element) if isinstance(child.tag, str)]
    if not child_elements:
        joined = "/".join(next_path)
        if joined not in IGNORE_XML_PATHS:
            out.append((joined, (element.text or "").strip()))
        return

    for child in child_elements:
        collect_xml_leaf_nodes(child, next_path, out)


def canonicalize_export_xml(result: dict[str, Any]) -> dict[str, Any]:
    if not result.get("ok", False):
        return {
            "ok": False,
            "error": normalize_message(str(result.get("error", "xml export failed"))),
        }

    raw_data = str(result.get("data", ""))
    try:
        root = ET.fromstring(raw_data)
    except ET.ParseError as exc:
        return {
            "ok": False,
            "error": f"invalid xml output: {exc}",
        }

    leaves: list[tuple[str, str]] = []
    collect_xml_leaf_nodes(root, [], leaves)

    leaf_map = {path: value for path, value in leaves}

    return {
        "ok": True,
        "content_type": result.get("content_type", ""),
        "file_name": result.get("file_name", ""),
        "leaves": sorted(leaves),
        "leaf_map": leaf_map,
    }


def canonicalize_export_csv(result: dict[str, Any]) -> dict[str, Any]:
    if not result.get("ok", False):
        return {
            "ok": False,
            "error": normalize_message(str(result.get("error", "csv export failed"))),
        }

    raw_data = str(result.get("data", ""))
    reader = csv.reader(io.StringIO(raw_data))
    rows = list(reader)
    if len(rows) < 2:
        return {
            "ok": False,
            "error": "csv output must include at least header and one row",
        }

    headers = rows[0]
    values = rows[1]
    width = min(len(headers), len(values))
    mapping = {headers[i]: values[i] for i in range(width) if headers[i] not in IGNORE_CSV_HEADERS}
    short_mapping: dict[str, str] = {}
    for key, value in mapping.items():
        short_key = key.split(".")[-1]
        if short_key not in short_mapping:
            short_mapping[short_key] = value

    return {
        "ok": True,
        "content_type": result.get("content_type", ""),
        "file_name": result.get("file_name", ""),
        "row": sorted(mapping.items()),
        "row_map": mapping,
        "short_row_map": short_mapping,
    }


def canonicalize_response(response: dict[str, Any]) -> dict[str, Any]:
    results = response.get("results", {})
    return {
        "validate": canonicalize_validation(results.get("validate", {"ok": False, "error": "missing validate result"})),
        "export_json": canonicalize_export_json(results.get("export_json", {"ok": False, "error": "missing export_json result"})),
        "export_xml": canonicalize_export_xml(results.get("export_xml", {"ok": False, "error": "missing export_xml result"})),
        "export_csv": canonicalize_export_csv(results.get("export_csv", {"ok": False, "error": "missing export_csv result"})),
    }


def json_path_value(payload: Any, path: str) -> Any:
    current = payload
    for token in path.split("."):
        if not isinstance(current, dict) or token not in current:
            return None
        current = current[token]
    return current


def normalize_assertion_value(value: Any) -> str:
    if isinstance(value, bool):
        return "true" if value else "false"
    if value is None:
        return ""
    text = str(value)
    timestamp = re.fullmatch(r"(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2})(\.\d+)?Z", text)
    if timestamp:
        fraction = timestamp.group(2) or ""
        if fraction:
            fraction = fraction.rstrip("0")
            if fraction == ".":
                fraction = ""
        return f"{timestamp.group(1)}{fraction}Z"
    return text


def compare_assertions(case: dict[str, Any], canonical_per_adapter: dict[str, dict[str, Any]]) -> list[str]:
    failures: list[str] = []
    assertions = case.get("assertions", {})
    if not assertions:
        return failures

    json_assertions = assertions.get("json_paths", {})
    xml_assertions = assertions.get("xml_paths", {})
    csv_assertions = assertions.get("csv_fields", {})

    for adapter, canonical in canonical_per_adapter.items():
        export_json = canonical["export_json"]
        export_xml = canonical["export_xml"]
        export_csv = canonical["export_csv"]

        for path, expected in json_assertions.items():
            actual = json_path_value(export_json.get("data", {}), path) if export_json.get("ok") else None
            if normalize_assertion_value(actual) != normalize_assertion_value(expected):
                failures.append(
                    f"adapter={adapter}: json assertion {path} expected={expected!r} actual={actual!r}"
                )

        xml_map = export_xml.get("leaf_map", {}) if export_xml.get("ok") else {}
        for path, expected in xml_assertions.items():
            actual = xml_map.get(path)
            if normalize_assertion_value(actual) != normalize_assertion_value(expected):
                failures.append(
                    f"adapter={adapter}: xml assertion {path} expected={expected!r} actual={actual!r}"
                )

        csv_map = export_csv.get("short_row_map", {}) if export_csv.get("ok") else {}
        for field, expected in csv_assertions.items():
            actual = csv_map.get(field)
            if normalize_assertion_value(actual) != normalize_assertion_value(expected):
                failures.append(
                    f"adapter={adapter}: csv assertion {field} expected={expected!r} actual={actual!r}"
                )

    return failures


def compare_case(case: dict[str, Any], adapter_responses: dict[str, dict[str, Any]]) -> list[str]:
    failures: list[str] = []
    expect_valid = bool(case["expect"]["valid"])
    parity_config = case.get("parity", {})
    parity_validate = bool(parity_config.get("validate", expect_valid))
    parity_exports = bool(parity_config.get("exports", expect_valid))

    canonical_per_adapter: dict[str, dict[str, Any]] = {}

    for adapter, response in adapter_responses.items():
        if "invoke_error" in response:
            failures.append(f"adapter={adapter}: invoke_error={response['invoke_error']}")
            continue

        canonical = canonicalize_response(response)
        canonical_per_adapter[adapter] = canonical

        validate_result = canonical["validate"]
        if not validate_result["ok"]:
            failures.append(f"adapter={adapter}: validate operation failed: {validate_result['error']}")
            continue

        actual_errors = validate_result["errors"]
        if expect_valid and actual_errors:
            failures.append(f"adapter={adapter}: expected no validation errors, got: {actual_errors}")

        if not expect_valid and not actual_errors:
            failures.append(f"adapter={adapter}: expected validation errors, got none")

        expected_errors = case["expect"].get("expected_errors")
        if expected_errors is not None:
            normalized_expected = sorted(
                normalize_error_code(*entry.split(":", 1)) if ":" in entry else normalize_message(entry)
                for entry in expected_errors
            )
            if actual_errors != normalized_expected:
                failures.append(
                    f"adapter={adapter}: expected errors {normalized_expected}, got {actual_errors}"
                )

        if expect_valid:
            for op in ("export_json", "export_xml", "export_csv"):
                op_result = canonical[op]
                if not op_result["ok"]:
                    failures.append(f"adapter={adapter}: expected {op} success, got error: {op_result['error']}")
        else:
            for op in ("export_json", "export_xml", "export_csv"):
                op_result = canonical[op]
                if op_result["ok"]:
                    failures.append(f"adapter={adapter}: expected {op} to fail for invalid case")

    adapters = sorted(canonical_per_adapter.keys())
    if len(adapters) < 2:
        if expect_valid:
            failures.extend(compare_assertions(case, canonical_per_adapter))
        return failures

    baseline = adapters[0]
    baseline_result = canonical_per_adapter[baseline]

    if expect_valid and case.get("assertions"):
        failures.extend(compare_assertions(case, canonical_per_adapter))
    else:
        for adapter in adapters[1:]:
            current = canonical_per_adapter[adapter]

            if parity_validate and baseline_result["validate"] != current["validate"]:
                failures.append(
                    f"parity(validate): {adapter} != {baseline}\n  {baseline}: {baseline_result['validate']}\n  {adapter}: {current['validate']}"
                )

            if expect_valid and parity_exports:
                for op in ("export_json", "export_xml", "export_csv"):
                    if baseline_result[op] != current[op]:
                        failures.append(
                            f"parity({op}): {adapter} != {baseline}\n"
                            f"  {baseline}: {baseline_result[op]}\n"
                            f"  {adapter}: {current[op]}"
                        )

    return failures


def main() -> int:
    args = parse_args()
    adapters = [name.strip() for name in args.adapters.split(",") if name.strip()]
    if not adapters:
        print("No adapters requested.", file=sys.stderr)
        return 2

    cases_dir = Path(args.cases_dir)
    cases = load_cases(cases_dir)

    total_failures = 0
    executed_adapters: list[str] = []

    for case in cases:
        case_id = case["id"]
        responses: dict[str, dict[str, Any]] = {}

        for adapter in adapters:
            response = run_adapter(adapter, case)
            if "invoke_error" in response and args.allow_missing_adapters:
                print(f"SKIP adapter={adapter} case={case_id}: {response['invoke_error']}")
                continue
            responses[adapter] = response

        if not responses:
            print(f"CASE {case_id}: SKIP (no adapters executed)")
            continue

        for adapter in responses.keys():
            if adapter not in executed_adapters:
                executed_adapters.append(adapter)

        failures = compare_case(case, responses)
        if failures:
            total_failures += len(failures)
            print(f"CASE {case_id}: FAIL ({len(failures)} issue(s))")
            for failure in failures:
                print(f"  - {failure}")
        else:
            print(f"CASE {case_id}: PASS")

    print("-")
    print(f"Cases: {len(cases)}")
    print(f"Adapters executed: {', '.join(executed_adapters) if executed_adapters else '(none)'}")

    if total_failures:
        print(f"Result: FAIL ({total_failures} total issue(s))")
        return 1

    print("Result: PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
