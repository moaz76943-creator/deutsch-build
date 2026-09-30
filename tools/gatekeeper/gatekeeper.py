#!/usr/bin/env python3
"""Unified local quality gatekeeper."""
from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
import sys
import time
from dataclasses import asdict, dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Iterable, Mapping, Sequence

DEFAULT_REPORT = Path("reports/local_gate_summary.json")
SKIP_CI = "[skip ci]"


@dataclass(frozen=True)
class SuiteResult:
    name: str
    status: str
    duration_seconds: float
    failures: list[str]
    command: list[str]
    checked: int = 0

    def to_dict(self) -> dict[str, Any]:
        return asdict(self)


class SchemaValidationError(ValueError):
    pass


def enforce_skip_ci(proposal: str) -> str:
    proposal = proposal.strip()
    if SKIP_CI.lower() in proposal.lower():
        return proposal
    return f"{proposal} {SKIP_CI}".strip()


def parse_pytest_failures(stdout: str, stderr: str, returncode: int) -> list[str]:
    if returncode == 0:
        return []
    lines = [line.strip() for line in f"{stdout}\n{stderr}".splitlines() if line.strip()]
    selected = []
    for line in lines:
        if re.match(r"^(FAILED|ERROR)\b", line) or line.startswith(("E   ", "ImportError", "ModuleNotFoundError")):
            if line not in selected:
                selected.append(line)
    if selected:
        return selected[:50]
    detail = " | ".join(lines[-8:]) if lines else "no pytest output captured"
    return [f"pytest exited with code {returncode}: {detail}"]


def run_python_suite(repo_root: str | Path, *, timeout_seconds: int = 900) -> SuiteResult:
    command = [sys.executable, "-m", "pytest", "-q"]
    started = time.perf_counter()
    try:
        result = subprocess.run(
            command,
            cwd=Path(repo_root).resolve(),
            capture_output=True,
            text=True,
            timeout=timeout_seconds,
            check=False,
        )
        failures = parse_pytest_failures(result.stdout, result.stderr, result.returncode)
        status = "passed" if result.returncode == 0 else "failed"
    except subprocess.TimeoutExpired:
        failures, status = [f"pytest timed out after {timeout_seconds} seconds"], "failed"
    except OSError as exc:
        failures, status = [f"pytest could not start: {exc}"], "failed"
    return SuiteResult("python", status, round(time.perf_counter() - started, 6), failures, command)


def _load_json(path: Path) -> Any:
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        raise SchemaValidationError(
            f"{path}: JSON parse error at line {exc.lineno}, column {exc.colno}: {exc.msg}"
        ) from exc
    except OSError as exc:
        raise SchemaValidationError(f"{path}: unable to read JSON: {exc}") from exc


def _type_ok(value: Any, expected: str) -> bool:
    return {
        "object": isinstance(value, dict),
        "array": isinstance(value, list),
        "string": isinstance(value, str),
        "boolean": isinstance(value, bool),
        "integer": isinstance(value, int) and not isinstance(value, bool),
        "number": isinstance(value, (int, float)) and not isinstance(value, bool),
        "null": value is None,
    }.get(expected, True)


def validate_document(value: Any, schema: Mapping[str, Any], path: str = "$") -> None:
    expected = schema.get("type")
    if isinstance(expected, str) and not _type_ok(value, expected):
        raise SchemaValidationError(f"{path}: expected type {expected}")
    if "const" in schema and value != schema["const"]:
        raise SchemaValidationError(f"{path}: expected constant {schema['const']!r}")
    if "enum" in schema and value not in schema["enum"]:
        raise SchemaValidationError(f"{path}: value {value!r} is not in enum")

    if isinstance(value, str):
        if len(value) < int(schema.get("minLength", 0)):
            raise SchemaValidationError(f"{path}: shorter than minLength {schema['minLength']}")
        if "pattern" in schema and re.search(str(schema["pattern"]), value) is None:
            raise SchemaValidationError(f"{path}: does not match pattern {schema['pattern']!r}")

    if isinstance(value, list):
        if len(value) < int(schema.get("minItems", 0)):
            raise SchemaValidationError(f"{path}: has fewer than {schema['minItems']} items")
        item_schema = schema.get("items")
        if isinstance(item_schema, Mapping):
            for index, item in enumerate(value):
                validate_document(item, item_schema, f"{path}[{index}]")

    if isinstance(value, dict):
        properties = schema.get("properties", {})
        for key in schema.get("required", []):
            if key not in value:
                raise SchemaValidationError(f"{path}: missing required property {key!r}")
        if isinstance(properties, Mapping):
            for key, child in properties.items():
                if key in value and isinstance(child, Mapping):
                    validate_document(value[key], child, f"{path}.{key}")
            if schema.get("additionalProperties") is False:
                extras = sorted(set(value) - set(properties))
                if extras:
                    raise SchemaValidationError(f"{path}: unexpected properties {extras}")


def _datasets_for(schema_path: Path) -> list[Path]:
    found: set[Path] = set()
    for name in ("output", "fixtures", "canonical"):
        directory = schema_path.parent / name
        if directory.is_dir():
            found.update(path for path in directory.rglob("*.json") if path.is_file())
    found.update(schema_path.parent.glob("*.dataset.json"))
    return sorted(found)


def run_schema_suite(repo_root: str | Path) -> SuiteResult:
    root = Path(repo_root).resolve()
    started = time.perf_counter()
    failures: list[str] = []
    checked = 0
    schemas = sorted(path for path in root.glob("tools/**/schema.json") if path.is_file())
    if not schemas:
        failures.append("no JSON schemas found under tools/**/schema.json")

    for schema_path in schemas:
        try:
            schema = _load_json(schema_path)
            if not isinstance(schema, Mapping):
                raise SchemaValidationError(f"{schema_path}: schema root must be an object")
        except SchemaValidationError as exc:
            failures.append(str(exc))
            continue
        datasets = _datasets_for(schema_path)
        if not datasets:
            failures.append(f"{schema_path.relative_to(root)}: no canonical JSON datasets discovered")
            continue
        for dataset_path in datasets:
            checked += 1
            try:
                validate_document(_load_json(dataset_path), schema)
            except SchemaValidationError as exc:
                failures.append(str(exc))

    return SuiteResult(
        "schemas",
        "failed" if failures else "passed",
        round(time.perf_counter() - started, 6),
        failures,
        ["local-json-schema-validation"],
        checked,
    )


def build_summary(mode: str, suites: Iterable[SuiteResult], *, commit_proposal: str | None = None) -> dict[str, Any]:
    suites = list(suites)
    reasons = [f"{suite.name}: {reason}" for suite in suites for reason in suite.failures]
    return {
        "timestamp": datetime.now(timezone.utc).isoformat(timespec="seconds").replace("+00:00", "Z"),
        "mode": mode,
        "overall_status": "passed" if suites and all(s.status == "passed" for s in suites) else "failed",
        "duration_seconds": round(sum(s.duration_seconds for s in suites), 6),
        "failure_reasons": reasons,
        "suites": [s.to_dict() for s in suites],
        "commit_policy": {
            "local_only": True,
            "required_marker": SKIP_CI,
            "proposal": enforce_skip_ci(commit_proposal) if commit_proposal is not None else None,
        },
    }


def write_summary(summary: Mapping[str, Any], report_path: str | Path = DEFAULT_REPORT) -> Path:
    path = Path(report_path)
    path.parent.mkdir(parents=True, exist_ok=True)
    temp = path.with_name(f".{path.name}.tmp")
    temp.write_text(json.dumps(summary, ensure_ascii=False, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    os.replace(temp, path)
    return path


def run_gatekeeper(
    repo_root: str | Path,
    *,
    mode: str = "full",
    report_path: str | Path = DEFAULT_REPORT,
    commit_proposal: str | None = None,
) -> dict[str, Any]:
    if mode not in {"python-only", "schemas-only", "full"}:
        raise ValueError(f"unsupported gatekeeper mode: {mode}")
    suites: list[SuiteResult] = []
    if mode in {"python-only", "full"}:
        suites.append(run_python_suite(repo_root))
    if mode in {"schemas-only", "full"}:
        suites.append(run_schema_suite(repo_root))
    summary = build_summary(mode, suites, commit_proposal=commit_proposal)
    write_summary(summary, report_path)
    return summary


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Run the unified local quality gatekeeper")
    group = parser.add_mutually_exclusive_group()
    group.add_argument("--python-only", action="store_true")
    group.add_argument("--schemas-only", action="store_true")
    group.add_argument("--full", action="store_true")
    parser.add_argument("--repo-root", type=Path, default=Path("."))
    parser.add_argument("--report", type=Path, default=DEFAULT_REPORT)
    parser.add_argument("--commit-proposal", help="[skip ci] is appended automatically")
    return parser


def main(argv: Sequence[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    mode = "python-only" if args.python_only else "schemas-only" if args.schemas_only else "full"
    summary = run_gatekeeper(args.repo_root, mode=mode, report_path=args.report, commit_proposal=args.commit_proposal)
    print(json.dumps(summary, ensure_ascii=False, sort_keys=True))
    return 0 if summary["overall_status"] == "passed" else 1


if __name__ == "__main__":
    raise SystemExit(main())
