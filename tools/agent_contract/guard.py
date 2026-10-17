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

    permitted = []
    denied = []

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

if __name__ == "__main__":
    main()
