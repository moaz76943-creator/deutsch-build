#!/usr/bin/env python3
"""Unified, fail-safe runner for the repository automation lifecycle."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
import subprocess
import sys
from typing import Any, Mapping, Sequence

DEFAULT_REPO_ROOT = Path(__file__).resolve().parents[2]


class PipelineError(RuntimeError):
    """Base error for orchestrator failures."""


class PipelineToolError(PipelineError):
    """Raised when an auxiliary lifecycle tool cannot complete successfully."""


class PipelineStateError(PipelineError):
    """Raised when the pipeline state cannot be read safely."""


def _parse_json_output(tool_name: str, stdout: str) -> dict[str, Any]:
    lines = [line.strip() for line in stdout.splitlines() if line.strip()]
    if not lines:
        raise PipelineToolError(f"{tool_name} produced no JSON output")
    try:
        payload = json.loads(lines[-1])
    except json.JSONDecodeError as exc:
        raise PipelineToolError(f"{tool_name} produced invalid JSON output: {exc}") from exc
    if not isinstance(payload, dict):
        raise PipelineToolError(f"{tool_name} JSON output must be an object")
    return payload


class PipelineOrchestrator:
    """Compose state validation, dependency dispatch, and local quality gates."""

    def __init__(self, *, repo_root: str | Path = DEFAULT_REPO_ROOT) -> None:
        self.repo_root = Path(repo_root).resolve()
        self.automation_dir = self.repo_root / "tools" / "automation"
        self.state_file = self.automation_dir / "pipeline_state.json"
        self.backlog_file = self.automation_dir / "backlog.json"
        self.claims_file = self.automation_dir / "claims.json"
        self.dispatch_dir = self.automation_dir / "dispatches"
        self.runtime = self.automation_dir / "runtime.py"
        self.gatekeeper = self.repo_root / "tools" / "gatekeeper" / "gatekeeper.py"
        self.gate_report = self.automation_dir / ".pipeline_gate_summary.json"

    def _load_state(self) -> dict[str, Any]:
        try:
            payload = json.loads(self.state_file.read_text(encoding="utf-8"))
        except FileNotFoundError as exc:
            raise PipelineStateError(f"pipeline state not found: {self.state_file}") from exc
        except (OSError, json.JSONDecodeError) as exc:
            raise PipelineStateError(f"cannot read pipeline state {self.state_file}: {exc}") from exc
        if not isinstance(payload, dict) or not isinstance(payload.get("tasks"), list):
            raise PipelineStateError("pipeline state must be an object with a tasks array")
        return payload

    def _run_tool(self, name: str, script: Path, args: Sequence[str]) -> dict[str, Any]:
        if not script.is_file():
            raise PipelineToolError(f"{name} tool not found: {script}")
        command = [sys.executable, str(script), *map(str, args)]
        try:
            completed = subprocess.run(
                command,
                cwd=self.repo_root,
                capture_output=True,
                text=True,
                check=False,
            )
        except OSError as exc:
            raise PipelineToolError(f"{name} could not start: {exc}") from exc
        if completed.returncode != 0:
            detail = completed.stderr.strip() or completed.stdout.strip() or "no output"
            raise PipelineToolError(f"{name} exited with code {completed.returncode}: {detail}")
        return _parse_json_output(name, completed.stdout)

    def _validate_state(self) -> dict[str, Any]:
        return self._run_tool(
            "automation_runtime",
            self.runtime,
            ["state", "--state", str(self.state_file), "validate"],
        )

    def _daemon_args(self, mode: str) -> list[str]:
        if mode not in {"--dry-run", "--poll-once"}:
            raise ValueError(f"unsupported daemon mode: {mode}")
        return [
            "dispatch",
            "--backlog",
            str(self.backlog_file),
            "--state-file",
            str(self.state_file),
            "--claims",
            str(self.claims_file),
            "--dispatch-dir",
            str(self.dispatch_dir),
            mode,
        ]

    def _run_gatekeeper(self) -> dict[str, Any]:
        summary = self._run_tool(
            "gatekeeper",
            self.gatekeeper,
            [
                "--full",
                "--repo-root",
                str(self.repo_root),
                "--report",
                str(self.gate_report),
            ],
        )
        if summary.get("overall_status") != "passed":
            raise PipelineToolError("gatekeeper completed without a passing overall_status")
        return summary

    @staticmethod
    def _is_complete(state: Mapping[str, Any]) -> bool:
        tasks = state.get("tasks", [])
        return bool(tasks) and all(
            isinstance(task, Mapping) and task.get("status") == "COMPLETED"
            for task in tasks
        )

    def cycle(self) -> dict[str, Any]:
        """Run one deterministic pipeline tick without mutating before gates pass."""
        self._validate_state()
        before = self._load_state()
        if self._is_complete(before):
            return {"state": "COMPLETE", "task_count": len(before["tasks"])}

        resolution = self._run_tool(
            "automation_runtime",
            self.runtime,
            self._daemon_args("--dry-run"),
        )
        resolution_state = resolution.get("state")
        if resolution_state not in {"DRY_RUN", "NO_CANDIDATE"}:
            raise PipelineToolError(
                f"automation runtime returned unexpected dry-run state: {resolution_state!r}"
            )

        gate = self._run_gatekeeper()

        if resolution_state == "NO_CANDIDATE":
            self._validate_state()
            current = self._load_state()
            return {
                "state": "COMPLETE" if self._is_complete(current) else "IDLE",
                "gate": gate,
            }

        planned_task = resolution.get("task_id")
        if not isinstance(planned_task, str) or not planned_task:
            raise PipelineToolError("automation runtime dry-run omitted task_id")

        committed = self._run_tool(
            "automation_runtime",
            self.runtime,
            self._daemon_args("--poll-once"),
        )
        committed_state = committed.get("state")
        if committed_state == "NO_CANDIDATE":
            self._validate_state()
            return {"state": "IDLE", "gate": gate, "planned_task_id": planned_task}
        if committed_state != "DISPATCHED":
            raise PipelineToolError(
                f"automation runtime returned unexpected commit state: {committed_state!r}"
            )

        dispatched_task = committed.get("task_id")
        if not isinstance(dispatched_task, str) or not dispatched_task:
            raise PipelineToolError("automation runtime dispatch omitted task_id")

        self._validate_state()
        return {
            "state": "DISPATCHED",
            "task_id": dispatched_task,
            "planned_task_id": planned_task,
            "gate": gate,
        }


def _build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Run the unified local automation pipeline")
    parser.add_argument("--cycle", action="store_true", required=True)
    parser.add_argument(
        "--repo-root",
        type=Path,
        default=DEFAULT_REPO_ROOT,
        help="repository root; defaults to the root containing this script",
    )
    return parser


def main(argv: Sequence[str] | None = None) -> int:
    args = _build_parser().parse_args(argv)
    try:
        result = PipelineOrchestrator(repo_root=args.repo_root).cycle()
    except Exception as exc:  # CLI boundary: all unexpected failures map to status 1.
        print(
            json.dumps(
                {"state": "ERROR", "error": str(exc), "error_type": type(exc).__name__},
                ensure_ascii=False,
                sort_keys=True,
            ),
            file=sys.stderr,
        )
        return 1
    print(json.dumps(result, ensure_ascii=False, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
