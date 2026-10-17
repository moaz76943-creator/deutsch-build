<<<<<<< HEAD
import argparse
import json
import os
import subprocess
import sys
import fnmatch
from typing import List, Dict, Any, Tuple

LEDGER_PATH = os.path.join(os.path.dirname(__file__), '../../docs/project-record/task_ledger.json')
TERMINAL_STATES = {'COMPLETE', 'FAILED', 'SUPERSEDE'}
VALID_TRANSITIONS = {
    'CLAIM': {'ACTIVE', 'BLOCKED', 'FAILED', 'SUPERSEDE'},
    'ACTIVE': {'BLOCKED', 'COMPLETE', 'FAILED', 'SUPERSEDE'},
    'BLOCKED': {'ACTIVE', 'FAILED', 'SUPERSEDE'},
    'COMPLETE': set(),
    'FAILED': {'CLAIM'}, # Retry
    'SUPERSEDE': set(),
}

FORBIDDEN_PATHS = [
    'lib/',
    'android/',
    'assets/',
    '.github/',
    '.circleci/',
    'signing keys',
    'secrets'
]

def load_ledger() -> Dict[str, Any]:
    if not os.path.exists(LEDGER_PATH):
        return {}
    with open(LEDGER_PATH, 'r') as f:
        try:
            return json.load(f)
        except json.JSONDecodeError:
            return {}

def save_ledger(ledger: Dict[str, Any]):
    os.makedirs(os.path.dirname(LEDGER_PATH), exist_ok=True)
    with open(LEDGER_PATH, 'w') as f:
        json.dump(ledger, f, indent=2)

def check_path_overlap(ledger: Dict[str, Any], task_id: str, paths: List[str]) -> Tuple[bool, str]:
    for existing_task_id, task_data in ledger.items():
        if existing_task_id == task_id:
            continue
        if task_data.get('state') in TERMINAL_STATES:
            continue
        existing_paths = task_data.get('allowed_paths', [])
        # Simple overlap check: check if any path matches or if one is a prefix of another
        for path in paths:
            for existing_path in existing_paths:
                # Normalizing paths
                p1 = os.path.normpath(path)
                p2 = os.path.normpath(existing_path)

                # Check if same or parent/child directory relationship
                if p1 == p2 or p1.startswith(p2 + os.sep) or p2.startswith(p1 + os.sep):
                     return True, f"Overlap with task {existing_task_id} on path {existing_path}"

                # Handling glob patterns roughly
                if '*' in p1 or '*' in p2:
                     # A simplified check: if both have globs or exact string match, we assume overlap if they share common prefix before the glob
                     p1_base = p1.split('*')[0]
                     p2_base = p2.split('*')[0]
                     if p1_base and p2_base and (p1_base.startswith(p2_base) or p2_base.startswith(p1_base)):
                         return True, f"Potential glob overlap with task {existing_task_id} on path {existing_path}"

    return False, ""

def claim_task(task_id: str, base_sha: str, paths: List[str]):
    ledger = load_ledger()

    # Check for overlaps
    has_overlap, msg = check_path_overlap(ledger, task_id, paths)
    if has_overlap:
        print(f"Error: Path claim rejected. {msg}", file=sys.stderr)
        sys.exit(1)

    ledger[task_id] = {
        'state': 'CLAIM',
        'base_sha': base_sha,
        'allowed_paths': paths
    }
    save_ledger(ledger)
    print(f"Task {task_id} claimed successfully.")

def transition_task(task_id: str, new_state: str):
    ledger = load_ledger()

    if task_id not in ledger:
        print(f"Error: Task {task_id} not found in ledger.", file=sys.stderr)
        sys.exit(1)

    current_state = ledger[task_id].get('state', '')

    if new_state not in VALID_TRANSITIONS.get(current_state, set()):
        print(f"Error: Invalid state transition from {current_state} to {new_state}.", file=sys.stderr)
        sys.exit(1)

    ledger[task_id]['state'] = new_state
    save_ledger(ledger)
    print(f"Task {task_id} transitioned to {new_state}.")

def _is_path_allowed(filepath: str, allowed_paths: List[str]) -> bool:
    # Resolve to detect path traversal and symlinks
    try:
        resolved_path = os.path.realpath(filepath)
        cwd = os.path.realpath(os.getcwd())

        # Security check: must not escape current working directory (preventing ../ escapes)
        if not resolved_path.startswith(cwd):
            return False

        # Get relative path based on the symlink/resolved difference
        # But we mostly work with relative paths from git diff
        rel_path = os.path.relpath(resolved_path, cwd)
        # Handle case where file might be a symlink inside the dir but points outside
        if '..' in rel_path.split(os.sep):
             return False

        # Ensure no forbidden paths
        for forbidden in FORBIDDEN_PATHS:
            if rel_path.startswith(forbidden) or (not forbidden.endswith('/') and rel_path == forbidden):
                return False

        # Check against allowed paths
        for allowed in allowed_paths:
            # Explicit match or subdirectory match
            if rel_path == allowed or rel_path.startswith(allowed + os.sep):
                return True
            # Glob match
            if fnmatch.fnmatch(rel_path, allowed):
                return True

        return False
    except Exception:
        return False

def validate_task(task_id: str):
    ledger = load_ledger()

    if task_id not in ledger:
        print(f"Error: Task {task_id} not found in ledger.", file=sys.stderr)
        sys.exit(1)

    task_data = ledger[task_id]
    base_sha = task_data.get('base_sha')
    allowed_paths = task_data.get('allowed_paths', [])

    # Check if base_sha exists in git
    try:
        subprocess.check_call(['git', 'cat-file', '-e', f'{base_sha}^{{commit}}'],
                              stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    except subprocess.CalledProcessError:
        print(f"Error: Stale or invalid base_sha {base_sha}.", file=sys.stderr)
        sys.exit(1)

    # Get changed files using git diff --name-only <base_sha> HEAD
    try:
        output = subprocess.check_output(['git', 'diff', '--name-only', base_sha, 'HEAD']).decode('utf-8')
        changed_files = [line.strip() for line in output.split('\n') if line.strip()]
    except subprocess.CalledProcessError:
        print("Error: Failed to get changed files from git.", file=sys.stderr)
        sys.exit(1)

    # Also get untracked files
    try:
        untracked_output = subprocess.check_output(['git', 'ls-files', '--others', '--exclude-standard']).decode('utf-8')
        changed_files.extend([line.strip() for line in untracked_output.split('\n') if line.strip()])
    except subprocess.CalledProcessError:
        pass

    # Deduplicate
    changed_files = list(set(changed_files))
=======
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
>>>>>>> pr-179

    permitted = []
    denied = []

<<<<<<< HEAD
    for filepath in changed_files:
        if _is_path_allowed(filepath, allowed_paths):
            permitted.append(filepath)
        else:
            denied.append(filepath)

    # Produce evidence report
    print("--- Guard Validation Evidence Report ---")
    print(f"Task ID: {task_id}")
    print(f"Base SHA: {base_sha}")
    print(f"Allowed Paths: {allowed_paths}")
    print("\nPermitted Paths:")
    for p in permitted:
        print(f"  - {p}")

    print("\nDenied Paths:")
    for p in denied:
        print(f"  - {p}")

    if denied:
        print("\nValidation Failed: Unauthorized modifications detected.", file=sys.stderr)
        sys.exit(1)
    else:
        print("\nValidation Passed: All changes are within allowed paths.")
        sys.exit(0)

def main():
    parser = argparse.ArgumentParser(description="Agent Contract Guard Subsystem")
    subparsers = parser.add_subparsers(dest='command', required=True)

    # Claim command
    claim_parser = subparsers.add_parser('claim', help="Claim ownership for a task and define allowed paths")
    claim_parser.add_argument('--task-id', required=True, help="The task ID")
    claim_parser.add_argument('--base-sha', required=True, help="The base SHA for the task")
    claim_parser.add_argument('--paths', required=True, nargs='+', help="Allowed paths (glob patterns allowed)")

    # Transition command
    transition_parser = subparsers.add_parser('transition', help="Transition task state")
    transition_parser.add_argument('--task-id', required=True, help="The task ID")
    transition_parser.add_argument('--state', required=True, choices=['CLAIM', 'ACTIVE', 'BLOCKED', 'COMPLETE', 'FAILED', 'SUPERSEDE'], help="The new state")

    # Validate command
    validate_parser = subparsers.add_parser('validate', help="Validate changes against allowed paths")
    validate_parser.add_argument('--task-id', required=True, help="The task ID")

    args = parser.parse_args()

    if args.command == 'claim':
        claim_task(args.task_id, args.base_sha, args.paths)
    elif args.command == 'transition':
        transition_task(args.task_id, args.state)
    elif args.command == 'validate':
        validate_task(args.task_id)
=======
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
>>>>>>> pr-179

if __name__ == "__main__":
    main()
