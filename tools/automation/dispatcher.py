#!/usr/bin/env python3
"""Fail-closed autonomous backlog dispatcher for isolated project work.

The dispatcher is intentionally read-only with respect to Git and GitHub. It
observes local branch names and claim snapshots, evaluates dependency readiness,
and emits a deterministic issue/PR specification for the next safe task. It
never creates branches, claims, pull requests, or workflow runs itself.

Canonical CLI routing is owned by tools/automation/runtime.py. Direct execution
remains a compatibility shim and delegates to the same main(argv) implementation.
"""

from __future__ import annotations

import argparse
import fnmatch
import json
import subprocess
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Iterable, Mapping, Sequence

HERE = Path(__file__).resolve().parent
DEFAULT_BACKLOG = HERE / "backlog.json"
VALID_DOMAINS = frozenset({"UI", "Audio", "DataMatrix", "Database", "Payments"})
VALID_STATUSES = frozenset({"PENDING", "IN_PROGRESS", "VERIFIED", "MERGED"})
DEFAULT_COMPLETE_STATUSES = frozenset({"VERIFIED", "MERGED"})
ACTIVE_CLAIM_STATUSES = frozenset({"ACTIVE", "CLAIMED", "IN_PROGRESS"})


class BacklogValidationError(ValueError):
    """Raised when the backlog or claim snapshot is unsafe or inconsistent."""


def load_backlog(path: str | Path = DEFAULT_BACKLOG) -> dict[str, Any]:
    data = json.loads(Path(path).read_text(encoding="utf-8"))
    if not isinstance(data, dict):
        raise BacklogValidationError("backlog root must be an object")
    return data


def _normalize_path_pattern(pattern: str) -> str:
    pattern = pattern.strip().replace("\\", "/")
    while pattern.startswith("./"):
        pattern = pattern[2:]
    return pattern


def _scope_root(pattern: str) -> str:
    normalized = _normalize_path_pattern(pattern)
    for marker in ("/**", "/*"):
        if normalized.endswith(marker):
            return normalized[: -len(marker)].rstrip("/")
    wildcard_positions = [i for i in (normalized.find("*"), normalized.find("?"), normalized.find("[")) if i >= 0]
    if wildcard_positions:
        return normalized[: min(wildcard_positions)].rstrip("/")
    return normalized.rstrip("/")


def _patterns_overlap(left: str, right: str) -> bool:
    """Conservatively detect whether two claim path patterns may intersect."""
    left = _normalize_path_pattern(left)
    right = _normalize_path_pattern(right)
    if not left or not right:
        return True
    if left in {"*", "**", "**/*"} or right in {"*", "**", "**/*"}:
        return True
    if fnmatch.fnmatchcase(left, right) or fnmatch.fnmatchcase(right, left):
        return True
    left_root = _scope_root(left)
    right_root = _scope_root(right)
    if not left_root or not right_root:
        return True
    return (
        left_root == right_root
        or left_root.startswith(right_root + "/")
        or right_root.startswith(left_root + "/")
    )


@dataclass(frozen=True)
class GitBranchSnapshot:
    names: frozenset[str]

    @classmethod
    def empty(cls) -> "GitBranchSnapshot":
        return cls(frozenset())

    @classmethod
    def from_names(cls, names: Iterable[str]) -> "GitBranchSnapshot":
        return cls(frozenset(name.strip() for name in names if str(name).strip()))

    @classmethod
    def from_local_git(cls, repo_root: str | Path = ".") -> "GitBranchSnapshot":
        try:
            result = subprocess.run(
                ["git", "for-each-ref", "--format=%(refname:short)", "refs/heads", "refs/remotes/origin"],
                cwd=Path(repo_root),
                text=True,
                capture_output=True,
                check=True,
            )
        except (OSError, subprocess.CalledProcessError) as exc:
            raise BacklogValidationError(f"cannot read git branches: {exc}") from exc
        names = []
        for raw in result.stdout.splitlines():
            name = raw.strip()
            if name.startswith("origin/"):
                name = name[len("origin/") :]
            if name and name != "HEAD":
                names.append(name)
        return cls.from_names(names)

    def contains(self, branch: str) -> bool:
        return branch in self.names


@dataclass(frozen=True)
class ClaimSnapshot:
    records: tuple[Mapping[str, Any], ...]

    @classmethod
    def empty(cls) -> "ClaimSnapshot":
        return cls(())

    @classmethod
    def from_records(cls, records: Iterable[Mapping[str, Any]]) -> "ClaimSnapshot":
        copied = tuple(dict(record) for record in records)
        for index, record in enumerate(copied):
            if not isinstance(record.get("claim_id"), str) or not record["claim_id"].strip():
                raise BacklogValidationError(f"claim[{index}] missing claim_id")
            if not isinstance(record.get("task_id"), str) or not record["task_id"].strip():
                raise BacklogValidationError(f"claim[{index}] missing task_id")
            if not isinstance(record.get("status"), str) or not record["status"].strip():
                raise BacklogValidationError(f"claim[{index}] missing status")
            allowed = record.get("allowed_paths", [])
            if not isinstance(allowed, list) or not all(isinstance(item, str) and item.strip() for item in allowed):
                raise BacklogValidationError(f"claim[{index}] allowed_paths must be a string array")
        return cls(copied)

    @classmethod
    def from_json(cls, path: str | Path) -> "ClaimSnapshot":
        data = json.loads(Path(path).read_text(encoding="utf-8"))
        if isinstance(data, dict):
            records = data.get("claims", [])
        elif isinstance(data, list):
            records = data
        else:
            raise BacklogValidationError("claim snapshot must be a list or an object with claims")
        if not isinstance(records, list):
            raise BacklogValidationError("claims must be an array")
        return cls.from_records(records)

    @property
    def active(self) -> tuple[Mapping[str, Any], ...]:
        return tuple(
            record
            for record in self.records
            if str(record.get("status", "")).upper() in ACTIVE_CLAIM_STATUSES
        )

    def conflicts_with(self, task: Mapping[str, Any]) -> bool:
        task_id = task["task_id"]
        candidate_paths = task["allowed_paths"]
        for claim in self.active:
            if claim["task_id"] == task_id:
                return True
            for claimed_path in claim.get("allowed_paths", []):
                if any(_patterns_overlap(claimed_path, candidate) for candidate in candidate_paths):
                    return True
        return False


class Dispatcher:
    def __init__(
        self,
        backlog: Mapping[str, Any],
        branches: GitBranchSnapshot,
        claims: ClaimSnapshot,
    ) -> None:
        self.backlog = backlog
        self.branches = branches
        self.claims = claims

    def validate(self) -> None:
        tasks = self.backlog.get("tasks")
        if not isinstance(tasks, list) or not tasks:
            raise BacklogValidationError("tasks must be a non-empty array")

        ids: list[str] = []
        for index, task in enumerate(tasks):
            if not isinstance(task, dict):
                raise BacklogValidationError(f"task[{index}] must be an object")
            task_id = task.get("task_id")
            if not isinstance(task_id, str) or not task_id.strip():
                raise BacklogValidationError(f"task[{index}] missing task_id")
            if task_id in ids:
                raise BacklogValidationError(f"duplicate task_id: {task_id}")
            ids.append(task_id)
            if task.get("domain") not in VALID_DOMAINS:
                raise BacklogValidationError(f"{task_id}: invalid domain")
            if task.get("status") not in VALID_STATUSES:
                raise BacklogValidationError(f"{task_id}: invalid status")
            branch = task.get("branch")
            if not isinstance(branch, str) or not branch.strip():
                raise BacklogValidationError(f"{task_id}: branch must be non-empty")
            prerequisites = task.get("prerequisites")
            if not isinstance(prerequisites, list) or not all(isinstance(dep, str) for dep in prerequisites):
                raise BacklogValidationError(f"{task_id}: prerequisites must be a string array")
            external = task.get("external_prerequisites", [])
            if not isinstance(external, list) or not all(isinstance(dep, str) for dep in external):
                raise BacklogValidationError(f"{task_id}: external_prerequisites must be a string array")
            paths = task.get("allowed_paths")
            if not isinstance(paths, list) or not paths:
                raise BacklogValidationError(f"{task_id}: allowed_paths must be non-empty")
            for pattern in paths:
                if not isinstance(pattern, str) or not pattern.strip() or pattern.startswith("/") or ".." in Path(pattern).parts:
                    raise BacklogValidationError(f"{task_id}: unsafe allowed path {pattern!r}")

        known = set(ids)
        for task in tasks:
            for dependency in task["prerequisites"]:
                if dependency not in known:
                    raise BacklogValidationError(
                        f"{task['task_id']}: unknown prerequisite {dependency}"
                    )
                if dependency == task["task_id"]:
                    raise BacklogValidationError(f"{task['task_id']}: self dependency")

        # DFS cycle check over internal prerequisites.
        graph = {task["task_id"]: tuple(task["prerequisites"]) for task in tasks}
        visiting: set[str] = set()
        visited: set[str] = set()

        def visit(node: str) -> None:
            if node in visiting:
                raise BacklogValidationError(f"dependency cycle detected at {node}")
            if node in visited:
                return
            visiting.add(node)
            for dependency in graph[node]:
                visit(dependency)
            visiting.remove(node)
            visited.add(node)

        for node in graph:
            visit(node)

    def _task_map(self) -> dict[str, Mapping[str, Any]]:
        return {task["task_id"]: task for task in self.backlog["tasks"]}

    def dependencies_complete(self, task: Mapping[str, Any]) -> bool:
        tasks = self._task_map()
        complete = set(self.backlog.get("dependency_complete_statuses", DEFAULT_COMPLETE_STATUSES))
        return all(tasks[dep]["status"] in complete for dep in task["prerequisites"])

    def blocked_by_live_work(self, task: Mapping[str, Any]) -> bool:
        return self.branches.contains(task["branch"]) or self.claims.conflicts_with(task)

    def executable_tasks(self) -> list[Mapping[str, Any]]:
        self.validate()
        return [
            task
            for task in self.backlog["tasks"]
            if task["status"] == "PENDING"
            and self.dependencies_complete(task)
            and not self.blocked_by_live_work(task)
        ]

    def next_executable(self) -> Mapping[str, Any] | None:
        tasks = self.executable_tasks()
        return tasks[0] if tasks else None

    def generate_spec(self, task: Mapping[str, Any], *, claim_id: str) -> str:
        if task["status"] != "PENDING":
            raise BacklogValidationError("spec generation requires a PENDING task")
        if not self.dependencies_complete(task):
            raise BacklogValidationError("spec generation requires completed dependencies")
        if self.blocked_by_live_work(task):
            raise BacklogValidationError("spec generation blocked by active branch or claim")

        prerequisites = task["prerequisites"] or ["none"]
        external = task.get("external_prerequisites", []) or ["none"]
        allowed = "\n".join(f"- {path}" for path in task["allowed_paths"])
        deps = "\n".join(f"- {dep}" for dep in prerequisites)
        external_deps = "\n".join(f"- {dep}" for dep in external)
        return (
            f"Task: {task['task_id']}\n"
            f"Domain: {task['domain']}\n"
            f"Claim: {claim_id}\n"
            f"Target branch: {task['branch']}\n"
            f"Goal: {task['goal']}\n\n"
            f"Prerequisites:\n{deps}\n\n"
            f"External prerequisites:\n{external_deps}\n\n"
            f"Allowed paths:\n{allowed}\n\n"
            "Isolation rule: Do not modify files outside these boundaries.\n"
            "Execution rule: preserve strict TDD, verify locally, and do not merge or trigger paid CI automatically.\n"
            "Acceptance: implementation is complete only after task-specific tests pass and the exact branch HEAD is verified."
        )


def main(argv: Sequence[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Select the next isolated backlog task")
    parser.add_argument("--backlog", type=Path, default=DEFAULT_BACKLOG)
    parser.add_argument("--repo", type=Path, default=Path("."))
    parser.add_argument("--claims", type=Path)
    parser.add_argument("--claim-id", default="TOOLING-DISPATCHER-001")
    parser.add_argument("--json", action="store_true", dest="as_json")
    args = parser.parse_args(argv)

    backlog = load_backlog(args.backlog)
    branches = GitBranchSnapshot.from_local_git(args.repo)
    claims = ClaimSnapshot.from_json(args.claims) if args.claims else ClaimSnapshot.empty()
    dispatcher = Dispatcher(backlog, branches, claims)
    dispatcher.validate()
    task = dispatcher.next_executable()

    if task is None:
        if args.as_json:
            print(json.dumps({"state": "NO_EXECUTABLE_TASK"}, sort_keys=True))
        else:
            print("NO_EXECUTABLE_TASK")
        return 0

    spec = dispatcher.generate_spec(task, claim_id=args.claim_id)
    if args.as_json:
        print(json.dumps({"state": "READY", "task_id": task["task_id"], "spec": spec}, ensure_ascii=False))
    else:
        print(spec)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
