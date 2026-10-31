#!/usr/bin/env python3
"""Bounded local end-to-end validation for the automation control plane."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
import tempfile
from typing import Any, Sequence

try:
    from .autonomous_daemon import AutonomousDispatcher
    from .state_manager import read_task, update_task
except ImportError:  # Direct script execution.
    from autonomous_daemon import AutonomousDispatcher  # type: ignore
    from state_manager import read_task, update_task  # type: ignore


def _write_json(path: Path, value: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def _run(root: Path) -> dict[str, Any]:
    automation = root / "tools" / "automation"
    backlog_path = automation / "backlog.json"
    state_path = automation / "pipeline_state.json"
    claims_path = automation / "claims.json"
    dispatch_dir = automation / "dispatches"

    _write_json(
        backlog_path,
        {
            "schema_version": 1,
            "tasks": [
                {
                    "task_id": "READY_TASK",
                    "status": "PENDING",
                    "branch": "automation/mock-ready-task",
                    "prerequisites": [],
                    "external_prerequisites": [],
                    "allowed_paths": ["tools/automation/**"],
                }
            ],
        },
    )
    _write_json(
        state_path,
        {
            "schema_version": 1,
            "tasks": [
                {
                    "task_id": "READY_TASK",
                    "status": "PENDING",
                    "branch": "automation/mock-ready-task",
                    "commit_sha": "",
                    "test_count": 0,
                    "dependent_tasks": [],
                }
            ],
        },
    )

    dispatcher = AutonomousDispatcher(
        backlog_path=backlog_path,
        state_path=state_path,
        claims_path=claims_path,
        dispatch_dir=dispatch_dir,
    )
    dry_run = dispatcher.poll_once(dry_run=True)
    if dry_run.get("state") != "DRY_RUN" or dry_run.get("task_id") != "READY_TASK":
        raise RuntimeError(f"unexpected dry-run result: {dry_run}")

    dispatched = dispatcher.poll_once()
    if dispatched != {"state": "DISPATCHED", "task_id": "READY_TASK"}:
        raise RuntimeError(f"unexpected dispatch result: {dispatched}")

    updated = update_task(state_path, "READY_TASK", "COMPLETED", "e" * 40, 1)
    snapshot = read_task(state_path, "READY_TASK")
    claims = json.loads(claims_path.read_text(encoding="utf-8"))
    dispatch = json.loads((dispatch_dir / "READY_TASK.dispatch.json").read_text(encoding="utf-8"))

    if snapshot["task"]["status"] != "COMPLETED":
        raise RuntimeError("ledger did not persist COMPLETED state")
    if len(claims.get("claims", [])) != 1:
        raise RuntimeError("claim lifecycle did not produce exactly one claim")
    if dispatch.get("task_id") != "READY_TASK":
        raise RuntimeError("dispatch payload task identity drifted")

    return {
        "status": "PASS",
        "dry_run_state": dry_run["state"],
        "dispatch_state": dispatched["state"],
        "task_id": updated["task_id"],
        "claim_count": len(claims["claims"]),
        "ledger_status": snapshot["task"]["status"],
        "provider_calls_executed": 0,
        "billing_changes": 0,
    }


def run_e2e_validation(work_root: str | Path | None = None) -> dict[str, Any]:
    if work_root is not None:
        return _run(Path(work_root).resolve())
    with tempfile.TemporaryDirectory(prefix="deutsch-ae-e2e-") as temp_dir:
        return _run(Path(temp_dir))


def _build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Run bounded local automation E2E validation")
    parser.add_argument("--work-root", type=Path)
    parser.add_argument("--report", action="store_true")
    return parser


def main(argv: Sequence[str] | None = None) -> int:
    args = _build_parser().parse_args(argv)
    try:
        report = run_e2e_validation(args.work_root)
    except Exception as exc:
        if args.report:
            print(json.dumps({"status": "FAIL", "error": str(exc)}, ensure_ascii=False, sort_keys=True))
        return 1
    if args.report:
        print(json.dumps(report, ensure_ascii=False, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
