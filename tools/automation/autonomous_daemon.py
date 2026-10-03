#!/usr/bin/env python3
"""Self-driving, fail-closed dispatcher for the shared automation pipeline.\n\nCanonical CLI routing is tools/automation/runtime.py; direct execution remains\na compatibility entrypoint for this implementation module.\n"""

from __future__ import annotations

import argparse
from contextlib import contextmanager
import fcntl
import json
import os
from pathlib import Path
import re
import sys
import tempfile
import time
from typing import Any, Iterator, Mapping, Sequence

HERE = Path(__file__).resolve().parent
DEFAULT_BACKLOG = HERE / "backlog.json"
DEFAULT_STATE = HERE / "pipeline_state.json"
DEFAULT_CLAIMS = HERE / "claims.json"
DEFAULT_DISPATCH_DIR = HERE / "dispatches"
ACTIVE_CLAIM_STATUSES = frozenset({"ACTIVE", "CLAIMED", "IN_PROGRESS"})
SHA_RE = re.compile(r"^[0-9a-fA-F]{7,64}$")


class DispatcherError(ValueError):
    """Raised when live dispatcher inputs are missing or inconsistent."""


def _read_object(path: Path, *, required: bool = True) -> dict[str, Any]:
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except FileNotFoundError:
        if not required:
            return {}
        raise DispatcherError(f"file not found: {path}") from None
    except (OSError, json.JSONDecodeError) as exc:
        raise DispatcherError(f"cannot read JSON file {path}: {exc}") from exc
    if not isinstance(data, dict):
        raise DispatcherError(f"JSON root must be an object: {path}")
    return data


def _atomic_write_json(path: Path, payload: Mapping[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, temp_name = tempfile.mkstemp(prefix=f".{path.name}.", suffix=".tmp", dir=path.parent)
    temp_path = Path(temp_name)
    try:
        with os.fdopen(fd, "w", encoding="utf-8") as handle:
            json.dump(payload, handle, ensure_ascii=False, indent=2, sort_keys=True)
            handle.write("\n")
            handle.flush()
            os.fsync(handle.fileno())
        os.replace(temp_path, path)
    except OSError as exc:
        raise DispatcherError(f"cannot atomically write {path}: {exc}") from exc
    finally:
        try:
            temp_path.unlink()
        except FileNotFoundError:
            pass


@contextmanager
def _exclusive_lock(lock_path: Path) -> Iterator[None]:
    lock_path.parent.mkdir(parents=True, exist_ok=True)
    try:
        with lock_path.open("a+", encoding="utf-8") as handle:
            fcntl.flock(handle.fileno(), fcntl.LOCK_EX)
            try:
                yield
            finally:
                fcntl.flock(handle.fileno(), fcntl.LOCK_UN)
    except OSError as exc:
        raise DispatcherError(f"cannot lock dispatcher state: {exc}") from exc


def _task_map(document: Mapping[str, Any], name: str) -> dict[str, dict[str, Any]]:
    tasks = document.get("tasks")
    if document.get("schema_version") != 1 or not isinstance(tasks, list):
        raise DispatcherError(f"{name} must have schema_version=1 and a tasks array")
    result: dict[str, dict[str, Any]] = {}
    for index, task in enumerate(tasks):
        if not isinstance(task, dict):
            raise DispatcherError(f"{name}.tasks[{index}] must be an object")
        task_id = task.get("task_id")
        if not isinstance(task_id, str) or not task_id.strip():
            raise DispatcherError(f"{name}.tasks[{index}] missing task_id")
        if task_id in result:
            raise DispatcherError(f"duplicate task_id in {name}: {task_id}")
        result[task_id] = task
    return result


def _load_claims(path: Path) -> dict[str, Any]:
    data = _read_object(path, required=False)
    if not data:
        return {"schema_version": 1, "claims": []}
    if data.get("schema_version") != 1 or not isinstance(data.get("claims"), list):
        raise DispatcherError("claims.json must have schema_version=1 and a claims array")
    return data


class AutonomousDispatcher:
    """Select and atomically claim one dependency-ready task at a time."""

    def __init__(
        self,
        *,
        backlog_path: str | Path = DEFAULT_BACKLOG,
        state_path: str | Path = DEFAULT_STATE,
        claims_path: str | Path = DEFAULT_CLAIMS,
        dispatch_dir: str | Path = DEFAULT_DISPATCH_DIR,
    ) -> None:
        self.backlog_path = Path(backlog_path)
        self.state_path = Path(state_path)
        self.claims_path = Path(claims_path)
        self.dispatch_dir = Path(dispatch_dir)
        self.lock_path = self.state_path.with_name(self.state_path.name + ".dispatch.lock")

    def _snapshot(self) -> tuple[dict[str, Any], dict[str, Any], dict[str, Any]]:
        return (
            _read_object(self.backlog_path),
            _read_object(self.state_path),
            _load_claims(self.claims_path),
        )

    def _validated_maps(
        self,
        backlog: Mapping[str, Any],
        state: Mapping[str, Any],
    ) -> tuple[dict[str, dict[str, Any]], dict[str, dict[str, Any]]]:
        backlog_tasks = _task_map(backlog, "backlog")
        state_tasks = _task_map(state, "pipeline_state")
        if set(backlog_tasks) != set(state_tasks):
            missing_state = sorted(set(backlog_tasks) - set(state_tasks))
            missing_backlog = sorted(set(state_tasks) - set(backlog_tasks))
            raise DispatcherError(
                f"backlog/state task mismatch; missing_state={missing_state} missing_backlog={missing_backlog}"
            )

        for task_id, backlog_task in backlog_tasks.items():
            state_task = state_tasks[task_id]
            prerequisites = backlog_task.get("prerequisites", [])
            state_prerequisites = state_task.get("dependent_tasks", [])
            if not isinstance(prerequisites, list) or not all(isinstance(dep, str) for dep in prerequisites):
                raise DispatcherError(f"{task_id}: backlog prerequisites must be a string array")
            if not isinstance(state_prerequisites, list) or not all(
                isinstance(dep, str) for dep in state_prerequisites
            ):
                raise DispatcherError(f"{task_id}: state dependent_tasks must be a string array")
            if prerequisites != state_prerequisites:
                raise DispatcherError(f"{task_id}: backlog/state prerequisites disagree")
            for dependency in prerequisites:
                if dependency not in state_tasks:
                    raise DispatcherError(f"{task_id}: unknown prerequisite {dependency}")

            branch = backlog_task.get("branch")
            scope = backlog_task.get("allowed_paths")
            if not isinstance(branch, str) or not branch.strip():
                raise DispatcherError(f"{task_id}: target branch must be non-empty")
            if not isinstance(scope, list) or not scope or not all(
                isinstance(path, str) and path.strip() for path in scope
            ):
                raise DispatcherError(f"{task_id}: allowed_paths must be a non-empty string array")
        return backlog_tasks, state_tasks

    @staticmethod
    def _active_claim_ids(claims: Mapping[str, Any]) -> set[str]:
        active: set[str] = set()
        for index, claim in enumerate(claims["claims"]):
            if not isinstance(claim, Mapping):
                raise DispatcherError(f"claims[{index}] must be an object")
            task_id = claim.get("task_id")
            status = claim.get("status")
            if not isinstance(task_id, str) or not isinstance(status, str):
                raise DispatcherError(f"claims[{index}] missing task_id/status")
            if status.upper() in ACTIVE_CLAIM_STATUSES:
                active.add(task_id)
        return active

    def _candidate_ids(
        self,
        backlog: Mapping[str, Any],
        state: Mapping[str, Any],
        claims: Mapping[str, Any],
    ) -> tuple[list[str], list[str], list[str]]:
        backlog_tasks, state_tasks = self._validated_maps(backlog, state)
        active_claims = self._active_claim_ids(claims)
        ready: list[str] = []
        blocked: list[str] = []
        in_progress: list[str] = []

        for backlog_task in backlog["tasks"]:
            task_id = backlog_task["task_id"]
            state_task = state_tasks[task_id]
            status = state_task.get("status")
            if status == "IN_PROGRESS":
                in_progress.append(task_id)
                continue
            if status != "PENDING":
                continue
            if backlog_task.get("status") != "PENDING":
                blocked.append(task_id)
                continue
            if task_id in active_claims:
                blocked.append(task_id)
                continue
            external = backlog_task.get("external_prerequisites", [])
            if external:
                blocked.append(task_id)
                continue

            dependencies = backlog_task.get("prerequisites", [])
            if not all(state_tasks[dep].get("status") == "COMPLETED" for dep in dependencies):
                blocked.append(task_id)
                continue

            for dependency in dependencies:
                sha = state_tasks[dependency].get("commit_sha")
                if not isinstance(sha, str) or not SHA_RE.fullmatch(sha):
                    raise DispatcherError(
                        f"{task_id}: COMPLETED prerequisite {dependency} has invalid commit_sha"
                    )
            ready.append(task_id)
        return ready, blocked, in_progress

    def _dispatch_payload(
        self,
        task_id: str,
        backlog_tasks: Mapping[str, Mapping[str, Any]],
        state_tasks: Mapping[str, Mapping[str, Any]],
    ) -> dict[str, Any]:
        task = backlog_tasks[task_id]
        prerequisite_shas = {
            dependency: str(state_tasks[dependency]["commit_sha"]).lower()
            for dependency in task.get("prerequisites", [])
        }
        return {
            "schema_version": 1,
            "task_id": task_id,
            "target_branch": task["branch"],
            "authorized_scope": list(task["allowed_paths"]),
            "prerequisite_shas": prerequisite_shas,
        }

    def status(self) -> dict[str, Any]:
        backlog, state, claims = self._snapshot()
        ready, blocked, in_progress = self._candidate_ids(backlog, state, claims)
        return {
            "ready": ready,
            "blocked": blocked,
            "in_progress": in_progress,
            "active_claims": sorted(self._active_claim_ids(claims)),
        }

    def poll_once(self, *, dry_run: bool = False) -> dict[str, Any]:
        if dry_run:
            backlog, state, claims = self._snapshot()
            ready, _, _ = self._candidate_ids(backlog, state, claims)
            if not ready:
                return {"state": "NO_CANDIDATE"}
            task_id = ready[0]
            backlog_tasks, state_tasks = self._validated_maps(backlog, state)
            return {
                "state": "DRY_RUN",
                "task_id": task_id,
                "dispatch": self._dispatch_payload(task_id, backlog_tasks, state_tasks),
            }

        with _exclusive_lock(self.lock_path):
            backlog, state, claims = self._snapshot()
            ready, _, _ = self._candidate_ids(backlog, state, claims)
            if not ready:
                return {"state": "NO_CANDIDATE"}

            task_id = ready[0]
            backlog_tasks, state_tasks = self._validated_maps(backlog, state)
            payload = self._dispatch_payload(task_id, backlog_tasks, state_tasks)

            claim = {
                "claim_id": f"AUTO::{task_id}",
                "task_id": task_id,
                "status": "ACTIVE",
                "branch": payload["target_branch"],
                "allowed_paths": payload["authorized_scope"],
                "prerequisite_shas": payload["prerequisite_shas"],
            }
            claims["claims"].append(claim)
            state_tasks[task_id]["status"] = "IN_PROGRESS"

            # Persist fail-closed: dispatch and claim become visible before state is advanced.
            _atomic_write_json(self.dispatch_dir / f"{task_id}.dispatch.json", payload)
            _atomic_write_json(self.claims_path, claims)
            _atomic_write_json(self.state_path, state)
            return {"state": "DISPATCHED", "task_id": task_id}


def _build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Autonomously claim dependency-ready automation tasks")
    parser.add_argument("--backlog", type=Path, default=DEFAULT_BACKLOG)
    parser.add_argument("--state-file", type=Path, default=DEFAULT_STATE)
    parser.add_argument("--claims", type=Path, default=DEFAULT_CLAIMS)
    parser.add_argument("--dispatch-dir", type=Path, default=DEFAULT_DISPATCH_DIR)
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument("--poll-once", action="store_true")
    mode.add_argument("--status", action="store_true")
    parser.add_argument("--dry-run", action="store_true")
    return parser


def main(argv: Sequence[str] | None = None) -> int:
    args = _build_parser().parse_args(argv)
    dispatcher = AutonomousDispatcher(
        backlog_path=args.backlog,
        state_path=args.state_file,
        claims_path=args.claims,
        dispatch_dir=args.dispatch_dir,
    )
    try:
        if args.status:
            print(json.dumps(dispatcher.status(), sort_keys=True))
            return 0
        if args.poll_once or args.dry_run:
            print(json.dumps(dispatcher.poll_once(dry_run=args.dry_run), sort_keys=True))
            return 0

        while True:
            result = dispatcher.poll_once()
            if result["state"] == "DISPATCHED":
                print(json.dumps(result, sort_keys=True), flush=True)
            time.sleep(5)
    except DispatcherError as exc:
        print(json.dumps({"error": str(exc)}, sort_keys=True), file=sys.stderr)
        return 2
    except KeyboardInterrupt:
        return 0


if __name__ == "__main__":
    raise SystemExit(main())
