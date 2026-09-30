import json
from pathlib import Path

import pytest

from tools.gatekeeper.gatekeeper import (
    SuiteResult,
    build_parser,
    build_summary,
    enforce_skip_ci,
    run_schema_suite,
    write_summary,
)


def test_schema_parser_error_is_captured(tmp_path: Path):
    root = tmp_path
    generator = root / "tools" / "data_generator"
    output = generator / "output"
    output.mkdir(parents=True)
    (generator / "schema.json").write_text(
        json.dumps({"type": "object", "required": ["entries"], "properties": {"entries": {"type": "array"}}}),
        encoding="utf-8",
    )
    (output / "broken.json").write_text('{"entries": [}', encoding="utf-8")

    result = run_schema_suite(root)

    assert result.status == "failed"
    assert result.checked == 1
    assert any("JSON parse error" in reason for reason in result.failures)
    assert any("broken.json" in reason for reason in result.failures)


def test_report_file_generation_records_failures_duration_and_skip_ci(tmp_path: Path):
    suite = SuiteResult(
        name="python",
        status="failed",
        duration_seconds=0.125,
        failures=["tests/test_example.py::test_bad: assertion failed"],
        command=["python", "-m", "pytest", "-q"],
        checked=3,
    )
    summary = build_summary("python-only", [suite], commit_proposal="feat: local verification")
    report_path = tmp_path / "reports" / "local_gate_summary.json"

    write_summary(summary, report_path)
    saved = json.loads(report_path.read_text(encoding="utf-8"))

    assert saved["mode"] == "python-only"
    assert saved["overall_status"] == "failed"
    assert saved["duration_seconds"] == pytest.approx(0.125)
    assert saved["failure_reasons"] == ["python: tests/test_example.py::test_bad: assertion failed"]
    assert saved["commit_policy"]["required_marker"] == "[skip ci]"
    assert saved["commit_policy"]["proposal"].endswith("[skip ci]")
    assert saved["timestamp"].endswith("Z")
    assert saved["suites"][0]["checked"] == 3


def test_skip_ci_enforcement_is_idempotent():
    assert enforce_skip_ci("feat: gate") == "feat: gate [skip ci]"
    assert enforce_skip_ci("feat: gate [skip ci]") == "feat: gate [skip ci]"


def test_cli_modes_are_mutually_exclusive():
    parser = build_parser()
    args = parser.parse_args(["--schemas-only"])
    assert args.schemas_only is True
    with pytest.raises(SystemExit):
        parser.parse_args(["--python-only", "--full"])
