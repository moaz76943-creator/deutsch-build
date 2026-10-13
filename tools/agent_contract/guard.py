#!/usr/bin/env python3
import argparse
import fcntl
import json
import os
import subprocess
import sys
from enum import Enum
from pathlib import Path
from typing import List, Dict, Set, Optional, Tuple

LEDGER_FILE = ".agent_ledger.json"

class TaskState(str, Enum):
    CLAIM = "CLAIM"
    ACTIVE = "ACTIVE"
    BLOCKED = "BLOCKED"
    COMPLETE = "COMPLETE"

class TaskLedger:
    def __init__(self, ledger_path: str = LEDGER_FILE):
        self.ledger_path = ledger_path

    def _read_ledger(self, file_obj) -> Dict:
        try:
            file_obj.seek(0)
            content = file_obj.read()
            if not content:
                return {}
            return json.loads(content)
        except json.JSONDecodeError:
            return {}

    def _write_ledger(self, file_obj, data: Dict):
        file_obj.seek(0)
        file_obj.truncate()
        json.dump(data, file_obj, indent=2)
        file_obj.flush()

    def claim_paths(self, task_id: str, paths: List[str]) -> Tuple[bool, str]:
        # Convert all to absolute paths to detect overlaps correctly
        abs_paths = [os.path.realpath(p) for p in paths]

        with open(self.ledger_path, 'a+') as f:
            fcntl.flock(f, fcntl.LOCK_EX)
            try:
                ledger = self._read_ledger(f)

                # Check for overlaps with other active/claimed tasks
                for other_task_id, task_data in ledger.items():
                    if other_task_id == task_id:
                        continue
                    if task_data.get("state") in [TaskState.COMPLETE.value, TaskState.BLOCKED.value]:
                        continue

                    other_paths = task_data.get("paths", [])
                    for my_path in abs_paths:
                        for other_path in other_paths:
                            # Check ancestor/descendant overlap securely
                            try:
                                if os.path.commonpath([my_path, other_path]) == my_path or os.path.commonpath([my_path, other_path]) == other_path:
                                    return False, f"Overlap detected: {my_path} overlaps with {other_path} claimed by {other_task_id}"
                            except ValueError:
                                pass # Paths are on different drives (Windows) or no common path

                # Register claim
                ledger[task_id] = {
                    "state": TaskState.CLAIM.value,
                    "paths": abs_paths
                }
                self._write_ledger(f, ledger)
                return True, "Success"
            finally:
                fcntl.flock(f, fcntl.LOCK_UN)

    def transition_state(self, task_id: str, new_state: TaskState) -> Tuple[bool, str]:
        with open(self.ledger_path, 'a+') as f:
            fcntl.flock(f, fcntl.LOCK_EX)
            try:
                ledger = self._read_ledger(f)
                if task_id not in ledger:
                    return False, f"Task {task_id} not found in ledger"

                # Only allow valid transitions (simplified for now, any to any is fine as long as it exists)
                ledger[task_id]["state"] = new_state.value
                self._write_ledger(f, ledger)
                return True, "Success"
            finally:
                fcntl.flock(f, fcntl.LOCK_UN)

class ScopeGuard:
    def __init__(self, task_id: str, base_sha: str, allowed_paths: List[str]):
        self.task_id = task_id
        self.base_sha = base_sha
        self.allowed_paths = [os.path.realpath(p.replace("/**", "")) for p in allowed_paths]
        self.ledger = TaskLedger()

    def verify_base_sha(self) -> Tuple[bool, str]:
        # Using git merge-base --is-ancestor to check if base_sha is in the history
        try:
            result = subprocess.run(
                ["git", "merge-base", "--is-ancestor", self.base_sha, "HEAD"],
                capture_output=True,
                text=True
            )
            if result.returncode == 0:
                return True, "Valid base SHA"
            else:
                return False, f"Stale base SHA: {self.base_sha} is not an ancestor of HEAD"
        except FileNotFoundError:
            # For testing without git
            return False, "git command not found"
        except Exception as e:
             return False, f"Git error: {str(e)}"

    def check_paths_allowed(self, changed_files: List[str]) -> Tuple[bool, str, List[str], List[str]]:
        permitted = []
        denied = []
        for file in changed_files:
            abs_file = os.path.realpath(file)
            is_allowed = False
            for allowed_path in self.allowed_paths:
                try:
                    if os.path.commonpath([abs_file, allowed_path]) == allowed_path:
                        is_allowed = True
                        break
                except ValueError:
                    pass
            if is_allowed:
                permitted.append(file)
            else:
                denied.append(file)

        if denied:
            return False, f"Forbidden paths modified: {', '.join(denied)}", permitted, denied
        return True, "All paths allowed", permitted, denied

    def generate_report(self, status: str, message: str, permitted: List[str] = None, denied: List[str] = None):
        # Result SHA is HEAD if we are verifying against the current working tree,
        # or it could be passed in. The prompt asks to return RESULT_SHA. We can get it via git rev-parse HEAD.
        try:
            result = subprocess.run(["git", "rev-parse", "HEAD"], capture_output=True, text=True)
            result_sha = result.stdout.strip() if result.returncode == 0 else "unknown"
        except FileNotFoundError:
            result_sha = "unknown"

        report = {
            "task_id": self.task_id,
            "base_sha": self.base_sha,
            "result_sha": result_sha,
            "status": status,
            "message": message,
            "permitted_paths": permitted or [],
            "denied_paths": denied or []
        }
        print(json.dumps(report, indent=2))

def main():
    parser = argparse.ArgumentParser(description="Agent ScopeGuard")
    parser.add_argument("--task-id", required=True, help="Unique Task ID")
    parser.add_argument("--base-sha", required=True, help="Base commit SHA")
    parser.add_argument("--allowed-paths", nargs='+', required=True, help="List of allowed paths (can include /**)")
    parser.add_argument("--changed-files", nargs='+', default=[], help="List of changed files to verify")
    parser.add_argument("action", choices=["claim", "verify", "complete", "block", "active"], help="Action to perform")

    args = parser.parse_args()

    guard = ScopeGuard(args.task_id, args.base_sha, args.allowed_paths)

    if args.action == "verify":
        # 1. Verify Base SHA
        valid_sha, sha_msg = guard.verify_base_sha()
        if not valid_sha:
            guard.generate_report("FAIL", sha_msg)
            sys.exit(1)

        # 2. Verify allowed paths
        if not args.changed_files:
            guard.generate_report("PASS", "No files to verify (or empty changed-files list)")
            sys.exit(0)

        valid_paths, path_msg, permitted, denied = guard.check_paths_allowed(args.changed_files)
        if not valid_paths:
            guard.generate_report("FAIL", path_msg, permitted, denied)
            sys.exit(1)

        guard.generate_report("PASS", "Verification passed", permitted, denied)
        sys.exit(0)

    elif args.action == "claim":
        if not args.changed_files:
            guard.generate_report("FAIL", "Must provide changed files/paths to claim")
            sys.exit(1)

        valid_paths, path_msg, permitted, denied = guard.check_paths_allowed(args.changed_files)
        if not valid_paths:
            guard.generate_report("FAIL", path_msg, permitted, denied)
            sys.exit(1)

        success, msg = guard.ledger.claim_paths(args.task_id, args.changed_files)
        if success:
            guard.generate_report("PASS", msg, permitted, denied)
            sys.exit(0)
        else:
            guard.generate_report("FAIL", msg, permitted, denied)
            sys.exit(1)

    elif args.action in ["complete", "block", "active"]:
        state_map = {
            "complete": TaskState.COMPLETE,
            "block": TaskState.BLOCKED,
            "active": TaskState.ACTIVE
        }
        success, msg = guard.ledger.transition_state(args.task_id, state_map[args.action])
        if success:
            guard.generate_report("PASS", msg)
            sys.exit(0)
        else:
            guard.generate_report("FAIL", msg)
            sys.exit(1)

if __name__ == "__main__":
    main()
