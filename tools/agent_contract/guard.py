import argparse
import fcntl
import json
import os
import subprocess
import sys
from pathlib import PurePosixPath, Path
from typing import List, Dict, Any, Optional

LEDGER_FILE = "tools/agent_contract/.ledger.json"

ALLOWED_PREFIXES = [
    "AGENTS.md",
    "docs/project-record/",
    "tools/agent_contract/"
]

VALID_TRANSITIONS = {
    "CLAIM": ["ACTIVE", "CANCELLED"],
    "ACTIVE": ["BLOCKED", "COMPLETE", "CANCELLED"],
    "BLOCKED": ["ACTIVE", "CANCELLED", "COMPLETE"],
    "COMPLETE": [],
    "CANCELLED": []
}

class ScopeGuardException(Exception):
    pass

def load_ledger() -> Dict[str, Any]:
    if not os.path.exists(LEDGER_FILE):
        return {}
    with open(LEDGER_FILE, 'r') as f:
        try:
            return json.load(f)
        except json.JSONDecodeError:
            return {}

def save_ledger(data: Dict[str, Any], f: Any):
    f.seek(0)
    f.truncate(0)
    json.dump(data, f, indent=2)

def is_path_allowed(path: str) -> bool:
    try:
        # Resolve path to catch '..' and symlink escapes
        resolved = Path(path).resolve()
        cwd = Path.cwd().resolve()
        # Must be within the current working directory
        if not str(resolved).startswith(str(cwd)):
            return False

        rel_path = str(resolved.relative_to(cwd))
        # Ensure it's not a sneaky traversal (relative_to might raise ValueError, but just in case)
        if rel_path.startswith("..") or "/../" in rel_path:
            return False

        # Path must be in allowed prefixes
        pure_path = PurePosixPath(rel_path)
        # Ensure directory paths have trailing slash for comparison if needed
        rel_path_dir = rel_path + '/' if Path(path).is_dir() and not rel_path.endswith('/') else rel_path

        for allowed in ALLOWED_PREFIXES:
            if allowed.endswith('/'):
                if rel_path.startswith(allowed) or rel_path_dir.startswith(allowed) or pure_path.match(allowed + '**') or rel_path == allowed.rstrip('/'):
                    return True
            else:
                if rel_path == allowed:
                    return True
        return False
    except Exception:
        return False

def check_path_collision(ledger: Dict[str, Any], task_id: str, paths: List[str]) -> Optional[str]:
    requested_paths = [PurePosixPath(p) for p in paths]

    for existing_task_id, task_info in ledger.items():
        if existing_task_id == task_id:
            continue

        if task_info.get('state') in ['COMPLETE', 'CANCELLED']:
            continue

        existing_paths = [PurePosixPath(p) for p in task_info.get('paths', [])]

        for req in requested_paths:
            for ext in existing_paths:
                # Check for direct match or subpath overlaps
                if req == ext or req.is_relative_to(ext) or ext.is_relative_to(req):
                    return str(req)
    return None

def get_changed_files(base_sha: str) -> List[str]:
    try:
        # Get changed files since base_sha
        result = subprocess.run(
            ['git', 'diff', '--name-only', base_sha],
            capture_output=True, text=True, check=True
        )
        files = result.stdout.splitlines()

        # Also check untracked/unstaged files
        status_result = subprocess.run(
            ['git', 'status', '--porcelain'],
            capture_output=True, text=True, check=True
        )
        for line in status_result.stdout.splitlines():
            # Extract filename from porcelain output (M  file.txt, ?? file.txt, etc.)
            if len(line) > 3:
                files.append(line[3:])

        # Deduplicate
        return list(set(files))
    except subprocess.CalledProcessError as e:
        raise ScopeGuardException(f"Failed to get changed files: {e.stderr}")

def validate_base_sha(base_sha: str):
    try:
        subprocess.run(
            ['git', 'cat-file', '-e', f'{base_sha}^{{commit}}'],
            capture_output=True, check=True
        )
    except subprocess.CalledProcessError:
        raise ScopeGuardException(f"Invalid or stale BASE_SHA: {base_sha}")

def process_claim(task_id: str, base_sha: str, state: str, paths: List[str]):
    ledger_dir = os.path.dirname(LEDGER_FILE)
    if ledger_dir:
        os.makedirs(ledger_dir, exist_ok=True)

    with open(LEDGER_FILE, 'a+') as f:
        fcntl.flock(f, fcntl.LOCK_EX)
        try:
            f.seek(0)
            content = f.read()
            if content:
                ledger = json.loads(content)
            else:
                ledger = {}

            # Validate paths
            if paths:
                for path in paths:
                    if not is_path_allowed(path):
                        raise ScopeGuardException(f"Path not allowed: {path}")

            # Check state transitions
            current_task = ledger.get(task_id)
            if current_task:
                current_state = current_task['state']
                if state not in VALID_TRANSITIONS.get(current_state, []):
                    # Exception: if state is CLAIM and we're already in a non-terminal state, might be an update,
                    # but strictly, CLAIM -> ACTIVE -> COMPLETE. Let's enforce it strictly unless resuming.
                    if state == 'CLAIM' and current_state == 'CLAIM':
                        pass # Allow updating a claim
                    else:
                        raise ScopeGuardException(f"Invalid state transition: {current_state} -> {state}")
            else:
                if state != 'CLAIM':
                    raise ScopeGuardException(f"Task {task_id} not found. Must start with CLAIM.")

            # Check for path collisions if paths are provided
            if paths:
                collision = check_path_collision(ledger, task_id, paths)
                if collision:
                    raise ScopeGuardException(f"Path collision detected: {collision}")

            # Validate base SHA
            validate_base_sha(base_sha)

            # Check changed files against allowed paths and claimed paths
            changed_files = get_changed_files(base_sha)

            # Combine requested paths with previously claimed paths for validation
            claimed_paths = paths if paths else (current_task.get('paths', []) if current_task else [])

            for file in changed_files:
                if not is_path_allowed(file):
                    raise ScopeGuardException(f"Unauthorized file modification detected: {file}")

                # Check if changed file is within claimed paths
                # The user requested 'paths' might just be the root, e.g., 'tools/agent_contract/'
                # So we check if the file is relative to any claimed path.
                is_claimed = False
                file_pure = PurePosixPath(file)
                for cp in claimed_paths:
                    cp_pure = PurePosixPath(cp)
                    if file_pure == cp_pure or file_pure.is_relative_to(cp_pure):
                        is_claimed = True
                        break

                if not is_claimed:
                    raise ScopeGuardException(f"Modified file not in claimed paths: {file}")

            # Update ledger
            ledger[task_id] = {
                'state': state,
                'base_sha': base_sha,
                'paths': claimed_paths
            }
            save_ledger(ledger, f)

            print(json.dumps({
                "status": "success",
                "task_id": task_id,
                "state": state,
                "base_sha": base_sha,
                "paths": claimed_paths,
                "changed_files": changed_files
            }))

        except ScopeGuardException as e:
            print(json.dumps({
                "status": "error",
                "message": str(e)
            }))
            sys.exit(1)
        except Exception as e:
            print(json.dumps({
                "status": "error",
                "message": f"Internal error: {str(e)}"
            }))
            sys.exit(1)
        finally:
            fcntl.flock(f, fcntl.LOCK_UN)

def main():
    parser = argparse.ArgumentParser(description="Agent ScopeGuard")
    parser.add_argument('--task-id', required=True, help="Task ID")
    parser.add_argument('--base-sha', required=True, help="Base Git SHA")
    parser.add_argument('--state', required=True, choices=['CLAIM', 'ACTIVE', 'BLOCKED', 'COMPLETE', 'CANCELLED'], help="Task state")
    parser.add_argument('--paths', nargs='*', default=[], help="Paths to claim")

    args = parser.parse_args()
    process_claim(args.task_id, args.base_sha, args.state, args.paths)

if __name__ == "__main__":
    main()
