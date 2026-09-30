#!/usr/bin/env python3
"""Deterministic dependency graph and merge sequencer for staged pull requests.

The sequencer is deliberately local/read-only with respect to GitHub. It reads
``backlog.json`` plus local/remote Git branch refs, derives dependencies between
PRs #104-#111, emits a deterministic topological order, and writes a Markdown
pipeline report. A dependency cycle is a hard failure.
"""

from __future__ import annotations

import argparse
import heapq
import json
import re
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Iterable, Mapping, Sequence

HERE = Path(__file__).resolve().parent
DEFAULT_BACKLOG = HERE / "backlog.json"
DEFAULT_REPORT = Path("docs/automation/MERGE_PIPELINE.md")
TARGET_PRS = tuple(range(104, 112))

PR_BRANCHES: Mapping[int, str] = {
    104: "phase2/core-wiring",
    105: "feature/offline-audio-engine",
    106: "feature/local-persistence-domain",
    107: "tools/language-matrix-builder",
    108: "feature/srs-scheduling-engine",
    109: "tools/autonomous-dispatcher",
    110: "feature/deck-ingestion-domain",
    111: "feature/study-session-coordinator",
}

PR_LANES: Mapping[int, str] = {
    104: "dart-ui",
    105: "dart-core",
    106: "dart-core",
    107: "python-tools",
    108: "dart-core",
    109: "python-tools",
    110: "dart-core",
    111: "dart-core",
}

_PR_REF_RE = re.compile(r"^PR\s*#(\d+)$", re.IGNORECASE)


class SequencerError(ValueError):
    """Base fail-closed validation error for the merge sequencer."""


class DependencyCycleError(SequencerError):
    """Raised when the task or PR dependency graph contains a cycle."""


@dataclass(frozen=True)
class MergePlanItem:
    pr_number: int
    branch: str
    lane: str
    ready: bool
    blocked_by: tuple[int, ...]
    branch_present: bool


def load_backlog(path: str | Path = DEFAULT_BACKLOG) -> dict[str, Any]:
    data = json.loads(Path(path).read_text(encoding="utf-8"))
    if not isinstance(data, dict):
        raise SequencerError("backlog root must be an object")
    tasks = data.get("tasks")
    if not isinstance(tasks, list):
        raise SequencerError("backlog tasks must be an array")
    return data


def _external_prs(task: Mapping[str, Any]) -> frozenset[int]:
    external = task.get("external_prerequisites", [])
    if not isinstance(external, list):
        raise SequencerError(
            f"{task.get('task_id', '<unknown>')}: external_prerequisites must be an array"
        )
    refs: set[int] = set()
    for value in external:
        if not isinstance(value, str):
            raise SequencerError(
                f"{task.get('task_id', '<unknown>')}: external prerequisite must be a string"
            )
        match = _PR_REF_RE.match(value.strip())
        if match:
            refs.add(int(match.group(1)))
    return frozenset(refs)


def derive_pr_dependencies(
    backlog: Mapping[str, Any],
    *,
    target_prs: Iterable[int] = TARGET_PRS,
) -> dict[int, frozenset[int]]:
    """Derive PR dependencies from backlog task dependencies.

    PR references attached to a task are peers. A PR attached to a downstream
    task depends on PR references attached to all prerequisite ancestor tasks.
    This models the current integration backlog where TASK-INT-002 / PR #111 is
    gated by TASK-INT-001 / PRs #106, #108 and #110.
    """

    targets = tuple(sorted(set(int(number) for number in target_prs)))
    target_set = set(targets)
    dependencies: dict[int, set[int]] = {number: set() for number in targets}

    tasks_raw = backlog.get("tasks")
    if not isinstance(tasks_raw, list):
        raise SequencerError("backlog tasks must be an array")

    tasks: dict[str, Mapping[str, Any]] = {}
    for index, task in enumerate(tasks_raw):
        if not isinstance(task, Mapping):
            raise SequencerError(f"task[{index}] must be an object")
        task_id = task.get("task_id")
        if not isinstance(task_id, str) or not task_id.strip():
            raise SequencerError(f"task[{index}] missing task_id")
        if task_id in tasks:
            raise SequencerError(f"duplicate task_id: {task_id}")
        prerequisites = task.get("prerequisites", [])
        if not isinstance(prerequisites, list) or not all(
            isinstance(dep, str) and dep.strip() for dep in prerequisites
        ):
            raise SequencerError(f"{task_id}: prerequisites must be a string array")
        tasks[task_id] = task

    for task_id, task in tasks.items():
        for prerequisite in task.get("prerequisites", []):
            if prerequisite not in tasks:
                raise SequencerError(f"{task_id}: unknown prerequisite {prerequisite}")

    memo: dict[str, frozenset[int]] = {}
    visiting: set[str] = set()

    def ancestor_prs(task_id: str) -> frozenset[int]:
        if task_id in memo:
            return memo[task_id]
        if task_id in visiting:
            raise DependencyCycleError(f"dependency cycle detected at {task_id}")
        visiting.add(task_id)
        collected: set[int] = set()
        for prerequisite in tasks[task_id].get("prerequisites", []):
            collected.update(_external_prs(tasks[prerequisite]))
            collected.update(ancestor_prs(prerequisite))
        visiting.remove(task_id)
        memo[task_id] = frozenset(collected)
        return memo[task_id]

    # Visit every task so a cycle is rejected even when it has no target PR ref.
    for task_id in tasks:
        ancestor_prs(task_id)

    for task_id, task in tasks.items():
        own_prs = _external_prs(task) & target_set
        inherited = ancestor_prs(task_id) & target_set
        for pr_number in own_prs:
            dependencies[pr_number].update(inherited - {pr_number})

    return {number: frozenset(values) for number, values in dependencies.items()}


def compute_topological_order(
    dependencies: Mapping[int, Iterable[int]],
) -> list[int]:
    """Return a stable PR order, breaking independent ties by PR number."""

    nodes = set(int(node) for node in dependencies)
    normalized: dict[int, set[int]] = {}
    for node, raw_dependencies in dependencies.items():
        deps = {int(dep) for dep in raw_dependencies}
        unknown = deps - nodes
        if unknown:
            raise SequencerError(
                f"PR #{node} references untracked dependencies: "
                + ", ".join(f"#{dep}" for dep in sorted(unknown))
            )
        normalized[int(node)] = deps

    indegree = {node: len(normalized[node]) for node in nodes}
    dependents: dict[int, set[int]] = {node: set() for node in nodes}
    for node, deps in normalized.items():
        for dep in deps:
            dependents[dep].add(node)

    ready = [node for node, degree in indegree.items() if degree == 0]
    heapq.heapify(ready)
    order: list[int] = []

    while ready:
        node = heapq.heappop(ready)
        order.append(node)
        for dependent in sorted(dependents[node]):
            indegree[dependent] -= 1
            if indegree[dependent] == 0:
                heapq.heappush(ready, dependent)

    if len(order) != len(nodes):
        cyclic = sorted(node for node, degree in indegree.items() if degree > 0)
        raise DependencyCycleError(
            "dependency cycle detected among "
            + ", ".join(f"PR #{node}" for node in cyclic)
        )
    return order


def read_active_git_branches(repo_root: str | Path = ".") -> frozenset[str]:
    """Read local and origin branch refs, normalized to plain branch names."""

    try:
        result = subprocess.run(
            [
                "git",
                "for-each-ref",
                "--format=%(refname:short)",
                "refs/heads",
                "refs/remotes/origin",
            ],
            cwd=Path(repo_root),
            check=True,
            capture_output=True,
            text=True,
        )
    except (OSError, subprocess.CalledProcessError) as exc:
        raise SequencerError(f"cannot read active git branches: {exc}") from exc

    names: set[str] = set()
    for raw in result.stdout.splitlines():
        name = raw.strip()
        if name.startswith("origin/"):
            name = name[len("origin/") :]
        if name and name != "HEAD":
            names.add(name)
    return frozenset(names)


def build_merge_plan(
    backlog: Mapping[str, Any],
    *,
    active_branches: Iterable[str],
    merged_prs: Iterable[int] = (),
    dependencies: Mapping[int, Iterable[int]] | None = None,
) -> list[MergePlanItem]:
    dependency_map = (
        {number: frozenset(values) for number, values in dependencies.items()}
        if dependencies is not None
        else derive_pr_dependencies(backlog)
    )
    order = compute_topological_order(dependency_map)
    active = frozenset(str(branch).strip() for branch in active_branches if str(branch).strip())
    merged = frozenset(int(number) for number in merged_prs)

    plan: list[MergePlanItem] = []
    for pr_number in order:
        branch = PR_BRANCHES[pr_number]
        blocked_by = tuple(sorted(set(dependency_map[pr_number]) - merged))
        branch_present = branch in active
        plan.append(
            MergePlanItem(
                pr_number=pr_number,
                branch=branch,
                lane=PR_LANES[pr_number],
                ready=branch_present and not blocked_by,
                blocked_by=blocked_by,
                branch_present=branch_present,
            )
        )
    return plan


def _badge(item: MergePlanItem) -> str:
    if item.ready:
        return "![ready-to-merge](https://img.shields.io/badge/merge-ready_to_merge-brightgreen)"
    return "![blocked](https://img.shields.io/badge/merge-blocked-orange)"


def render_merge_pipeline(plan: Sequence[MergePlanItem]) -> str:
    lines = [
        "# MERGE_PIPELINE",
        "",
        "Generated by `tools/automation/merge_sequencer.py` from `backlog.json` and active Git branches.",
        "",
        "| Order | PR | Lane | Branch | Status | Blocked by |",
        "| ---: | ---: | --- | --- | --- | --- |",
    ]
    for index, item in enumerate(plan, start=1):
        if item.blocked_by:
            blocked = ", ".join(f"#{number}" for number in item.blocked_by)
        elif not item.branch_present:
            blocked = "branch not active"
        else:
            blocked = "—"
        lines.append(
            f"| {index} | #{item.pr_number} | {item.lane} | `{item.branch}` | {_badge(item)} | {blocked} |"
        )
    lines.extend(
        [
            "",
            "Ready means the expected branch exists and all tracked PR dependencies are already marked merged for this run.",
            "Blocked means one or more tracked dependencies remain or the expected branch is not present.",
            "",
        ]
    )
    return "\n".join(lines)


def write_merge_pipeline(path: str | Path, plan: Sequence[MergePlanItem]) -> Path:
    output = Path(path)
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(render_merge_pipeline(plan), encoding="utf-8")
    return output


def _build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Build dependency-aware merge sequence for PRs #104-#111")
    parser.add_argument("--backlog", type=Path, default=DEFAULT_BACKLOG)
    parser.add_argument("--repo", type=Path, default=Path("."))
    parser.add_argument("--output", type=Path)
    parser.add_argument(
        "--merged-pr",
        type=int,
        action="append",
        default=[],
        help="PR number already merged; repeat for multiple PRs",
    )
    return parser


def _main(argv: Sequence[str] | None = None) -> int:
    args = _build_parser().parse_args(argv)
    try:
        backlog = load_backlog(args.backlog)
        dependencies = derive_pr_dependencies(backlog)
        # Force PR-level cycle validation before touching Git so cycles always
        # fail deterministically with exit code 1.
        compute_topological_order(dependencies)
        branches = read_active_git_branches(args.repo)
        plan = build_merge_plan(
            backlog,
            active_branches=branches,
            merged_prs=args.merged_pr,
            dependencies=dependencies,
        )
        output = args.output or (args.repo / DEFAULT_REPORT)
        write_merge_pipeline(output, plan)
        print("Merge order: " + " -> ".join(f"#{item.pr_number}" for item in plan))
        print(f"Report: {output}")
        return 0
    except DependencyCycleError as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 1
    except (SequencerError, OSError, json.JSONDecodeError) as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(_main())
