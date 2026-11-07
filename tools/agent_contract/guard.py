#!/usr/bin/env python3
import argparse
import subprocess
import json
import sys
import os
import time
import fcntl
import tempfile
from pathlib import Path, PurePosixPath
LOCK_TTL_SECONDS = 3600

ALLOWED_PATHS = [
    "AGENTS.md",
    "docs/project-record/",
    "tools/agent_contract/"
]

VALID_TRANSITIONS = {
    "CLAIM": ["ACTIVE", "BLOCKED", "CANCELLED"],
    "ACTIVE": ["COMPLETE", "BLOCKED", "CANCELLED"],
    "BLOCKED": ["ACTIVE", "CANCELLED"],
    "COMPLETE": [],
    "CANCELLED": []
}

REPO_ROOT = str(Path(__file__).resolve().parents[2])
LOCK_TTL_SECONDS = 3600



def default_state_dir():
    """Keep mutable agent state outside the source-controlled repository."""
    base = os.environ.get("XDG_STATE_HOME")
    return (Path(base) if base else Path.home() / ".local" / "state") / "deutsch-agent-contract"


def write_json_atomic(path, value):
    """Durably replace JSON under the caller's stable sibling-file lock."""
    target = Path(path)
    target.parent.mkdir(parents=True, exist_ok=True)
    descriptor, temporary = tempfile.mkstemp(prefix=".agent-state-", dir=target.parent)
    try:
        os.fchmod(descriptor, 0o600)
        with os.fdopen(descriptor, "w", encoding="utf-8") as stream:
            json.dump(value, stream, indent=2)
            stream.write("\n")
            stream.flush()
            os.fsync(stream.fileno())
        os.replace(temporary, target)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)


def get_changed_files(base_sha, result_sha="HEAD"):
    cmd = ["git", "diff", "--name-only", f"{base_sha}...{result_sha}"]
    try:
        output = subprocess.check_output(cmd, text=True, stderr=subprocess.PIPE, cwd=REPO_ROOT)
        return [line.strip() for line in output.splitlines() if line.strip()]
    except subprocess.CalledProcessError as e:
        raise ValueError(f"Git diff failed or stale base SHA. Ensure BASE_SHA is valid. Error: {e.stderr}")

def is_path_allowed(path_str):
    """Validate a repository-relative claim without following any symlink."""
    if not isinstance(path_str, str):
        return False
    try:
        path = PurePosixPath(path_str)
        if (not path.parts or path.is_absolute() or
                ".." in path.parts or ".git" in path.parts):
            return False

        normalized = path.as_posix()
        if not (
            normalized == "AGENTS.md"
            or normalized == "docs/project-record"
            or normalized.startswith("docs/project-record/")
            or normalized == "tools/agent_contract"
            or normalized.startswith("tools/agent_contract/")
        ):
            return False

        root = Path(REPO_ROOT).resolve()
        candidate = root
        for component in path.parts:
            candidate = candidate / component
            # Even in-scope symlink aliases obscure the actual claimed file.
            if candidate.is_symlink():
                return False
        return candidate.resolve().is_relative_to(root)
    except (OSError, RuntimeError, ValueError):
        return False

def paths_overlap(p1, p2):
    parts1 = PurePosixPath(p1).parts
    parts2 = PurePosixPath(p2).parts
    length = min(len(parts1), len(parts2))
    return parts1[:length] == parts2[:length]

def check_overlapping_claims(ledger, task_id, requested_paths, now, recover_from=None, owner_evidence=None):
    for other_task, data in list(ledger.items()):
        if other_task == task_id or other_task == "_metadata":
            continue
        if data.get("state") in ["CLAIM", "ACTIVE"]:
            expired = now - data.get("timestamp", 0) > LOCK_TTL_SECONDS
            if recover_from and other_task == recover_from and owner_evidence:
                continue
            other_paths = data.get("paths", [])
            for p in requested_paths:
                for op in other_paths:
                    if paths_overlap(p, op):
                        reason = f"Path {p} overlaps with {op} claimed by {other_task}"
                        if expired:
                            reason += "; expired claim requires explicit release after owner reconciliation"
                        return True, reason
    return False, ""

def is_stale_base_sha(ledger, base_sha):
    latest_completed = ledger.get("_metadata", {}).get("latest_base_sha")
    if latest_completed:
        try:
            subprocess.check_call(["git", "merge-base", "--is-ancestor", latest_completed, base_sha],
                                  stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, cwd=REPO_ROOT)
        except subprocess.CalledProcessError:
            return True
    return False

def process_ledger(parsed, content):
    ledger = json.loads(content) if content else {}
    states = frozenset(VALID_TRANSITIONS)
    if (not isinstance(ledger, dict) or
            any(not isinstance(value, dict) or
                (key != "_metadata" and value.get("state") not in states)
                for key, value in ledger.items())):
        raise ValueError("invalid_ledger_schema")

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
    if getattr(parsed, "depends_on", None):
        for dep in parsed.depends_on:
            dep_state = ledger.get(dep, {}).get("state")
            if dep_state != "COMPLETE":
                report["blockers"].append(f"Task depends on {dep} which is in state {dep_state}")

    now = time.time()
    recover_from = getattr(parsed, "recover_from", None)
    owner_evidence = getattr(parsed, "owner_evidence", None)

    overlap, overlap_msg = check_overlapping_claims(ledger, parsed.task_id, report["permitted_paths"], now, recover_from, owner_evidence)
    if overlap:
        report["blockers"].append(overlap_msg)

    if report["blockers"]:
        return 1, report, ledger

    if recover_from and owner_evidence and recover_from in ledger and ledger[recover_from].get("state") in ["CLAIM", "ACTIVE"]:
        ledger[recover_from]["state"] = "CANCELLED"
        ledger[recover_from]["owner_evidence"] = owner_evidence

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
    parser.add_argument("--ledger", default=str(default_state_dir() / "task_ledger.json"))
    parser.add_argument("--report", default=str(default_state_dir() / "evidence_report.json"))
    parser.add_argument("--recover-from", help="Task ID to recover from")
    parser.add_argument("--owner-evidence", help="Evidence of owner failure for recovery")

    parsed = parser.parse_args(args)

    ledger_path = Path(parsed.ledger)
    ledger_path.parent.mkdir(parents=True, exist_ok=True)
    # A persistent sibling lock remains valid across atomic inode replacements.
    with open(str(ledger_path) + ".lock", "a+", encoding="utf-8") as lock:
        os.chmod(str(ledger_path) + ".lock", 0o600)
        fcntl.flock(lock, fcntl.LOCK_EX)
        try:
            if ledger_path.exists():
                with ledger_path.open("r", encoding="utf-8") as current:
                    result_code, report, updated_ledger = process_ledger(parsed, current.read())
            else:
                import io
                result_code, report, updated_ledger = process_ledger(parsed, "")
        except (json.JSONDecodeError, ValueError, TypeError, AttributeError):
            result_code = 1
            report = {"task_id": parsed.task_id, "base_sha": parsed.base_sha,
                      "result_sha": parsed.result_sha, "transition": parsed.transition,
                      "permitted_paths": [], "denied_paths": [],
                      "blockers": ["Invalid ledger JSON/schema: existing state preserved"]}
            updated_ledger = None

        write_json_atomic(parsed.report, report)
        if result_code == 0:
            write_json_atomic(ledger_path, updated_ledger)

    if report["blockers"]:
        print("Blockers found:", file=sys.stderr)
        for b in report["blockers"]:
            print(f" - {b}", file=sys.stderr)
        return 1

    print(f"Task {parsed.task_id} transitioned to {parsed.transition} successfully.")
    return 0

if __name__ == "__main__":
    sys.exit(main())
