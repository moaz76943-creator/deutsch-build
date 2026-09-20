#!/usr/bin/env python3
"""Append one structured local project-record event for a verified local runner."""

from __future__ import annotations

import argparse
import json
import subprocess
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
EVENTS = ROOT / "docs" / "project-record" / "events.ndjson"

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
    ts = datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")
    task_key = args.task_id or ""
    event = {"event_key": f"local:{ts}:{args.type}:{task_key}", "timestamp": ts, "source": "local_runner", "type": args.type, "status": args.status, "task_id": args.task_id, "message": args.message, "evidence": args.evidence}
    with EVENTS.open("a", encoding="utf-8") as f:
        f.write(json.dumps(event, ensure_ascii=False, sort_keys=True) + "\n")
    if args.commit:
        subprocess.run(["git", "add", str(EVENTS.relative_to(ROOT))], cwd=ROOT, check=True)
        subprocess.run(["git", "commit", "-m", f"ops: record project event {args.type}"], cwd=ROOT, check=True)
    print(json.dumps(event, ensure_ascii=False))
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
