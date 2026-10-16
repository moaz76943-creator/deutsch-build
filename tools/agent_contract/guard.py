import json
import os
import argparse
import subprocess
from pathlib import Path

LEDGER_PATH = "docs/project-record/task_ledger.json"
VALID_STATES = ["CLAIM", "ACTIVE", "BLOCKED", "COMPLETE"]
VALID_TRANSITIONS = {
    "CLAIM": ["ACTIVE", "BLOCKED"],
    "ACTIVE": ["BLOCKED", "COMPLETE"],
    "BLOCKED": ["ACTIVE", "COMPLETE"],
    "COMPLETE": []
}

class TaskLedger:
    def __init__(self, path=LEDGER_PATH):
        self.path = path
        self.data = self._load()

    def _load(self):
        if os.path.exists(self.path):
            with open(self.path, 'r') as f:
                return json.load(f)
        return {"tasks": {}}

    def save(self):
        with open(self.path, 'w') as f:
            json.dump(self.data, f, indent=2)
            f.write("\n")

    def get_task(self, task_id):
        return self.data.get("tasks", {}).get(task_id)

    def add_task(self, task_id, allowed_paths):
        if task_id in self.data.get("tasks", {}):
            raise ValueError(f"Task {task_id} already exists.")

        if "tasks" not in self.data:
            self.data["tasks"] = {}

        self.data["tasks"][task_id] = {
            "state": "CLAIM",
            "allowed_paths": allowed_paths
        }
        self.save()

    def transition_state(self, task_id, new_state):
        task = self.get_task(task_id)
        if not task:
            raise ValueError(f"Task {task_id} not found.")

        current_state = task["state"]
        if new_state not in VALID_STATES:
            raise ValueError(f"Invalid state: {new_state}")

        if new_state not in VALID_TRANSITIONS.get(current_state, []):
             raise ValueError(f"Invalid transition from {current_state} to {new_state}")

        task["state"] = new_state
        self.save()

    def check_overlap(self, task_id, paths):
        """Checks if the proposed paths overlap with any other ACTIVE or CLAIM tasks"""
        for other_task_id, other_task in self.data.get("tasks", {}).items():
            if other_task_id == task_id:
                continue

            if other_task["state"] not in ["CLAIM", "ACTIVE", "BLOCKED"]:
                continue

            other_allowed = other_task.get("allowed_paths", [])

            for path in paths:
                for other_path in other_allowed:
                     # Simple check: does one path subsume the other?
                     # e.g., docs/project-record/** overlaps with docs/project-record/task_ledger.json
                     if match_path(path, other_path) or match_path(other_path, path):
                         return True
        return False

def match_path(file_path, allowed_pattern):
    """Matches a file path against a pattern, supporting exact match and **"""
    if allowed_pattern.endswith('/**'):
        prefix = allowed_pattern[:-3]
        if not prefix: # just /** which is all files
             return True
        # Either it's inside the dir, or it IS the dir
        if file_path.startswith(prefix + '/') or file_path == prefix:
            return True
        return False
    else:
        # exact match
        return file_path == allowed_pattern

def is_safe_path(base_dir, path):
    """
    Prevent path traversal and symlink escapes.
    Returns True if path resolves within base_dir.
    """
    try:
        resolved_base = Path(base_dir).resolve()
        # Combine and resolve to catch ../ and symlinks
        resolved_target = (Path(base_dir) / path).resolve()

        # Check if the target is within the base directory
        return resolved_target.is_relative_to(resolved_base)
    except Exception:
        return False

def get_git_diff(base_sha, head_sha):
    """Gets the list of changed files between base and head"""
    try:
        # Check if base_sha is an ancestor of head_sha
        subprocess.check_call(
            ["git", "merge-base", "--is-ancestor", base_sha, head_sha],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL
        )
    except subprocess.CalledProcessError:
        raise ValueError(f"Stale base SHA: {base_sha} is not an ancestor of {head_sha}")

    # Get changed files
    result = subprocess.run(
        ["git", "diff", "--name-only", f"{base_sha}...{head_sha}"],
        capture_output=True,
        text=True,
        check=True
    )
    return [line.strip() for line in result.stdout.splitlines() if line.strip()]

def validate_changes(task_id, base_sha, head_sha, base_dir=".", ledger_path=LEDGER_PATH):
    ledger = TaskLedger(ledger_path)
    task = ledger.get_task(task_id)

    if not task:
        return {"error": f"Task {task_id} not found in ledger"}

    if task["state"] not in ["CLAIM", "ACTIVE"]:
        return {"error": f"Task {task_id} is in state {task['state']}, cannot validate changes"}

    allowed_paths = task.get("allowed_paths", [])

    try:
        changed_files = get_git_diff(base_sha, head_sha)
    except Exception as e:
        return {"error": str(e)}

    # Check for overlap
    if ledger.check_overlap(task_id, allowed_paths):
        return {"error": f"Task {task_id} claims paths that overlap with another active task"}

    permitted = []
    denied = []

    for file_path in changed_files:
        # Check safe path
        if not is_safe_path(base_dir, file_path):
            denied.append({"path": file_path, "reason": "Path traversal or symlink escape detected"})
            continue

        # Check if file is in allowed paths
        is_allowed = False
        for pattern in allowed_paths:
            if match_path(file_path, pattern):
                is_allowed = True
                break

        if is_allowed:
            permitted.append(file_path)
        else:
            denied.append({"path": file_path, "reason": "File not in allowed_paths"})

    result = {
        "task_id": task_id,
        "base_sha": base_sha,
        "head_sha": head_sha,
        "permitted": permitted,
        "denied": denied
    }

    if denied:
        result["status"] = "REJECTED"
    else:
        result["status"] = "APPROVED"

    return result

def main():
    parser = argparse.ArgumentParser(description="Agent ScopeGuard & Exclusive File Ownership")
    subparsers = parser.add_subparsers(dest="command", required=True)

    # Transition command
    transition_parser = subparsers.add_parser("transition", help="Transition task state")
    transition_parser.add_argument("--task-id", required=True)
    transition_parser.add_argument("--state", required=True, choices=VALID_STATES)
    transition_parser.add_argument("--ledger", default=LEDGER_PATH)

    # Validate command
    validate_parser = subparsers.add_parser("validate", help="Validate changed files against allowed paths")
    validate_parser.add_argument("--task-id", required=True)
    validate_parser.add_argument("--base-sha", required=True)
    validate_parser.add_argument("--head-sha", default="HEAD")
    validate_parser.add_argument("--ledger", default=LEDGER_PATH)

    args = parser.parse_args()

    if args.command == "transition":
        try:
            ledger = TaskLedger(args.ledger)
            ledger.transition_state(args.task_id, args.state)
            print(json.dumps({"status": "SUCCESS", "task_id": args.task_id, "new_state": args.state}, indent=2))
        except Exception as e:
            print(json.dumps({"error": str(e)}, indent=2))
            exit(1)

    elif args.command == "validate":
        result = validate_changes(args.task_id, args.base_sha, args.head_sha, ledger_path=args.ledger)
        print(json.dumps(result, indent=2))
        if result.get("status") == "REJECTED" or "error" in result:
            exit(1)

if __name__ == "__main__":
    main()
