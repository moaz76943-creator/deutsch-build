import argparse
import json
import logging
import os
import subprocess
import sys
from pathlib import Path
from typing import Dict, List, Optional, Set

# Configuration
LEDGER_PATH = Path("tools/agent_contract/.scope_guard_ledger.json")

ALLOWED_PATHS = [
    "AGENTS.md",
    "docs/project-record/",
    "tools/agent_contract/",
]

VALID_TRANSITIONS = {
    "CLAIM": ["ACTIVE", "BLOCKED"],
    "ACTIVE": ["BLOCKED", "COMPLETE", "FAILED"],
    "BLOCKED": ["ACTIVE", "COMPLETE", "FAILED"],
    "COMPLETE": [],
    "FAILED": ["CLAIM"],
}


class ScopeGuardError(Exception):
    pass


class ScopeGuard:
    def __init__(self, repo_root: Path):
        self.repo_root = repo_root.resolve()
        self.ledger_path = self.repo_root / LEDGER_PATH
        self._load_ledger()

    def _load_ledger(self) -> None:
        if self.ledger_path.exists():
            try:
                with open(self.ledger_path, "r", encoding="utf-8") as f:
                    self.ledger = json.load(f)
            except json.JSONDecodeError:
                self.ledger = {}
        else:
            self.ledger = {}

    def _save_ledger(self) -> None:
        with open(self.ledger_path, "w", encoding="utf-8") as f:
            json.dump(self.ledger, f, indent=2)

    def _check_stale_base_sha(self, base_sha: str) -> None:
        """Check if base_sha is an ancestor of HEAD (i.e. not stale)."""
        try:
            subprocess.run(
                ["git", "merge-base", "--is-ancestor", base_sha, "HEAD"],
                check=True,
                cwd=self.repo_root,
                capture_output=True,
            )
        except subprocess.CalledProcessError:
            raise ScopeGuardError(f"Stale branch-base SHA detected. Base SHA '{base_sha}' is behind the latest completed merge.")

    def _is_path_allowed(self, path_str: str) -> bool:
        """Check if a path is within the allowed paths list."""
        path = (self.repo_root / path_str).resolve()

        # Prevent traversal outside the repo root
        if not str(path).startswith(str(self.repo_root)):
            return False

        # Convert back to relative string for comparison
        rel_path = str(path.relative_to(self.repo_root))

        for allowed in ALLOWED_PATHS:
            if allowed.endswith("/"):
                # Directory match
                if rel_path == allowed[:-1] or rel_path.startswith(allowed):
                    return True
            else:
                # Exact file match
                if rel_path == allowed:
                    return True
        return False

    def _get_changed_files(self, base_sha: str) -> List[str]:
        """Get the list of changed files relative to base_sha using git diff."""
        try:
            # Find changed files comparing the working tree and index to base_sha
            cmd = ["git", "diff", "--name-only", base_sha]
            result = subprocess.run(
                cmd, capture_output=True, text=True, check=True, cwd=self.repo_root
            )
            # Also check untracked files
            untracked_cmd = ["git", "ls-files", "--others", "--exclude-standard"]
            untracked_result = subprocess.run(
                untracked_cmd, capture_output=True, text=True, check=True, cwd=self.repo_root
            )

            changed_files = set()
            if result.stdout:
                changed_files.update(result.stdout.strip().split("\n"))
            if untracked_result.stdout:
                changed_files.update(untracked_result.stdout.strip().split("\n"))

            return [f for f in changed_files if f]
        except subprocess.CalledProcessError as e:
            raise ScopeGuardError(f"Failed to get changed files: {e.stderr}")

    def validate_changes(self, task_id: str, base_sha: str) -> List[str]:
        """Validates that all changed files are within the explicitly claimed allowed paths."""
        changed_files = self._get_changed_files(base_sha)
        denied_files = []
        task_paths = self.ledger.get(task_id, {}).get("paths", [])

        for file in changed_files:
            # 1. Global allowlist check
            if not self._is_path_allowed(file):
                denied_files.append(file)
                continue

            # 2. Explicit task claim check
            claimed = False
            for allowed in task_paths:
                if allowed.endswith("/"):
                    if file == allowed[:-1] or file.startswith(allowed):
                        claimed = True
                        break
                else:
                    if file == allowed:
                        claimed = True
                        break

            if not claimed:
                denied_files.append(file)

        if denied_files:
            raise ScopeGuardError(
                f"Unauthorized file modifications detected (not explicitly claimed or globally forbidden): {', '.join(denied_files)}"
            )
        return changed_files

    def transition_task(self, task_id: str, new_state: str, base_sha: str, paths: List[str] = None) -> None:
        """Transitions a task to a new state."""
        new_state = new_state.upper()
        if new_state not in VALID_TRANSITIONS and new_state != "CLAIM":
            raise ScopeGuardError(f"Invalid state: {new_state}")

        if base_sha:
            self._check_stale_base_sha(base_sha)

        # For new claims, paths must be provided
        if task_id not in self.ledger:
            if new_state != "CLAIM":
                raise ScopeGuardError(f"Task {task_id} does not exist. Must CLAIM first.")
            if not paths:
                raise ScopeGuardError("Paths must be provided for initial CLAIM.")
            self.ledger[task_id] = {
                "state": "CLAIM",
                "base_sha": base_sha,
                "paths": paths,
            }
        else:
            current_state = self.ledger[task_id]["state"]
            if new_state not in VALID_TRANSITIONS.get(current_state, []):
                raise ScopeGuardError(
                    f"Invalid transition from {current_state} to {new_state}"
                )

            self.ledger[task_id]["state"] = new_state
            if paths is not None and paths:
                self.ledger[task_id]["paths"] = paths

        # Ensure that no other active tasks overlap paths
        if new_state in ["CLAIM", "ACTIVE"]:
            task_paths = self.ledger[task_id]["paths"]

            # Check path permissions first
            for path in task_paths:
                if not self._is_path_allowed(path):
                    raise ScopeGuardError(f"Cannot claim unauthorized path: {path}")

            for existing_task_id, task_data in self.ledger.items():
                if existing_task_id != task_id and task_data["state"] in ["CLAIM", "ACTIVE"]:
                    # Check for exact matches or directory overlaps
                    for p1 in task_paths:
                        for p2 in task_data.get("paths", []):
                            if p1 == p2 or (p1.endswith("/") and p2.startswith(p1)) or (p2.endswith("/") and p1.startswith(p2)):
                                raise ScopeGuardError(
                                    f"Overlapping claim with task {existing_task_id} on paths: {p1} / {p2}"
                                )

            if base_sha:
                 self.ledger[task_id]["base_sha"] = base_sha

            # Validate code changes on state transitions (except CLAIM/FAILED)
            if new_state in ["COMPLETE", "ACTIVE"]:
                self.validate_changes(task_id, self.ledger[task_id]["base_sha"])

        self._save_ledger()


def main():
    parser = argparse.ArgumentParser(description="ScopeGuard - Repository Ownership and Path Validator")
    parser.add_argument("--task-id", required=True, help="The task ID")
    parser.add_argument("--base-sha", required=True, help="The base git SHA")
    parser.add_argument("--state", required=True, choices=["CLAIM", "ACTIVE", "BLOCKED", "COMPLETE", "FAILED"], help="The state to transition to")
    parser.add_argument("--paths", nargs="*", help="List of paths to claim")

    args = parser.parse_args()

    repo_root = Path.cwd()
    guard = ScopeGuard(repo_root)

    try:
        guard.transition_task(args.task_id, args.state, args.base_sha, args.paths)
        try:
            result_sha = subprocess.run(
                ["git", "rev-parse", "HEAD"], capture_output=True, text=True, check=True
            ).stdout.strip()
        except subprocess.CalledProcessError:
            result_sha = "UNKNOWN"

        if args.state in ["ACTIVE", "COMPLETE"]:
            changed = guard.validate_changes(args.task_id, args.base_sha)
            print(f"✅ State transition to {args.state} successful.")
            print(f"BASE_SHA: {args.base_sha}")
            print(f"RESULT_SHA: {result_sha}")
            print(f"Allowed changes: {len(changed)} file(s).")
        else:
            print(f"✅ State transition to {args.state} successful.")
            print(f"BASE_SHA: {args.base_sha}")
            print(f"RESULT_SHA: {result_sha}")
        sys.exit(0)
    except ScopeGuardError as e:
        print(f"❌ ScopeGuard Blocked: {e}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"❌ Unexpected Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
