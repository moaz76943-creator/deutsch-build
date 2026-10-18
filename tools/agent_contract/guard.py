import argparse
import fcntl
import json
import os
import subprocess
import sys
from pathlib import Path
from typing import List, Dict, Any, Tuple

LEDGER_FILE = "docs/project-record/task_ledger.json"
LEDGER_LOCK_FILE = ".ledger.lock"

VALID_TRANSITIONS = {
    None: ["CLAIM"],
    "CLAIM": ["ACTIVE", "FAILED", "SUPERSEDE"],
    "ACTIVE": ["BLOCKED", "HANDOFF", "COMPLETE", "FAILED", "SUPERSEDE"],
    "BLOCKED": ["ACTIVE", "HANDOFF", "FAILED", "SUPERSEDE"],
    "HANDOFF": ["ACTIVE"],
    "COMPLETE": [],
    "FAILED": ["CLAIM", "ACTIVE"],
    "SUPERSEDE": []
}

class ScopeGuard:
    def __init__(self, repo_root: str = "."):
        self.repo_root = Path(repo_root).resolve()
        self.ledger_path = self.repo_root / LEDGER_FILE
        self.lock_path = self.repo_root / LEDGER_LOCK_FILE

    def _acquire_lock(self):
        self.lock_fd = open(self.lock_path, "w")
        fcntl.flock(self.lock_fd, fcntl.LOCK_EX)

    def _release_lock(self):
        fcntl.flock(self.lock_fd, fcntl.LOCK_UN)
        self.lock_fd.close()

    def _read_ledger(self) -> Dict[str, Any]:
        if not self.ledger_path.exists():
            return {"tasks": {}}
        try:
            with open(self.ledger_path, "r") as f:
                return json.load(f)
        except json.JSONDecodeError:
            return {"tasks": {}}

    def _write_ledger(self, data: Dict[str, Any]):
        self.ledger_path.parent.mkdir(parents=True, exist_ok=True)
        with open(self.ledger_path, "w") as f:
            json.dump(data, f, indent=2)

    def get_git_changes(self, base_sha: str, target_sha: str) -> List[str]:
        try:
            res = subprocess.run(["git", "-C", str(self.repo_root), "diff", "--name-only", base_sha, target_sha], capture_output=True, text=True, check=True)
            return [line.strip() for line in res.stdout.splitlines() if line.strip()]
        except subprocess.CalledProcessError:
            return []

    def is_ancestor(self, ancestor_sha: str, descendant_sha: str) -> bool:
        try:
            res = subprocess.run(["git", "-C", str(self.repo_root), "merge-base", "--is-ancestor", ancestor_sha, descendant_sha])
            return res.returncode == 0
        except Exception:
            return False

    def get_head_sha(self) -> str:
        try:
            res = subprocess.run(["git", "-C", str(self.repo_root), "rev-parse", "HEAD"], capture_output=True, text=True, check=True)
            return res.stdout.strip()
        except subprocess.CalledProcessError:
            return "UNKNOWN"

    def is_path_allowed(self, path: str, allowed_paths: List[str]) -> bool:
        try:
            abs_path = (self.repo_root / path).resolve()
        except Exception:
            return False

        if not str(abs_path).startswith(str(self.repo_root)):
            return False

        rel_path = abs_path.relative_to(self.repo_root).as_posix()

        for allowed in allowed_paths:
            if allowed.endswith("/**"):
                prefix = allowed[:-3]
                prefix_dir = prefix if prefix.endswith("/") else prefix + "/"
                if rel_path.startswith(prefix_dir) or rel_path == prefix.rstrip("/"):
                    return True
            else:
                if rel_path == allowed:
                    return True
        return False

    def paths_overlap(self, path1: str, path2: str) -> bool:
        p1 = path1[:-3] if path1.endswith("/**") else path1
        p2 = path2[:-3] if path2.endswith("/**") else path2

        if p1 == p2:
            return True

        p1_dir = p1 if p1.endswith("/") else p1 + "/"
        p2_dir = p2 if p2.endswith("/") else p2 + "/"

        if path1.endswith("/**") and p2.startswith(p1_dir):
            return True
        if path2.endswith("/**") and p1.startswith(p2_dir):
            return True

        return False

    def check_conflicts(self, task_id: str, new_paths: List[str], ledger: Dict[str, Any]) -> Tuple[bool, str]:
        for other_task, data in ledger.get("tasks", {}).items():
            if other_task == task_id:
                continue

            if data.get("state") not in ["CLAIM", "ACTIVE", "BLOCKED"]:
                continue

            other_paths = data.get("allowed_paths", [])
            for p1 in new_paths:
                for p2 in other_paths:
                    if self.paths_overlap(p1, p2):
                        return True, f"Conflict: Path '{p1}' overlaps with '{p2}' owned by task {other_task}"
        return False, ""

    def validate(self, task_id: str, base_sha: str, changed_files: List[str] = None, current_sha: str = None) -> Dict[str, Any]:
        self._acquire_lock()
        try:
            ledger = self._read_ledger()
            task_data = ledger.get("tasks", {}).get(task_id)

            if not current_sha:
                current_sha = self.get_head_sha()

            result_payload = {
                "BASE_SHA": base_sha,
                "RESULT_SHA": current_sha,
                "test_evidence": "NOT_PROVIDED",
                "blockers": []
            }

            if not task_data:
                result_payload.update({"status": "REJECTED", "reason": f"Task {task_id} not found in ledger."})
                result_payload["blockers"].append("TASK_NOT_FOUND")
                return result_payload

            allowed_paths = task_data.get("allowed_paths", [])
            state = task_data.get("state")

            # Using real Git tree-diff logic if base_sha and current_sha are available and not "UNKNOWN",
            # and changed_files isn't explicitly provided (we can support passing it manually for testing)
            if not changed_files and current_sha != "UNKNOWN" and base_sha != "UNKNOWN":
                if not self.is_ancestor(base_sha, current_sha):
                    if state in ["CLAIM", "ACTIVE", "COMPLETE"]:
                        result_payload.update({"status": "REJECTED", "reason": f"Stale BASE_SHA: {base_sha} is not an ancestor of {current_sha}"})
                        result_payload["blockers"].append("STALE_BASE_SHA")
                        return result_payload
                changed_files = self.get_git_changes(base_sha, current_sha)

            if changed_files is None:
                changed_files = []

            denied_files = []
            permitted_files = []

            for f in changed_files:
                if self.is_path_allowed(f, allowed_paths):
                    permitted_files.append(f)
                else:
                    denied_files.append(f)

            if denied_files:
                result_payload.update({
                    "status": "REJECTED",
                    "reason": "Unauthorized paths modified.",
                    "denied": denied_files,
                    "permitted": permitted_files
                })
                result_payload["blockers"].append("UNAUTHORIZED_MODIFICATION")
                return result_payload

            result_payload.update({
                "status": "APPROVED",
                "permitted": permitted_files
            })
            return result_payload
        finally:
            self._release_lock()

    def transition(self, task_id: str, new_state: str, allowed_paths: List[str] = None) -> Dict[str, Any]:
        self._acquire_lock()
        try:
            ledger = self._read_ledger()
            tasks = ledger.setdefault("tasks", {})
            task_data = tasks.get(task_id, {})
            current_state = task_data.get("state")

            if new_state not in VALID_TRANSITIONS.get(current_state, []):
                return {"status": "REJECTED", "reason": f"Invalid transition from {current_state} to {new_state}"}

            if allowed_paths is not None:
                conflict, msg = self.check_conflicts(task_id, allowed_paths, ledger)
                if conflict:
                    return {"status": "REJECTED", "reason": msg}
                task_data["allowed_paths"] = allowed_paths

            task_data["state"] = new_state
            tasks[task_id] = task_data
            self._write_ledger(ledger)
            return {"status": "SUCCESS"}
        finally:
            self._release_lock()


def main():
    parser = argparse.ArgumentParser(description="Agent ScopeGuard")
    subparsers = parser.add_subparsers(dest="command")

    val_parser = subparsers.add_parser("validate")
    val_parser.add_argument("--task-id", required=True)
    val_parser.add_argument("--base-sha", required=True)
    val_parser.add_argument("--current-sha", required=False)
    val_parser.add_argument("--changed-files", nargs="*")

    trans_parser = subparsers.add_parser("transition")
    trans_parser.add_argument("--task-id", required=True)
    trans_parser.add_argument("--state", required=True)
    trans_parser.add_argument("--paths", nargs="*")

    args = parser.add_args(sys.argv[1:]) if hasattr(parser, 'add_args') else parser.parse_args()

    guard = ScopeGuard()

    if args.command == "validate":
        res = guard.validate(args.task_id, args.base_sha, args.changed_files, args.current_sha)
        print(json.dumps(res, indent=2))
        if res["status"] != "APPROVED":
            sys.exit(1)

    elif args.command == "transition":
        res = guard.transition(args.task_id, args.state, args.paths)
        print(json.dumps(res, indent=2))
        if res["status"] != "SUCCESS":
            sys.exit(1)

if __name__ == "__main__":
    main()
