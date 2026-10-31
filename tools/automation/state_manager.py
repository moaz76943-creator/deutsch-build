#!/usr/bin/env python3
"""Atomic shared task-state ledger for cooperating automation agents.\n\nCanonical CLI routing is tools/automation/runtime.py; direct execution remains\na compatibility entrypoint for this implementation module.\n"""

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
from typing import Any, Iterator, Mapping, Sequence

HERE = Path(__file__).resolve().parent
DEFAULT_STATE = HERE / "pipeline_state.json"
VALID_STATUSES = frozenset({"PENDING", "IN_PROGRESS", "COMPLETED", "GATED"})
TASK_FIELDS = frozenset(
    {"task_id", "status", "branch", "commit_sha", "test_count", "dependent_tasks"}
)
SHA_RE = re.compile(r"^[0-9a-fA-F]{7,64}$")
ALLOWED_TRANSITIONS = {
    "PENDING": frozenset({"PENDING", "IN_PROGRESS", "GATED"}),
    "IN_PROGRESS": frozenset({"IN_PROGRESS", "COMPLETED", "GATED"}),
    "GATED": frozenset({"GATED", "IN_PROGRESS"}),
    "COMPLETED": frozenset({"COMPLETED"}),
}


class StateLedgerError(ValueError):
    """Raised when state is malformed or an update is unsafe."""


def _read_json(path: Path) -> dict[str, Any]:
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except FileNotFoundError as exc:
        raise StateLedgerError(f"state file not found: {path}") from exc
    except (OSError, json.JSONDecodeError) as exc:
        raise StateLedgerError(f"cannot read state file {path}: {exc}") from exc
    if not isinstance(data, dict):
        raise StateLedgerError("ledger root must be an object")
    return data


def load_state(path: str | Path = DEFAULT_STATE) -> dict[str, Any]:
    """Load a state document. Validation is explicit via validate_state()."""
    return _read_json(Path(path))


def _validate_sha(value: Any, *, allow_empty: bool) -> None:
    if value == "" and allow_empty:
        return
    if not isinstance(value, str) or not SHA_RE.fullmatch(value):
        raise StateLedgerError("commit sha must be 7-64 hexadecimal characters")


def _validate_test_count(value: Any) -> None:
    if isinstance(value, bool) or not isinstance(value, int) or value < 0:
        raise StateLedgerError("test count must be a non-negative integer")


def validate_state(state: Mapping[str, Any]) -> None:
    """Validate schema, statuses, task identities, and dependency integrity."""
    if not isinstance(state, Mapping):
        raise StateLedgerError("ledger root must be an object")
    if state.get("schema_version") != 1:
        raise StateLedgerError("schema_version must be 1")

    tasks = state.get("tasks")
    if not isinstance(tasks, list) or not tasks:
        raise StateLedgerError("tasks must be a non-empty array")

    by_id: dict[str, Mapping[str, Any]] = {}
    for index, task in enumerate(tasks):
        if not isinstance(task, Mapping):
            raise StateLedgerError(f"task[{index}] must be an object")
        if set(task) != TASK_FIELDS:
            missing = sorted(TASK_FIELDS - set(task))
            extra = sorted(set(task) - TASK_FIELDS)
            raise StateLedgerError(
                f"task[{index}] fields invalid; missing={missing} extra={extra}"
            )

        task_id = task["task_id"]
        if not isinstance(task_id, str) or not task_id.strip():
            raise StateLedgerError(f"task[{index}] task_id must be non-empty")
        if task_id in by_id:
            raise StateLedgerError(f"duplicate task_id: {task_id}")
        by_id[task_id] = task

        status = task["status"]
        if status not in VALID_STATUSES:
            raise StateLedgerError(f"{task_id}: invalid status {status!r}")
        branch = task["branch"]
        if not isinstance(branch, str) or not branch.strip():
            raise StateLedgerError(f"{task_id}: branch must be non-empty")
        _validate_sha(task["commit_sha"], allow_empty=True)
        _validate_test_count(task["test_count"])

        dependencies = task["dependent_tasks"]
        if not isinstance(dependencies, list) or not all(
            isinstance(dep, str) and dep.strip() for dep in dependencies
        ):
            raise StateLedgerError(f"{task_id}: dependent_tasks must be a string array")
        if len(dependencies) != len(set(dependencies)):
            raise StateLedgerError(f"{task_id}: duplicate dependency")
        if task_id in dependencies:
            raise StateLedgerError(f"{task_id}: self dependency")

    for task_id, task in by_id.items():
        for dependency in task["dependent_tasks"]:
            if dependency not in by_id:
                raise StateLedgerError(
                    f"{task_id}: dangling dependency {dependency}"
                )

    visiting: set[str] = set()
    visited: set[str] = set()

    def visit(task_id: str) -> None:
        if task_id in visiting:
            raise StateLedgerError(f"dependency cycle detected at {task_id}")
        if task_id in visited:
            return
        visiting.add(task_id)
        for dependency in by_id[task_id]["dependent_tasks"]:
            visit(dependency)
        visiting.remove(task_id)
        visited.add(task_id)

    for task_id in by_id:
        visit(task_id)


@contextmanager
def _locked(path: Path, *, exclusive: bool) -> Iterator[None]:
    lock_path = path.with_name(path.name + ".lock")
    try:
        with lock_path.open("a+", encoding="utf-8") as lock_file:
            fcntl.flock(lock_file.fileno(), fcntl.LOCK_EX if exclusive else fcntl.LOCK_SH)
            try:
                yield
            finally:
                fcntl.flock(lock_file.fileno(), fcntl.LOCK_UN)
    except OSError as exc:
        raise StateLedgerError(f"cannot lock state file {path}: {exc}") from exc


def _atomic_write_json(path: Path, state: Mapping[str, Any]) -> None:
    fd, temp_name = tempfile.mkstemp(
        prefix=f".{path.name}.", suffix=".tmp", dir=path.parent
    )
    temp_path = Path(temp_name)
    try:
        with os.fdopen(fd, "w", encoding="utf-8") as handle:
            json.dump(state, handle, ensure_ascii=False, indent=2)
            handle.write("\n")
            handle.flush()
            os.fsync(handle.fileno())
        os.replace(temp_path, path)
        try:
            directory_fd = os.open(path.parent, os.O_RDONLY | getattr(os, "O_DIRECTORY", 0))
        except OSError:
            directory_fd = None
        if directory_fd is not None:
            try:
                os.fsync(directory_fd)
            finally:
                os.close(directory_fd)
    except OSError as exc:
        raise StateLedgerError(f"cannot atomically write state file {path}: {exc}") from exc
    finally:
        try:
            temp_path.unlink()
        except FileNotFoundError:
            pass


def _find_task(state: Mapping[str, Any], task_id: str) -> dict[str, Any]:
    for task in state["tasks"]:
        if task["task_id"] == task_id:
            return task
    raise StateLedgerError(f"unknown task: {task_id}")


def update_task(
    path: str | Path,
    task_id: str,
    status: str,
    sha: str,
    test_count: int,
) -> dict[str, Any]:
    """Serialize, validate, and atomically persist one task progress update."""
    state_path = Path(path)
    normalized_status = status.upper() if isinstance(status, str) else status
    if normalized_status not in VALID_STATUSES:
        raise StateLedgerError(f"invalid status: {status!r}")
    _validate_sha(sha, allow_empty=False)
    _validate_test_count(test_count)

    with _locked(state_path, exclusive=True):
        state = _read_json(state_path)
        validate_state(state)
        task = _find_task(state, task_id)

        current_status = task["status"]
        if normalized_status not in ALLOWED_TRANSITIONS[current_status]:
            raise StateLedgerError(
                f"invalid transition: {current_status} -> {normalized_status}"
            )
        if test_count < task["test_count"]:
            raise StateLedgerError(
                f"test count cannot decrease: {task['test_count']} -> {test_count}"
            )

        task["status"] = normalized_status
        task["commit_sha"] = sha.lower()
        task["test_count"] = test_count
        validate_state(state)
        _atomic_write_json(state_path, state)
        return dict(task)


def read_task(path: str | Path, task_id: str) -> dict[str, Any]:
    """Return one task plus full prerequisite snapshots for agent consumption."""
    state_path = Path(path)
    with _locked(state_path, exclusive=False):
        state = _read_json(state_path)
        validate_state(state)
        task = _find_task(state, task_id)
        by_id = {entry["task_id"]: entry for entry in state["tasks"]}
        return {
            "task": dict(task),
            "prerequisites": [dict(by_id[dep]) for dep in task["dependent_tasks"]],
        }


def validate_file(path: str | Path) -> int:
    state_path = Path(path)
    with _locked(state_path, exclusive=False):
        state = _read_json(state_path)
        validate_state(state)
        return len(state["tasks"])


def _build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Manage the shared agent pipeline state ledger")
    parser.add_argument("--state", type=Path, default=DEFAULT_STATE)
    subparsers = parser.add_subparsers(dest="command", required=True)

    update = subparsers.add_parser("update", help="atomically record task progress")
    update.add_argument("--task-id", required=True)
    update.add_argument("--status", required=True)
    update.add_argument("--sha", required=True)
    update.add_argument("--tests", required=True, type=int, dest="test_count")

    read = subparsers.add_parser("read", help="read task state and prerequisites")
    read.add_argument("--task-id", required=True)

    subparsers.add_parser("validate", help="validate ledger structure and dependencies")
    return parser


def main(argv: Sequence[str] | None = None) -> int:
    parser = _build_parser()
    args = parser.parse_args(argv)
    try:
        if args.command == "update":
            payload = update_task(
                args.state, args.task_id, args.status, args.sha, args.test_count
            )
        elif args.command == "read":
            payload = read_task(args.state, args.task_id)
        else:
            payload = {"valid": True, "task_count": validate_file(args.state)}
    except StateLedgerError as exc:
        print(json.dumps({"error": str(exc)}, sort_keys=True), file=sys.stderr)
        return 2

    print(json.dumps(payload, ensure_ascii=False, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
