#!/usr/bin/env python3
import argparse
import subprocess
import json
import sys
import os
from pathlib import PurePosixPath

ALLOWED_PATHS = [
    "AGENTS.md",
    "docs/project-record/",
    "tools/agent_contract/"
]

VALID_TRANSITIONS = {
    "CLAIM": ["ACTIVE", "BLOCKED"],
    "ACTIVE": ["COMPLETE", "BLOCKED"],
    "BLOCKED": ["ACTIVE", "COMPLETE"],
    "COMPLETE": []
}

REPO_ROOT = os.path.abspath(os.getcwd())

def get_changed_files(base_sha, result_sha="HEAD"):
    cmd = ["git", "diff", "--name-only", f"{base_sha}...{result_sha}"]
    try:
        output = subprocess.check_output(cmd, text=True, stderr=subprocess.PIPE)
        return [line.strip() for line in output.splitlines() if line.strip()]
    except subprocess.CalledProcessError as e:
        raise ValueError(f"Git diff failed or stale base SHA. Ensure BASE_SHA is valid. Error: {e.stderr}")

def is_path_allowed(path_str):
    p = PurePosixPath(path_str)
    if ".." in p.parts or p.is_absolute():
        return False

    path_str = str(p)
    if path_str == "AGENTS.md":
        return True
    if path_str.startswith("docs/project-record/"):
        return True
    if path_str.startswith("tools/agent_contract/"):
        return True
    return False

def is_symlink_safe(path_str):
    if not os.path.islink(path_str):
        return True

    target = os.path.realpath(path_str)
    if not target.startswith(REPO_ROOT):
        return False

    rel_target = os.path.relpath(target, REPO_ROOT)
    rel_target = rel_target.replace(os.sep, "/")
    return is_path_allowed(rel_target)

def check_overlapping_claims(ledger, task_id, changed_files):
    for other_task, data in ledger.items():
        if other_task == task_id:
            continue
        if data.get("state") in ["CLAIM", "ACTIVE"]:
            other_paths = data.get("paths", [])
            for p in changed_files:
                if p in other_paths:
                    return True, f"File {p} is currently claimed by {other_task}"
    return False, ""

def load_ledger(path):
    if os.path.exists(path):
        with open(path, "r") as f:
            return json.load(f)
    return {}

def save_ledger(path, ledger):
    os.makedirs(os.path.dirname(os.path.abspath(path)), exist_ok=True)
    with open(path, "w") as f:
        json.dump(ledger, f, indent=2)

def main(args=None):
    if args is None:
        args = sys.argv[1:]

    parser = argparse.ArgumentParser(description="Repository governance guard")
    parser.add_argument("--task-id", required=True)
    parser.add_argument("--base-sha", required=True)
    parser.add_argument("--result-sha", default="HEAD")
    parser.add_argument("--transition", choices=["CLAIM", "ACTIVE", "COMPLETE", "BLOCKED"], required=True)
    parser.add_argument("--ledger", default="tools/agent_contract/task_ledger.json")
    parser.add_argument("--report", default="tools/agent_contract/evidence_report.json")

    parsed = parser.parse_args(args)

    report = {
        "task_id": parsed.task_id,
        "base_sha": parsed.base_sha,
        "result_sha": parsed.result_sha,
        "transition": parsed.transition,
        "permitted_paths": [],
        "denied_paths": [],
        "blockers": []
    }

    try:
        changed_files = get_changed_files(parsed.base_sha, parsed.result_sha)
    except ValueError as e:
        report["blockers"].append(str(e))
        save_ledger(parsed.report, report)
        print(f"Error: {e}", file=sys.stderr)
        return 1

    for p in changed_files:
        if is_path_allowed(p):
            if os.path.exists(p) and not is_symlink_safe(p):
                report["denied_paths"].append(p)
                report["blockers"].append(f"Symlink {p} points to forbidden path")
            else:
                report["permitted_paths"].append(p)
        else:
            report["denied_paths"].append(p)

    if report["denied_paths"]:
        report["blockers"].append("Changes to forbidden paths detected.")

    ledger = load_ledger(parsed.ledger)
    current_state = ledger.get(parsed.task_id, {}).get("state")

    if current_state:
        if parsed.transition not in VALID_TRANSITIONS.get(current_state, []):
            if current_state != parsed.transition: # allow idempotency
                report["blockers"].append(f"Invalid transition from {current_state} to {parsed.transition}")
    elif parsed.transition not in ["CLAIM", "ACTIVE", "BLOCKED"]:
        report["blockers"].append(f"Invalid initial transition: {parsed.transition}")

    overlap, overlap_msg = check_overlapping_claims(ledger, parsed.task_id, changed_files)
    if overlap:
        report["blockers"].append(overlap_msg)

    save_ledger(parsed.report, report)

    if report["blockers"]:
        print("Blockers found:", file=sys.stderr)
        for b in report["blockers"]:
            print(f" - {b}", file=sys.stderr)
        return 1

    # Update ledger
    ledger_entry = ledger.get(parsed.task_id, {"paths": []})
    ledger_entry["state"] = parsed.transition
    ledger_entry["paths"] = list(set(ledger_entry.get("paths", []) + report["permitted_paths"]))
    ledger[parsed.task_id] = ledger_entry

    save_ledger(parsed.ledger, ledger)
    print(f"Task {parsed.task_id} transitioned to {parsed.transition} successfully.")
    return 0

if __name__ == "__main__":
    sys.exit(main())
