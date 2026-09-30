#!/usr/bin/env python3
"""Pure-Python dependency resolver and bounded task allocator for project backlog items."""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path
from typing import Any, Mapping, Sequence

SUCCESS_STATES = frozenset({"verified", "integrated", "complete"})
ALLOWED_STATUSES = frozenset(
    {"pending", "blocked", "verified", "integrated", "complete", "failed", "quarantined"}
)
ALLOWED_KINDS = frozenset({"component", "integration_stage"})
TOKEN_RE = re.compile(r"^[A-Za-z0-9][A-Za-z0-9._/-]*$")


class BacklogValidationError(ValueError):
    """Raised when backlog or worker input violates dispatcher invariants."""


def _require_str(value: Any, path: str) -> str:
    if not isinstance(value, str) or not value.strip():
        raise BacklogValidationError(f"{path}: expected non-empty string")
    return value.strip()


def _require_string_list(value: Any, path: str) -> list[str]:
    if not isinstance(value, list) or any(not isinstance(item, str) or not item.strip() for item in value):
        raise BacklogValidationError(f"{path}: expected list of non-empty strings")
    return [item.strip() for item in value]


def validate_backlog(backlog: Mapping[str, Any]) -> None:
    if not isinstance(backlog, dict):
        raise BacklogValidationError("$: backlog root must be an object")
    if backlog.get("schema_version") != 1:
        raise BacklogValidationError("$.schema_version: expected 1")
    for key in ("program_id", "repo", "base_main_sha"):
        _require_str(backlog.get(key), f"$.{key}")

    items = backlog.get("items")
    if not isinstance(items, list) or not items:
        raise BacklogValidationError("$.items: expected non-empty list")

    ids: set[str] = set()
    by_id: dict[str, Mapping[str, Any]] = {}
    for index, item in enumerate(items):
        path = f"$.items[{index}]"
        if not isinstance(item, dict):
            raise BacklogValidationError(f"{path}: expected object")
        item_id = _require_str(item.get("id"), f"{path}.id")
        if TOKEN_RE.fullmatch(item_id) is None:
            raise BacklogValidationError(f"{path}.id: invalid item id {item_id!r}")
        if item_id in ids:
            raise BacklogValidationError(f"{path}.id: duplicate item id {item_id!r}")
        ids.add(item_id)
        by_id[item_id] = item

        kind = item.get("kind")
        if kind not in ALLOWED_KINDS:
            raise BacklogValidationError(f"{path}.kind: unsupported kind {kind!r}")
        _require_str(item.get("stage"), f"{path}.stage")
        status = item.get("status")
        if status not in ALLOWED_STATUSES:
            raise BacklogValidationError(f"{path}.status: unsupported status {status!r}")
        priority = item.get("priority")
        if isinstance(priority, bool) or not isinstance(priority, int):
            raise BacklogValidationError(f"{path}.priority: expected integer")
        dependencies = _require_string_list(item.get("dependencies"), f"{path}.dependencies")
        if len(dependencies) != len(set(dependencies)):
            raise BacklogValidationError(f"{path}.dependencies: duplicate dependency")
        _require_string_list(item.get("required_capabilities"), f"{path}.required_capabilities")
        _require_str(item.get("mutable_scope"), f"{path}.mutable_scope")
        _require_string_list(item.get("evidence"), f"{path}.evidence")

    for item_id, item in by_id.items():
        for dependency in item["dependencies"]:
            if dependency == item_id:
                raise BacklogValidationError(f"{item_id}: dependency cycle via self-reference")
            if dependency not in by_id:
                raise BacklogValidationError(f"{item_id}: unknown dependency {dependency!r}")

    visiting: set[str] = set()
    visited: set[str] = set()

    def visit(item_id: str, trail: tuple[str, ...]) -> None:
        if item_id in visiting:
            cycle = " -> ".join((*trail, item_id))
            raise BacklogValidationError(f"dependency cycle: {cycle}")
        if item_id in visited:
            return
        visiting.add(item_id)
        for dependency in by_id[item_id]["dependencies"]:
            visit(dependency, (*trail, item_id))
        visiting.remove(item_id)
        visited.add(item_id)

    for item_id in by_id:
        visit(item_id, ())


def load_backlog(path: str | Path) -> dict[str, Any]:
    value = json.loads(Path(path).read_text(encoding="utf-8"))
    if not isinstance(value, dict):
        raise BacklogValidationError("$: backlog root must be an object")
    validate_backlog(value)
    return value


def resolve_ready_tasks(backlog: Mapping[str, Any]) -> list[dict[str, Any]]:
    validate_backlog(backlog)
    by_id = {item["id"]: item for item in backlog["items"]}
    ready = [
        dict(item)
        for item in backlog["items"]
        if item["kind"] == "integration_stage"
        and item["status"] == "pending"
        and all(by_id[dep]["status"] in SUCCESS_STATES for dep in item["dependencies"])
    ]
    return sorted(ready, key=lambda item: (-item["priority"], item["id"]))


def _validate_workers(workers: Sequence[Mapping[str, Any]]) -> list[dict[str, Any]]:
    if not isinstance(workers, Sequence) or isinstance(workers, (str, bytes)):
        raise BacklogValidationError("workers: expected sequence")
    normalized: list[dict[str, Any]] = []
    seen: set[str] = set()
    for index, worker in enumerate(workers):
        path = f"workers[{index}]"
        if not isinstance(worker, Mapping):
            raise BacklogValidationError(f"{path}: expected object")
        worker_id = _require_str(worker.get("id"), f"{path}.id")
        if worker_id in seen:
            raise BacklogValidationError(f"{path}.id: duplicate worker id {worker_id!r}")
        seen.add(worker_id)
        capabilities = sorted(set(_require_string_list(worker.get("capabilities"), f"{path}.capabilities")))
        capacity = worker.get("capacity", 1)
        if isinstance(capacity, bool) or not isinstance(capacity, int) or capacity < 1:
            raise BacklogValidationError(f"{path}.capacity: expected integer >= 1")
        normalized.append({"id": worker_id, "capabilities": capabilities, "capacity": capacity})
    return sorted(normalized, key=lambda worker: worker["id"])


def allocate_tasks(
    backlog: Mapping[str, Any], workers: Sequence[Mapping[str, Any]]
) -> dict[str, list[dict[str, str]]]:
    ready = resolve_ready_tasks(backlog)
    worker_state = _validate_workers(workers)
    used_capacity = {worker["id"]: 0 for worker in worker_state}
    claimed_scopes: set[str] = set()
    assignments: list[dict[str, str]] = []
    unassigned: list[dict[str, str]] = []

    for task in ready:
        scope = task["mutable_scope"]
        if scope in claimed_scopes:
            unassigned.append({"task_id": task["id"], "reason": "mutable_scope_claimed"})
            continue

        required = set(task["required_capabilities"])
        eligible = [
            worker
            for worker in worker_state
            if used_capacity[worker["id"]] < worker["capacity"]
            and required.issubset(set(worker["capabilities"]))
        ]
        if not eligible:
            unassigned.append(
                {"task_id": task["id"], "reason": "no_eligible_worker_capacity"}
            )
            continue

        worker = eligible[0]
        used_capacity[worker["id"]] += 1
        claimed_scopes.add(scope)
        assignments.append({"task_id": task["id"], "worker_id": worker["id"]})

    return {"assignments": assignments, "unassigned": unassigned}


def _main() -> int:
    parser = argparse.ArgumentParser(description="Resolve and allocate autonomous backlog tasks")
    parser.add_argument("backlog", type=Path)
    parser.add_argument("--workers", type=Path, help="JSON array of worker capability objects")
    args = parser.parse_args()

    backlog = load_backlog(args.backlog)
    ready = resolve_ready_tasks(backlog)
    if args.workers is None:
        print(json.dumps({"ready": [item["id"] for item in ready]}, indent=2))
        return 0

    workers = json.loads(args.workers.read_text(encoding="utf-8"))
    print(json.dumps(allocate_tasks(backlog, workers), indent=2, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(_main())
