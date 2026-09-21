#!/usr/bin/env python3
"""Append one structured local project-record event for a verified local runner."""

from __future__ import annotations

import argparse
import json
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
EVENTS = ROOT / "docs" / "project-record" / "events.ndjson"

TASK_EVENT_STATUS = {
    "task_started": "started",
    "task_completed": "completed",
    "task_failed": "failed",
}
TERMINAL_TASK_TYPES = {"task_completed", "task_failed"}


def load_task_events(task_id: str, path: Path = EVENTS) -> list[dict[str, Any]]:
    """Read durable task events for one task_id, ignoring malformed ledger lines."""
    if not path.exists():
        return []

    matches: list[dict[str, Any]] = []
    for line in path.read_text(encoding="utf-8").splitlines():
        if not line.strip():
            continue
        try:
            event = json.loads(line)
        except json.JSONDecodeError:
            continue
        if event.get("task_id") == task_id and event.get("type") in TASK_EVENT_STATUS:
            matches.append(event)
    return matches


def validate_task_transition(
    event_type: str,
    status: str | None,
    task_id: str | None,
    evidence: str | None,
    *,
    path: Path = EVENTS,
) -> None:
    """Fail closed on duplicate or invalid task lifecycle transitions.

    Generic local-runner events remain backward compatible. The stricter
    checks apply only to the approved task_started/task_completed/task_failed
    contract.
    """
    if event_type not in TASK_EVENT_STATUS:
        return

    if not task_id or not task_id.strip():
        raise ValueError(f"{event_type} requires a stable --task-id")

    expected_status = TASK_EVENT_STATUS[event_type]
    if status != expected_status:
        raise ValueError(
            f"{event_type} requires --status {expected_status!r}; got {status!r}"
        )

    if not evidence or not evidence.strip():
        raise ValueError(f"{event_type} requires non-empty --evidence")

    history = load_task_events(task_id, path)
    terminal = next(
        (event for event in history if event.get("type") in TERMINAL_TASK_TYPES),
        None,
    )
    if terminal is not None:
        terminal_type = terminal.get("type")
        raise ValueError(
            f"task_id {task_id!r} already has terminal event {terminal_type!r}; "
            "do not execute it again"
        )

    started = any(event.get("type") == "task_started" for event in history)
    if event_type == "task_started":
        if started:
            raise ValueError(
                f"task_id {task_id!r} is already started without a terminal event; "
                "resume from durable evidence/checkpoint instead of starting a duplicate"
            )
        return

    if not started:
        raise ValueError(
            f"{event_type} for task_id {task_id!r} requires a prior task_started event"
        )


def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("--type", required=True)
    p.add_argument("--status")
    p.add_argument("--task-id")
    p.add_argument("--message")
    p.add_argument("--evidence")
    p.add_argument("--commit", action="store_true")
    args = p.parse_args()
    EVENTS.parent.mkdir(parents=True, exist_ok=True)

    try:
        validate_task_transition(
            args.type,
            args.status,
            args.task_id,
            args.evidence,
            path=EVENTS,
        )
    except ValueError as exc:
        print(
            json.dumps(
                {
                    "ok": False,
                    "error": "invalid_task_transition",
                    "message": str(exc),
                    "task_id": args.task_id,
                    "type": args.type,
                },
                ensure_ascii=False,
                sort_keys=True,
            ),
            file=sys.stderr,
        )
        return 2

    ts = datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")
    task_key = args.task_id or ""
    event = {
        "event_key": f"local:{ts}:{args.type}:{task_key}",
        "timestamp": ts,
        "source": "local_runner",
        "type": args.type,
        "status": args.status,
        "task_id": args.task_id,
        "message": args.message,
        "evidence": args.evidence,
    }
    with EVENTS.open("a", encoding="utf-8") as f:
        f.write(json.dumps(event, ensure_ascii=False, sort_keys=True) + "\n")
    if args.commit:
        subprocess.run(["git", "add", str(EVENTS.relative_to(ROOT))], cwd=ROOT, check=True)
        subprocess.run(
            ["git", "commit", "-m", f"ops: record project event {args.type}"],
            cwd=ROOT,
            check=True,
        )
    print(json.dumps(event, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
