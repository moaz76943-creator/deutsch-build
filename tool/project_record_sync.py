#!/usr/bin/env python3
"""Synchronize durable project-record runtime evidence from Git and CI events."""

from __future__ import annotations

import argparse
import json
import os
import subprocess
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
RECORD_DIR = ROOT / "docs" / "project-record"
RUNTIME_PATH = RECORD_DIR / "runtime.json"
EVENTS_PATH = RECORD_DIR / "events.ndjson"

def run(*args: str) -> str:
    return subprocess.check_output(args, cwd=ROOT, text=True).strip()

def git(*args: str) -> str:
    return run("git", *args)

def now() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")

CANONICAL_BRANCH = "main"
CANONICAL_RUNTIME_WORKFLOWS = frozenset({"Engineering CI", "Recovery Checkpoint"})

def should_promote_to_canonical_runtime(
    workflow: str,
    branch: str | None,
    workflow_head_sha: str,
    current_sha: str,
) -> bool:
    """Return whether workflow evidence can update canonical runtime pointers."""
    if (
        workflow not in CANONICAL_RUNTIME_WORKFLOWS
        or branch != CANONICAL_BRANCH
        or not workflow_head_sha
    ):
        return False
    return reachable(workflow_head_sha, current_sha)

def load_runtime() -> dict[str, Any]:
    if not RUNTIME_PATH.exists():
        return {}
    return json.loads(RUNTIME_PATH.read_text(encoding="utf-8"))

def save_runtime(data: dict[str, Any]) -> None:
    RUNTIME_PATH.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

def load_event_keys() -> set[str]:
    keys: set[str] = set()
    if not EVENTS_PATH.exists():
        return keys
    for line in EVENTS_PATH.read_text(encoding="utf-8").splitlines():
        if not line.strip():
            continue
        try:
            obj = json.loads(line)
        except json.JSONDecodeError:
            continue
        if obj.get("event_key"):
            keys.add(str(obj["event_key"]))
    return keys

def append_event(event: dict[str, Any], keys: set[str]) -> bool:
    key = str(event["event_key"])
    if key in keys:
        return False
    with EVENTS_PATH.open("a", encoding="utf-8") as f:
        f.write(json.dumps(event, ensure_ascii=False, sort_keys=True) + "\n")
    keys.add(key)
    return True

def reachable(old_sha: str, new_sha: str) -> bool:
    if not old_sha:
        return True
    proc = subprocess.run(["git", "merge-base", "--is-ancestor", old_sha, new_sha], cwd=ROOT, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    return proc.returncode == 0

def source_commits_since(last_source_commit: str | None, current_sha: str) -> list[dict[str, str]]:
    if not last_source_commit or not reachable(last_source_commit, current_sha):
        return []
    fmt = "%H%x1f%an%x1f%aI%x1f%s%x1f%P"
    out = git("log", "--first-parent", f"--pretty=format:{fmt}", f"{last_source_commit}..{current_sha}", "--", ".", ":(exclude)docs/project-record/runtime.json", ":(exclude)docs/project-record/events.ndjson")
    rows: list[dict[str, str]] = []
    for line in out.splitlines():
        parts = line.split("\x1f", 4)
        if len(parts) != 5:
            continue
        sha, author, authored_at, subject, parents = parts
        rows.append({"sha": sha, "author": author, "authored_at": authored_at, "subject": subject, "parents": parents})
    return list(reversed(rows))

def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--trigger", default=os.getenv("GITHUB_EVENT_NAME", "manual"))
    parser.add_argument("--run-id", default=os.getenv("PROJECT_RECORD_RUN_ID", ""))
    parser.add_argument("--workflow", default=os.getenv("PROJECT_RECORD_WORKFLOW", ""))
    parser.add_argument("--conclusion", default=os.getenv("PROJECT_RECORD_CONCLUSION", ""))
    parser.add_argument("--workflow-head-sha", default=os.getenv("PROJECT_RECORD_HEAD_SHA", ""))
    parser.add_argument("--workflow-branch", default=os.getenv("PROJECT_RECORD_BRANCH", ""))
    args = parser.parse_args()

    RECORD_DIR.mkdir(parents=True, exist_ok=True)
    runtime = load_runtime()
    keys = load_event_keys()
    current_sha = git("rev-parse", "HEAD")
    previous_source = runtime.get("last_source_commit")
    gap = bool(previous_source) and not reachable(str(previous_source), current_sha)
    source_rows = source_commits_since(str(previous_source) if previous_source else None, current_sha)
    added_commits = 0
    source_head = str(previous_source) if previous_source else None
    if not gap and not previous_source:
        baseline_event = {
            "event_key": f"baseline:{current_sha}",
            "timestamp": now(),
            "source": "github",
            "type": "baseline",
            "commit_sha": current_sha,
            "message": "Initial project-record baseline; earlier repository history was not replayed into the event ledger.",
            "evidence": f"https://github.com/sali97m-cpu/deutsch-bilarabi/commit/{current_sha}"
        }
        append_event(baseline_event, keys)
        source_head = current_sha
    if not gap:
        for row in source_rows:
            if row["subject"].startswith("ops: project-record sync"):
                continue
            commit_sha = row["sha"]
            source_head = commit_sha
            event = {
                "event_key": f"commit:{commit_sha}",
                "timestamp": now(),
                "source": "github",
                "type": "commit",
                "commit_sha": row["sha"],
                "author": row["author"],
                "authored_at": row["authored_at"],
                "subject": row["subject"],
                "trigger": args.trigger,
                "workflow": args.workflow,
                "run_id": args.run_id,
                "evidence": f"https://github.com/sali97m-cpu/deutsch-bilarabi/commit/{commit_sha}"
            }
            added_commits += append_event(event, keys)

    if args.run_id and args.conclusion:
        wf_key = f"workflow:{args.workflow}:{args.run_id}"
        wf_event = {"event_key": wf_key, "timestamp": now(), "source": "github_actions", "type": "workflow_run", "workflow": args.workflow, "run_id": args.run_id, "conclusion": args.conclusion, "commit_sha": args.workflow_head_sha or current_sha, "branch": args.workflow_branch or None}
        append_event(wf_event, keys)
        if should_promote_to_canonical_runtime(
            args.workflow,
            args.workflow_branch,
            args.workflow_head_sha,
            current_sha,
        ):
            if args.workflow == "Engineering CI":
                runtime["last_ci"] = wf_event
            elif args.workflow == "Recovery Checkpoint":
                runtime["last_recovery_checkpoint_run"] = wf_event

    runtime.update({
        "record_status": "RECONCILIATION_REQUIRED" if gap else "CURRENT",
        "reconciliation_required": gap,
        "reconciliation_reason": "Recorded source commit is not an ancestor of current main; history/lineage changed." if gap else None,
        "last_source_commit": source_head,
        "last_observed_head": current_sha,
        "last_sync_at": now(),
        "last_sync_event": {"trigger": args.trigger, "workflow": args.workflow, "run_id": args.run_id, "conclusion": args.conclusion or None},
        "observed_source_commit_count": len(source_rows)
    })
    save_runtime(runtime)
    print(json.dumps({"current_sha": current_sha, "source_events_added": added_commits, "source_commits_observed": len(source_rows), "reconciliation_required": gap, "record_status": runtime["record_status"]}, ensure_ascii=False))
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
