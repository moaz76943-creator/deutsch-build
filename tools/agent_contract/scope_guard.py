import argparse
import fnmatch
import json
import logging
import os
import subprocess
import sys
from pathlib import Path
from typing import List, Dict, Set, Optional

# Constants
LEDGER_FILE = Path(__file__).parent / ".scope_guard_ledger.json"
ALLOWED_PATHS = [
    "AGENTS.md",
    "docs/project-record/**",
    "tools/agent_contract/**"
]
STATES = {"CLAIM", "ACTIVE", "BLOCKED", "COMPLETE"}

logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")

class ScopeGuardError(Exception):
    pass

class Ledger:
    def __init__(self, path: Path):
        self.path = path
        self.data: Dict[str, Dict] = self._load()

    def _load(self) -> Dict[str, Dict]:
        if self.path.exists():
            try:
                with open(self.path, "r", encoding="utf-8") as f:
                    return json.load(f)
            except json.JSONDecodeError:
                return {}
        return {}

    def save(self) -> None:
        with open(self.path, "w", encoding="utf-8") as f:
            json.dump(self.data, f, indent=2)

    def get_task(self, task_id: str) -> Optional[Dict]:
        return self.data.get(task_id)

    def set_task(self, task_id: str, state: str, base_sha: str, paths: List[str]) -> None:
        self.data[task_id] = {
            "state": state,
            "base_sha": base_sha,
            "paths": paths
        }
        self.save()

    def get_overlapping_task(self, task_id: str, paths: List[str]) -> Optional[str]:
        for existing_id, info in self.data.items():
            if existing_id == task_id or info["state"] == "COMPLETE":
                continue
            existing_paths = info.get("paths", [])
            for req_path in paths:
                for existing_path in existing_paths:
                    if req_path == existing_path:
                        return existing_id
                    # Handle if requested path falls inside existing dir claim
                    if existing_path.endswith("/**") and req_path.startswith(existing_path[:-3] + "/"):
                        return existing_id
                    # Handle if existing path falls inside requested dir claim
                    if req_path.endswith("/**") and existing_path.startswith(req_path[:-3] + "/"):
                        return existing_id
        return None

def is_path_allowed(path: str) -> bool:
    # Resolve to check for traversals like '../lib'
    try:
        resolved = Path(path).resolve()
        cwd = Path.cwd().resolve()
        if not str(resolved).startswith(str(cwd)):
            return False

        rel_path = str(resolved.relative_to(cwd))

        # Replace backslashes on Windows just in case
        rel_path = rel_path.replace(os.sep, "/")

        for allowed in ALLOWED_PATHS:
            if allowed.endswith("/**"):
                base_dir = allowed[:-3]
                if rel_path == base_dir or rel_path.startswith(base_dir + "/"):
                    return True
            else:
                if rel_path == allowed:
                    return True
        return False
    except ValueError:
         return False

def verify_base_sha(base_sha: str) -> bool:
    """Check if base_sha is an ancestor of HEAD (not stale)"""
    try:
        subprocess.run(["git", "rev-parse", "--verify", base_sha], check=True, capture_output=True)
        # Using git merge-base --is-ancestor base_sha HEAD
        result = subprocess.run(["git", "merge-base", "--is-ancestor", base_sha, "HEAD"], capture_output=True)
        return result.returncode == 0
    except subprocess.CalledProcessError:
        return False

def get_changed_files(base_sha: str) -> List[str]:
    try:
        result = subprocess.run(["git", "diff", "--name-only", base_sha, "HEAD"], check=True, capture_output=True, text=True)
        return [line for line in result.stdout.splitlines() if line.strip()]
    except subprocess.CalledProcessError as e:
        raise ScopeGuardError(f"Failed to get changed files: {e.stderr}")

def cmd_claim(task_id: str, base_sha: str, paths: List[str]) -> None:
    ledger = Ledger(LEDGER_FILE)

    if not verify_base_sha(base_sha):
        raise ScopeGuardError(f"BASE_SHA {base_sha} is invalid or stale (not an ancestor of HEAD).")

    for p in paths:
        if not is_path_allowed(p):
            raise ScopeGuardError(f"Path '{p}' is forbidden or outside Allowed Paths.")

    overlapping = ledger.get_overlapping_task(task_id, paths)
    if overlapping:
        raise ScopeGuardError(f"Paths overlap with existing active task: {overlapping}")

    ledger.set_task(task_id, "CLAIM", base_sha, paths)
    logging.info(f"Task {task_id} claimed paths: {paths}")

def cmd_transition(task_id: str, state: str) -> None:
    if state not in STATES:
        raise ScopeGuardError(f"Invalid state: {state}")

    ledger = Ledger(LEDGER_FILE)
    task = ledger.get_task(task_id)

    if not task:
        raise ScopeGuardError(f"Task {task_id} not found in ledger.")

    task["state"] = state
    ledger.save()
    logging.info(f"Task {task_id} transitioned to {state}")

def cmd_verify(task_id: str) -> None:
    ledger = Ledger(LEDGER_FILE)
    task = ledger.get_task(task_id)

    if not task:
        raise ScopeGuardError(f"Task {task_id} not found in ledger.")

    if task["state"] not in ("CLAIM", "ACTIVE"):
        raise ScopeGuardError(f"Task {task_id} is in non-active state: {task['state']}")

    base_sha = task["base_sha"]
    if not verify_base_sha(base_sha):
        raise ScopeGuardError(f"BASE_SHA {base_sha} is invalid or stale.")

    changed_files = get_changed_files(base_sha)
    allowed_task_paths = set(task["paths"])

    denied_paths = []
    permitted_paths = []

    for f in changed_files:
        if not is_path_allowed(f):
            denied_paths.append(f)
        elif f not in allowed_task_paths:
            # Must be in task's claimed paths

            # handle directory matches
            matched = False
            for claim in allowed_task_paths:
                if claim.endswith("/**"):
                    if f.startswith(claim[:-3] + "/"):
                        matched = True
                        break
                elif f == claim:
                    matched = True
                    break
            if not matched:
                denied_paths.append(f)
            else:
                permitted_paths.append(f)
        else:
             permitted_paths.append(f)

    if denied_paths:
        raise ScopeGuardError(f"Unauthorized modifications detected in forbidden or unclaimed paths:\n" + "\n".join(denied_paths))

    print("Verification evidence report:")
    print(f"BASE_SHA: {base_sha}")
    try:
        result_sha = subprocess.run(["git", "rev-parse", "HEAD"], check=True, capture_output=True, text=True).stdout.strip()
        print(f"RESULT_SHA: {result_sha}")
    except subprocess.CalledProcessError:
        print("RESULT_SHA: UNKNOWN")
    print("Permitted paths modified:")
    for p in permitted_paths:
        print(f"  - {p}")
    print("Denied paths modified: None")
    logging.info("Verification passed.")

def main():
    parser = argparse.ArgumentParser(description="ScopeGuard - Enforces exclusive file ownership and path constraints.")
    subparsers = parser.add_subparsers(dest="command", required=True)

    # claim
    claim_parser = subparsers.add_parser("claim", help="Claim paths for a task")
    claim_parser.add_argument("--task-id", required=True)
    claim_parser.add_argument("--base-sha", required=True)
    claim_parser.add_argument("--paths", nargs="+", required=True)

    # transition
    transition_parser = subparsers.add_parser("transition", help="Transition task state")
    transition_parser.add_argument("--task-id", required=True)
    transition_parser.add_argument("--state", choices=list(STATES), required=True)

    # verify
    verify_parser = subparsers.add_parser("verify", help="Verify actual git changes against claims")
    verify_parser.add_argument("--task-id", required=True)

    args = parser.parse_args()

    try:
        if args.command == "claim":
            cmd_claim(args.task_id, args.base_sha, args.paths)
        elif args.command == "transition":
            cmd_transition(args.task_id, args.state)
        elif args.command == "verify":
            cmd_verify(args.task_id)
    except ScopeGuardError as e:
        logging.error(e)
        sys.exit(1)

if __name__ == "__main__":
    main()
