#!/usr/bin/env python3
import argparse
import subprocess
import json
import sys
import os
import time
import fcntl
from pathlib import PurePosixPath

class TaskLedger:
    def __init__(self, ledger_path):
        self.ledger_path = os.path.abspath(ledger_path)
        self.lock_path = f"{self.ledger_path}.lock"
        self.tmp_path = f"{self.ledger_path}.tmp"
        self.lock_fd = None
        self.ledger_data = {}

    def __enter__(self):
        os.makedirs(os.path.dirname(self.ledger_path), exist_ok=True)
        self.lock_fd = open(self.lock_path, "w")
        fcntl.flock(self.lock_fd, fcntl.LOCK_EX)
        if os.path.exists(self.ledger_path):
            with open(self.ledger_path, "r") as f:
                content = f.read()
                self.ledger_data = json.loads(content) if content else {}
        else:
            self.ledger_data = {}
        return self.ledger_data

    def __exit__(self, exc_type, exc_val, exc_tb):
        if exc_type is None:
            with open(self.tmp_path, "w") as f:
                json.dump(self.ledger_data, f, indent=2)
                f.write("\n")
            os.replace(self.tmp_path, self.ledger_path)
        fcntl.flock(self.lock_fd, fcntl.LOCK_UN)
        self.lock_fd.close()


ALLOWED_PATHS = [
    "AGENTS.md",
    "docs/project-record/",
    "tools/agent_contract/"
]

VALID_TRANSITIONS = {
    "CLAIM": ["ACTIVE", "BLOCKED", "CANCELLED"],
    "ACTIVE": ["COMPLETE", "BLOCKED", "CANCELLED"],
    "BLOCKED": ["ACTIVE", "COMPLETE", "CANCELLED"],
    "COMPLETE": [],
    "CANCELLED": []
}

REPO_ROOT = os.path.abspath(os.getcwd())
LOCK_TTL_SECONDS = 3600

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

def paths_overlap(p1, p2):
    parts1 = PurePosixPath(p1).parts
    parts2 = PurePosixPath(p2).parts
    length = min(len(parts1), len(parts2))
    return parts1[:length] == parts2[:length]

def check_overlapping_claims(ledger, task_id, requested_paths, now):
    for other_task, data in list(ledger.items()):
        if other_task == task_id or other_task == "_metadata":
            continue
        if data.get("state") in ["CLAIM", "ACTIVE"]:
            timestamp = data.get("timestamp", 0)
            if now - timestamp > LOCK_TTL_SECONDS:
                data["state"] = "BLOCKED"
                data["recovery_evidence"] = f"Stale lock recovered after {now - timestamp} seconds. Original owner: {other_task}."
                continue

            other_paths = data.get("paths", [])
            for p in requested_paths:
                for op in other_paths:
                    if paths_overlap(p, op):
                        return True, f"Path {p} overlaps with {op} claimed by {other_task}"
    return False, ""

def is_stale_base_sha(ledger, base_sha):
    latest_completed = ledger.get("_metadata", {}).get("latest_base_sha")
    if latest_completed:
        try:
            subprocess.check_call(["git", "merge-base", "--is-ancestor", latest_completed, base_sha],
                                  stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        except subprocess.CalledProcessError:
            return True
    return False

def process_ledger(parsed, ledger):
    report = {
        "task_id": parsed.task_id,
        "base_sha": parsed.base_sha,
        "result_sha": parsed.result_sha,
        "transition": parsed.transition,
        "permitted_paths": [],
        "denied_paths": [],
        "blockers": []
    }

    current_state = ledger.get(parsed.task_id, {}).get("state")
    current_paths = ledger.get(parsed.task_id, {}).get("paths", [])

    requested_paths = []
    if parsed.transition == "CLAIM":
        if parsed.paths:
            requested_paths = parsed.paths
        else:
            report["blockers"].append("Paths must be provided for initial CLAIM.")
            return 1, report, ledger
    elif parsed.transition in ["ACTIVE", "COMPLETE"]:
        try:
            requested_paths = get_changed_files(parsed.base_sha, parsed.result_sha)
        except ValueError as e:
            report["blockers"].append(str(e))
            return 1, report, ledger

    for p in requested_paths:
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

    if parsed.transition == "COMPLETE" or parsed.transition == "ACTIVE":
        for p in report["permitted_paths"]:
            if p not in current_paths:
                covered = any(paths_overlap(p, cp) for cp in current_paths)
                if not covered:
                    report["blockers"].append(f"File {p} modified but not originally claimed.")

    if current_state:
        if parsed.transition not in VALID_TRANSITIONS.get(current_state, []):
            if current_state != parsed.transition:
                report["blockers"].append(f"Invalid transition from {current_state} to {parsed.transition}")
    elif parsed.transition not in ["CLAIM", "ACTIVE", "BLOCKED", "CANCELLED"]:
        report["blockers"].append(f"Invalid initial transition: {parsed.transition}")

    if parsed.transition in ["CLAIM", "ACTIVE"]:
        if is_stale_base_sha(ledger, parsed.base_sha):
            report["blockers"].append("Stale branch-base SHA detected. Base SHA is behind the latest completed merge.")

    # Check dependencies
    if parsed.depends_on:
        for dep in parsed.depends_on:
            dep_state = ledger.get(dep, {}).get("state")
            if dep_state != "COMPLETE":
                report["blockers"].append(f"Task depends on {dep} which is in state {dep_state}")

    now = time.time()
    overlap, overlap_msg = check_overlapping_claims(ledger, parsed.task_id, report["permitted_paths"], now)
    if overlap:
        report["blockers"].append(overlap_msg)

    if report["blockers"]:
        return 1, report, ledger

    ledger_entry = ledger.get(parsed.task_id, {"paths": []})
    ledger_entry["state"] = parsed.transition
    ledger_entry["timestamp"] = now

    if parsed.transition == "CLAIM":
        merged_paths = list(set(ledger_entry.get("paths", []) + report["permitted_paths"]))
        ledger_entry["paths"] = merged_paths

    ledger[parsed.task_id] = ledger_entry

    if parsed.transition == "COMPLETE":
        if "_metadata" not in ledger:
            ledger["_metadata"] = {}
        ledger["_metadata"]["latest_base_sha"] = parsed.result_sha

    return 0, report, ledger

def main(args=None):
    if args is None:
        args = sys.argv[1:]

    parser = argparse.ArgumentParser(description="Repository governance guard")
    parser.add_argument("--task-id", required=True)
    parser.add_argument("--base-sha", required=True)
    parser.add_argument("--result-sha", default="HEAD")
    parser.add_argument("--transition", choices=["CLAIM", "ACTIVE", "COMPLETE", "BLOCKED", "CANCELLED"], required=True)
    parser.add_argument("--paths", nargs="*", help="List of files/dirs to claim")
    parser.add_argument("--depends-on", nargs="*", help="List of task IDs this task depends on")
    parser.add_argument("--ledger", default="tools/agent_contract/task_ledger.json")
    parser.add_argument("--report", default="tools/agent_contract/evidence_report.json")

    parsed = parser.parse_args(args)

    os.makedirs(os.path.dirname(os.path.abspath(parsed.ledger)), exist_ok=True)

    with TaskLedger(parsed.ledger) as ledger_data:
        result_code, report, updated_ledger = process_ledger(parsed, ledger_data)

        os.makedirs(os.path.dirname(os.path.abspath(parsed.report)), exist_ok=True)
        with open(parsed.report, "w") as rf:
            json.dump(report, rf, indent=2)

    if report["blockers"]:
        print("Blockers found:", file=sys.stderr)
        for b in report["blockers"]:
            print(f" - {b}", file=sys.stderr)
        return 1

    print(f"Task {parsed.task_id} transitioned to {parsed.transition} successfully.")
    return 0

if __name__ == "__main__":
    sys.exit(main())
