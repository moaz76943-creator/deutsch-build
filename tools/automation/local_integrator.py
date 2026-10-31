#!/usr/bin/env python3
"""Safe local integration runner driven by the verified merge sequence.

The runner consumes the dependency order from ``merge_sequencer`` and delegates
merge safety analysis to ``rebase_healer`` before mutating a local target branch.
A candidate is integrated only when its tracked prerequisites are already
ancestors of the current HEAD. Post-merge gatekeeper failure restores the
original HEAD with ``git reset --merge``.
"""

from __future__ import annotations

import argparse
import json
import os
import shlex
import subprocess
import sys
from pathlib import Path
from typing import Any, Iterable, Mapping, Sequence

from tools.automation.merge_sequencer import (
    DEFAULT_BACKLOG,
    PR_BRANCHES,
    compute_topological_order,
    derive_pr_dependencies,
    load_backlog,
)
from tools.automation.rebase_healer import (
    STATUS_AUTO_RESOLVABLE,
    STATUS_CLEAN,
    simulate_integration,
)


class IntegrationError(RuntimeError):
    """Raised when the local repository cannot be integrated safely."""


def _git(
    repo: Path,
    *args: str,
    check: bool = True,
) -> subprocess.CompletedProcess[str]:
    try:
        result = subprocess.run(
            ["git", *args],
            cwd=repo,
            check=False,
            capture_output=True,
            text=True,
        )
    except OSError as exc:
        raise IntegrationError(f"unable to execute git: {exc}") from exc
    if check and result.returncode != 0:
        detail = result.stderr.strip() or result.stdout.strip() or "git command failed"
        raise IntegrationError(f"git {' '.join(args)}: {detail}")
    return result


def _resolve_commit(repo: Path, ref: str) -> str | None:
    for candidate in (ref, f"origin/{ref}"):
        result = _git(repo, "rev-parse", "--verify", f"{candidate}^{{commit}}", check=False)
        if result.returncode == 0:
            return result.stdout.strip()
    return None


def _is_ancestor(repo: Path, ancestor: str, descendant: str = "HEAD") -> bool:
    result = _git(repo, "merge-base", "--is-ancestor", ancestor, descendant, check=False)
    return result.returncode == 0


def _merge_in_progress(repo: Path) -> bool:
    result = _git(repo, "rev-parse", "-q", "--verify", "MERGE_HEAD", check=False)
    return result.returncode == 0


def verify_tree(repo: str | Path = ".") -> dict[str, Any]:
    repository = Path(repo).resolve()
    if not repository.exists():
        raise IntegrationError(f"repository does not exist: {repository}")
    inside = _git(repository, "rev-parse", "--is-inside-work-tree", check=False)
    if inside.returncode != 0 or inside.stdout.strip() != "true":
        raise IntegrationError(f"not a git work tree: {repository}")

    status = _git(repository, "status", "--porcelain").stdout
    head = _git(repository, "rev-parse", "HEAD").stdout.strip()
    tree = _git(repository, "rev-parse", "HEAD^{tree}").stdout.strip()
    merging = _merge_in_progress(repository)
    return {
        "clean": not bool(status.strip()) and not merging,
        "head": head,
        "tree": tree,
        "merge_in_progress": merging,
        "status_porcelain": status.rstrip("\n"),
    }


def _require_clean_tree(repo: Path) -> dict[str, Any]:
    state = verify_tree(repo)
    if not state["clean"]:
        raise IntegrationError("working tree must be clean and free of an in-progress merge")
    return state


def _candidate_boundaries(
    repo: Path,
    backlog: Mapping[str, Any],
    branch: str,
    target_head: str,
    candidate_head: str,
) -> tuple[str, ...]:
    tasks = backlog.get("tasks", [])
    if isinstance(tasks, list):
        for task in tasks:
            if not isinstance(task, Mapping) or task.get("branch") != branch:
                continue
            allowed = task.get("allowed_paths", [])
            if isinstance(allowed, list):
                normalized = tuple(
                    value.strip()
                    for value in allowed
                    if isinstance(value, str) and value.strip()
                )
                if normalized:
                    return normalized

    merge_base = _git(repo, "merge-base", target_head, candidate_head).stdout.strip()
    changed = _git(
        repo,
        "diff",
        "--name-only",
        "-z",
        f"{merge_base}..{candidate_head}",
    ).stdout
    exact_paths = tuple(sorted(path for path in changed.split("\0") if path))
    return exact_paths or ("**",)


def _next_candidate(
    repo: Path,
    dependencies: Mapping[int, Iterable[int]],
    pr_branches: Mapping[int, str],
) -> dict[str, Any] | None:
    normalized_dependencies = {
        int(number): frozenset(int(dep) for dep in deps)
        for number, deps in dependencies.items()
    }
    order = compute_topological_order(normalized_dependencies)

    for pr_number in order:
        branch = pr_branches.get(pr_number)
        if not branch:
            continue
        candidate_head = _resolve_commit(repo, branch)
        if candidate_head is None:
            continue
        if _is_ancestor(repo, candidate_head):
            continue

        blockers: list[int] = []
        for dependency in sorted(normalized_dependencies.get(pr_number, ())):
            dependency_branch = pr_branches.get(dependency)
            dependency_head = (
                _resolve_commit(repo, dependency_branch) if dependency_branch else None
            )
            if dependency_head is None or not _is_ancestor(repo, dependency_head):
                blockers.append(dependency)
        if blockers:
            continue
        return {
            "pr_number": pr_number,
            "branch": branch,
            "candidate_head": candidate_head,
            "sequence": order,
        }
    return None


def _default_gatekeeper_command() -> tuple[str, ...]:
    configured = os.environ.get("DEUTSCH_LOCAL_GATEKEEPER", "").strip()
    if configured:
        parsed = tuple(shlex.split(configured))
        if not parsed:
            raise IntegrationError("DEUTSCH_LOCAL_GATEKEEPER resolved to an empty command")
        return parsed
    return (sys.executable, "-m", "pytest", "-q")


def _run_gatekeeper(repo: Path, command: Sequence[str]) -> subprocess.CompletedProcess[str]:
    if not command:
        raise IntegrationError("gatekeeper command must not be empty")
    try:
        return subprocess.run(
            list(command),
            cwd=repo,
            check=False,
            capture_output=True,
            text=True,
        )
    except OSError as exc:
        raise IntegrationError(f"unable to execute gatekeeper: {exc}") from exc


def _restore_original_head(repo: Path, original_head: str) -> None:
    if _merge_in_progress(repo):
        _git(repo, "merge", "--abort", check=False)
    current = _git(repo, "rev-parse", "HEAD", check=False)
    if current.returncode != 0 or current.stdout.strip() != original_head:
        _git(repo, "reset", "--merge", original_head)


def apply_next(
    *,
    repo: str | Path = ".",
    backlog_path: str | Path = DEFAULT_BACKLOG,
    backlog: Mapping[str, Any] | None = None,
    dependencies: Mapping[int, Iterable[int]] | None = None,
    pr_branches: Mapping[int, str] | None = None,
    gatekeeper_command: Sequence[str] | None = None,
    dry_run: bool = False,
) -> dict[str, Any]:
    """Integrate the next dependency-ready candidate into the current branch.

    The repository must start clean. The selected candidate is preflighted by
    ``rebase_healer`` against the exact current HEAD. Only CLEAN and
    AUTO_RESOLVABLE preflight results may proceed. Gatekeeper failure restores
    the exact original HEAD before returning a failure result.
    """

    repository = Path(repo).resolve()
    original_state = _require_clean_tree(repository)
    original_head = str(original_state["head"])

    backlog_data = dict(backlog) if backlog is not None else load_backlog(backlog_path)
    dependency_map = (
        {int(number): frozenset(int(dep) for dep in deps) for number, deps in dependencies.items()}
        if dependencies is not None
        else derive_pr_dependencies(backlog_data)
    )
    branch_map = dict(pr_branches) if pr_branches is not None else dict(PR_BRANCHES)

    candidate = _next_candidate(repository, dependency_map, branch_map)
    if candidate is None:
        return {
            "status": "NO_READY_CANDIDATE",
            "exit_code": 0,
            "head": original_head,
        }

    candidate_head = str(candidate["candidate_head"])
    boundaries = _candidate_boundaries(
        repository,
        backlog_data,
        str(candidate["branch"]),
        original_head,
        candidate_head,
    )
    preflight = simulate_integration(
        repo=repository,
        candidate_ref=candidate_head,
        target_ref=original_head,
        boundaries=boundaries,
    )
    accepted = preflight.get("status") in {STATUS_CLEAN, STATUS_AUTO_RESOLVABLE}
    if not accepted or int(preflight.get("exit_code", 1)) != 0:
        return {
            "status": "PREFLIGHT_REJECTED",
            "exit_code": 1,
            "pr_number": candidate["pr_number"],
            "branch": candidate["branch"],
            "preflight": preflight,
            "head": original_head,
        }

    fast_forward = _is_ancestor(repository, original_head, candidate_head)
    merge_mode = "fast-forward" if fast_forward else "merge"
    if dry_run:
        return {
            "status": "DRY_RUN",
            "exit_code": 0,
            "pr_number": candidate["pr_number"],
            "branch": candidate["branch"],
            "candidate_head": candidate_head,
            "target_head": original_head,
            "merge_mode": merge_mode,
            "preflight": preflight,
            "boundaries": list(boundaries),
        }

    merge_args = (
        ("merge", "--ff-only", candidate_head)
        if fast_forward
        else ("merge", "--no-ff", "--no-edit", candidate_head)
    )
    merge = _git(repository, *merge_args, check=False)
    if merge.returncode != 0:
        _restore_original_head(repository, original_head)
        return {
            "status": "MERGE_FAILED",
            "exit_code": 1,
            "pr_number": candidate["pr_number"],
            "branch": candidate["branch"],
            "merge_mode": merge_mode,
            "merge_stderr": merge.stderr.strip(),
            "rolled_back": True,
        }

    command = tuple(gatekeeper_command) if gatekeeper_command is not None else _default_gatekeeper_command()
    gate = _run_gatekeeper(repository, command)
    if gate.returncode != 0:
        _restore_original_head(repository, original_head)
        restored = verify_tree(repository)
        return {
            "status": "ROLLED_BACK_GATE_FAILURE",
            "exit_code": 1,
            "pr_number": candidate["pr_number"],
            "branch": candidate["branch"],
            "merge_mode": merge_mode,
            "gatekeeper_exit_code": gate.returncode,
            "gatekeeper_stdout": gate.stdout.strip(),
            "gatekeeper_stderr": gate.stderr.strip(),
            "rolled_back": restored["head"] == original_head,
            "head": restored["head"],
        }

    post_state = verify_tree(repository)
    if not post_state["clean"]:
        _restore_original_head(repository, original_head)
        restored = verify_tree(repository)
        return {
            "status": "ROLLED_BACK_TREE_VERIFICATION_FAILURE",
            "exit_code": 1,
            "pr_number": candidate["pr_number"],
            "branch": candidate["branch"],
            "merge_mode": merge_mode,
            "rolled_back": restored["head"] == original_head,
            "tree_clean_after_restore": restored["clean"],
        }

    return {
        "status": "INTEGRATED",
        "exit_code": 0,
        "pr_number": candidate["pr_number"],
        "branch": candidate["branch"],
        "merge_mode": merge_mode,
        "previous_head": original_head,
        "head": post_state["head"],
        "tree": post_state["tree"],
        "preflight": preflight,
        "gatekeeper_exit_code": gate.returncode,
        "rolled_back": False,
    }


def _build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Safely integrate the next verified local branch")
    parser.add_argument("--repo", type=Path, default=Path("."))
    parser.add_argument("--backlog", type=Path, default=DEFAULT_BACKLOG)
    action = parser.add_mutually_exclusive_group(required=True)
    action.add_argument("--apply-next", action="store_true", help="integrate the next ready candidate")
    action.add_argument("--verify-tree", action="store_true", help="verify current local tree safety")
    parser.add_argument("--dry-run", action="store_true", help="preflight the next candidate without merging")
    return parser


def _main(argv: Sequence[str] | None = None) -> int:
    parser = _build_parser()
    args = parser.parse_args(argv)
    if args.verify_tree and args.dry_run:
        parser.error("--dry-run is valid only with --apply-next")

    try:
        if args.verify_tree:
            result = verify_tree(args.repo)
            result["status"] = "TREE_OK" if result["clean"] else "TREE_DIRTY"
            result["exit_code"] = 0 if result["clean"] else 1
        else:
            result = apply_next(
                repo=args.repo,
                backlog_path=args.backlog,
                dry_run=args.dry_run,
            )
        print(json.dumps(result, indent=2, sort_keys=True))
        return int(result.get("exit_code", 1))
    except (IntegrationError, OSError, json.JSONDecodeError, ValueError) as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(_main())
