import json
import os
import argparse
import subprocess
import fcntl
import time
from pathlib import Path

LEDGER_PATH = "docs/project-record/task_ledger.json"
VALID_STATES = ["CLAIM", "ACTIVE", "BLOCKED", "COMPLETE"]
VALID_TRANSITIONS = {
    "CLAIM": ["ACTIVE", "BLOCKED", "COMPLETE"],
    "ACTIVE": ["BLOCKED", "COMPLETE"],
    "BLOCKED": ["ACTIVE", "COMPLETE"],
    "COMPLETE": []
}
STALE_LOCK_TIMEOUT_SECONDS = 3600  # 1 hour

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

def check_overlap_paths(paths_a, paths_b):
    for path_a in paths_a:
        for path_b in paths_b:
            if match_path(path_a, path_b) or match_path(path_b, path_a):
                return True
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

def validate_base_sha(base_sha):
    try:
        subprocess.check_call(
            ["git", "cat-file", "-e", f"{base_sha}^{{commit}}"],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL
        )
        return True
    except subprocess.CalledProcessError:
        return False

class TaskLedger:
    def __init__(self, path=LEDGER_PATH):
        self.path = path
        self.lock_path = path + ".lock"
        self._lock_file = None
        # Ensure dir exists
        os.makedirs(os.path.dirname(self.path) if os.path.dirname(self.path) else ".", exist_ok=True)
        self.data = self._load()

    def __enter__(self):
        self._lock_file = open(self.lock_path, "a+")
        fcntl.flock(self._lock_file, fcntl.LOCK_EX)
        self.data = self._load()
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        if self._lock_file:
            fcntl.flock(self._lock_file, fcntl.LOCK_UN)
            self._lock_file.close()

    def _load(self):
        if os.path.exists(self.path):
            try:
                with open(self.path, 'r') as f:
                    return json.load(f)
            except json.JSONDecodeError:
                return {"tasks": {}}
        return {"tasks": {}}

    def save(self):
        with open(self.path, 'w') as f:
            json.dump(self.data, f, indent=2)
            f.write("\n")

    def get_task(self, task_id):
        return self.data.get("tasks", {}).get(task_id)

    def add_task(self, task_id, allowed_paths, owner=None, base_sha=None, dependencies=None):
        if "tasks" not in self.data:
            self.data["tasks"] = {}

        task = self.data["tasks"].get(task_id)
        if task and task["state"] not in ["COMPLETE"]:
            raise ValueError(f"Task {task_id} already exists and is not COMPLETE.")

        self.data["tasks"][task_id] = {
            "state": "CLAIM",
            "allowed_paths": allowed_paths,
            "owner": owner,
            "base_sha": base_sha,
            "timestamp": time.time(),
            "dependencies": dependencies or []
        }
        self.save()

    def update_task_timestamp(self, task_id):
        task = self.get_task(task_id)
        if task:
            task["timestamp"] = time.time()
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
        task["timestamp"] = time.time()
        self.save()

    def check_overlap(self, task_id, paths):
        """Checks if the proposed paths overlap with any other ACTIVE or CLAIM tasks"""
        for other_task_id, other_task in self.data.get("tasks", {}).items():
            if other_task_id == task_id:
                continue

            if other_task["state"] not in ["CLAIM", "ACTIVE", "BLOCKED"]:
                continue

            other_allowed = other_task.get("allowed_paths", [])

            if check_overlap_paths(paths, other_allowed):
                return True
        return False

    def recover_stale_lock(self, task_id, owner_evidence):
        task = self.get_task(task_id)
        if not task:
            raise ValueError(f"Task {task_id} not found.")

        if task["state"] == "COMPLETE":
            return True # Nothing to recover

        if time.time() - task.get("timestamp", 0) > STALE_LOCK_TIMEOUT_SECONDS:
            # It's stale. Break the lock.
            task["state"] = "COMPLETE" # or release/abandoned
            task["recovery_evidence"] = owner_evidence
            self.save()
            return True
        return False

    def check_dependencies(self, dependencies):
        if not dependencies:
            return True
        for dep in dependencies:
            dep_task = self.get_task(dep)
            if not dep_task or dep_task["state"] != "COMPLETE":
                return False
        return True

def acquire_lock(task_id, paths, owner, base_sha, dependencies=None, ledger_path=LEDGER_PATH):
    if not validate_base_sha(base_sha):
        return {"error": f"Invalid or stale base SHA: {base_sha}"}

    with TaskLedger(ledger_path) as ledger:
        if not ledger.check_dependencies(dependencies):
            return {"error": "Dependencies not met."}

        if ledger.check_overlap(task_id, paths):
            return {"error": "Paths overlap with another active claim."}

        try:
            ledger.add_task(task_id, paths, owner, base_sha, dependencies)
            return {"status": "ACQUIRED", "task_id": task_id}
        except ValueError as e:
            return {"error": str(e)}

def release_lock(task_id, ledger_path=LEDGER_PATH):
    with TaskLedger(ledger_path) as ledger:
        try:
            # We don't delete, we mark COMPLETE or transition to COMPLETE
            ledger.transition_state(task_id, "COMPLETE")
            return {"status": "RELEASED", "task_id": task_id}
        except ValueError as e:
            return {"error": str(e)}

def recover_lock(task_id, owner_evidence, ledger_path=LEDGER_PATH):
    with TaskLedger(ledger_path) as ledger:
        try:
            recovered = ledger.recover_stale_lock(task_id, owner_evidence)
            if recovered:
                return {"status": "RECOVERED", "task_id": task_id}
            else:
                return {"error": "Lock is not stale yet."}
        except ValueError as e:
            return {"error": str(e)}

def validate_changes(task_id, base_sha, head_sha, base_dir=".", ledger_path=LEDGER_PATH):
    with TaskLedger(ledger_path) as ledger:
        task = ledger.get_task(task_id)

        if not task:
            return {"error": f"Task {task_id} not found in ledger"}

        if task["state"] not in ["CLAIM", "ACTIVE"]:
            return {"error": f"Task {task_id} is in state {task['state']}, cannot validate changes"}

        allowed_paths = task.get("allowed_paths", [])

        # Check for overlap (dynamic validation)
        if ledger.check_overlap(task_id, allowed_paths):
            return {"error": f"Task {task_id} claims paths that overlap with another active task"}

    try:
        changed_files = get_git_diff(base_sha, head_sha)
    except Exception as e:
        return {"error": str(e)}

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

    # Acquire command
    acquire_parser = subparsers.add_parser("acquire", help="Acquire a lock for paths")
    acquire_parser.add_argument("--task-id", required=True)
    acquire_parser.add_argument("--paths", required=True, nargs='+')
    acquire_parser.add_argument("--owner", required=True)
    acquire_parser.add_argument("--base-sha", required=True)
    acquire_parser.add_argument("--dependencies", nargs='*', default=[])
    acquire_parser.add_argument("--ledger", default=LEDGER_PATH)

    # Release command
    release_parser = subparsers.add_parser("release", help="Release a task lock (transition to COMPLETE)")
    release_parser.add_argument("--task-id", required=True)
    release_parser.add_argument("--ledger", default=LEDGER_PATH)

    # Recover command
    recover_parser = subparsers.add_parser("recover", help="Recover a stale task lock")
    recover_parser.add_argument("--task-id", required=True)
    recover_parser.add_argument("--owner-evidence", required=True)
    recover_parser.add_argument("--ledger", default=LEDGER_PATH)


    args = parser.parse_args()

    if args.command == "transition":
        try:
            with TaskLedger(args.ledger) as ledger:
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

    elif args.command == "acquire":
        result = acquire_lock(args.task_id, args.paths, args.owner, args.base_sha, args.dependencies, args.ledger)
        print(json.dumps(result, indent=2))
        if "error" in result:
            exit(1)

    elif args.command == "release":
        result = release_lock(args.task_id, args.ledger)
        print(json.dumps(result, indent=2))
        if "error" in result:
            exit(1)

    elif args.command == "recover":
        result = recover_lock(args.task_id, args.owner_evidence, args.ledger)
        print(json.dumps(result, indent=2))
        if "error" in result:
            exit(1)

if __name__ == "__main__":
    main()
