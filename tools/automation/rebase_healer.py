#!/usr/bin/env python3
"""Read-only integration pre-flight simulator for candidate branches.

The simulator compares a candidate branch with an exact target commit, performs
Git's three-way tree merge in a temporary object database, and never updates the
index or working tree. It reports path collisions, hard merge conflicts, task
boundary violations, and JSON-schema contract regressions.
"""

from __future__ import annotations

import argparse
import fnmatch
import json
import os
import re
import subprocess
import sys
import tempfile
from pathlib import Path
from typing import Any, Iterable, Mapping, Sequence

STATUS_CLEAN = "CLEAN"
STATUS_AUTO_RESOLVABLE = "AUTO_RESOLVABLE"
STATUS_HARD_CONFLICT = "HARD_CONFLICT"
REPORT_SCHEMA_VERSION = "1.0.0"


class PreflightError(RuntimeError):
    """Raised when the pre-flight simulation cannot be completed safely."""


def _git(
    repo: Path,
    *args: str,
    check: bool = True,
    env: Mapping[str, str] | None = None,
) -> subprocess.CompletedProcess[str]:
    try:
        result = subprocess.run(
            ["git", *args],
            cwd=repo,
            check=False,
            capture_output=True,
            text=True,
            env=dict(env) if env is not None else None,
        )
    except OSError as exc:
        raise PreflightError(f"unable to execute git: {exc}") from exc
    if check and result.returncode != 0:
        detail = result.stderr.strip() or result.stdout.strip() or "git command failed"
        raise PreflightError(f"git {' '.join(args)}: {detail}")
    return result


def _resolve_ref(repo: Path, declared_ref: str) -> str:
    """Resolve a branch/ref or an exact ``label@sha`` declaration to a commit."""

    value = declared_ref.strip()
    if not value:
        raise PreflightError("ref must not be empty")

    if "@" in value:
        _label, separator, exact = value.rpartition("@")
        if separator and exact:
            resolved = _git(repo, "rev-parse", "--verify", f"{exact}^{{commit}}", check=False)
            if resolved.returncode != 0:
                raise PreflightError(
                    f"declared exact ref {declared_ref!r} cannot resolve commit {exact!r}"
                )
            return resolved.stdout.strip()

    resolved = _git(repo, "rev-parse", "--verify", f"{value}^{{commit}}", check=False)
    if resolved.returncode != 0:
        raise PreflightError(f"cannot resolve ref {declared_ref!r}")
    return resolved.stdout.strip()


def _changed_files(repo: Path, base: str, head: str) -> list[str]:
    result = _git(repo, "diff", "--name-only", "-z", f"{base}..{head}")
    return sorted(path for path in result.stdout.split("\0") if path)


def _matches_boundary(path: str, boundaries: Iterable[str]) -> bool:
    normalized = path.replace(os.sep, "/")
    return any(fnmatch.fnmatchcase(normalized, pattern.strip()) for pattern in boundaries)


def _schema_path(path: str) -> bool:
    normalized = path.lower().replace("\\", "/")
    return normalized.endswith(".json") and "schema" in normalized


def _show_text(
    repo: Path,
    treeish: str,
    path: str,
    *,
    env: Mapping[str, str] | None = None,
) -> str | None:
    result = _git(repo, "show", f"{treeish}:{path}", check=False, env=env)
    if result.returncode != 0:
        return None
    return result.stdout


def _format_items(values: Iterable[str]) -> str:
    return ", ".join(sorted(set(values)))


def _compare_schema_nodes(
    path: str,
    previous: Any,
    merged: Any,
    *,
    location: str = "$",
) -> list[str]:
    regressions: list[str] = []
    if not isinstance(previous, dict) or not isinstance(merged, dict):
        return regressions

    previous_properties = previous.get("properties")
    merged_properties = merged.get("properties")
    if isinstance(previous_properties, dict):
        current_properties = merged_properties if isinstance(merged_properties, dict) else {}
        removed = set(previous_properties) - set(current_properties)
        if removed:
            suffix = "" if location == "$" else f" at {location}"
            regressions.append(
                f"{path}: removed properties [{_format_items(removed)}]{suffix}"
            )
        for key in sorted(set(previous_properties) & set(current_properties)):
            regressions.extend(
                _compare_schema_nodes(
                    path,
                    previous_properties[key],
                    current_properties[key],
                    location=f"{location}.properties.{key}",
                )
            )

    previous_required = previous.get("required")
    merged_required = merged.get("required")
    if isinstance(previous_required, list):
        current_required = set(merged_required) if isinstance(merged_required, list) else set()
        removed_required = {
            item for item in previous_required if isinstance(item, str)
        } - current_required
        if removed_required:
            suffix = "" if location == "$" else f" at {location}"
            regressions.append(
                f"{path}: removed required fields [{_format_items(removed_required)}]{suffix}"
            )

    previous_type = previous.get("type")
    merged_type = merged.get("type")
    if previous_type is not None and merged_type is not None and previous_type != merged_type:
        suffix = "" if location == "$" else f" at {location}"
        regressions.append(
            f"{path}: changed type from {previous_type!r} to {merged_type!r}{suffix}"
        )

    return regressions


def _schema_regressions(
    repo: Path,
    target_commit: str,
    merged_tree: str | None,
    candidate_changed_files: Iterable[str],
    *,
    env: Mapping[str, str],
) -> list[str]:
    if merged_tree is None:
        return []

    regressions: list[str] = []
    for path in sorted(path for path in candidate_changed_files if _schema_path(path)):
        merged_text = _show_text(repo, merged_tree, path, env=env)
        if merged_text is None:
            if _show_text(repo, target_commit, path) is not None:
                regressions.append(f"{path}: schema file removed")
            continue
        try:
            merged_schema = json.loads(merged_text)
        except json.JSONDecodeError as exc:
            regressions.append(
                f"{path}: invalid merged JSON schema at line {exc.lineno} column {exc.colno}"
            )
            continue

        target_text = _show_text(repo, target_commit, path)
        if target_text is None:
            continue
        try:
            target_schema = json.loads(target_text)
        except json.JSONDecodeError:
            # Existing target corruption is not attributed to this candidate.
            continue
        regressions.extend(_compare_schema_nodes(path, target_schema, merged_schema))

    return sorted(set(regressions))


def _temporary_object_env(repo: Path, object_dir: Path) -> dict[str, str]:
    git_objects = _git(repo, "rev-parse", "--git-path", "objects").stdout.strip()
    source_objects = Path(git_objects)
    if not source_objects.is_absolute():
        source_objects = (repo / source_objects).resolve()
    env = os.environ.copy()
    env["GIT_OBJECT_DIRECTORY"] = str(object_dir)
    env["GIT_ALTERNATE_OBJECT_DIRECTORIES"] = str(source_objects)
    return env


def _merge_tree_simulation(
    repo: Path,
    target_commit: str,
    candidate_commit: str,
    candidate_changed_files: Iterable[str],
) -> tuple[str | None, list[str], list[str]]:
    """Run Git's recursive tree merge without touching the index/worktree.

    Generated merge objects are redirected to a temporary object database and
    removed when the simulation ends, leaving the repository object database
    unchanged as well.
    """

    with tempfile.TemporaryDirectory(prefix="integration-preflight-objects-") as temp:
        object_dir = Path(temp)
        env = _temporary_object_env(repo, object_dir)
        result = _git(
            repo,
            "merge-tree",
            "--write-tree",
            "--name-only",
            "--messages",
            target_commit,
            candidate_commit,
            check=False,
            env=env,
        )

        stdout = result.stdout
        first_section = stdout.split("\n\n", 1)[0]
        lines = [line.strip() for line in first_section.splitlines() if line.strip()]
        merged_tree = lines[0] if lines and re.fullmatch(r"[0-9a-fA-F]{40,64}", lines[0]) else None
        hard_conflicts = sorted(set(lines[1:])) if result.returncode != 0 else []

        regressions = _schema_regressions(
            repo,
            target_commit,
            merged_tree,
            candidate_changed_files,
            env=env,
        )
        return merged_tree, hard_conflicts, regressions


def simulate_integration(
    *,
    repo: str | Path,
    candidate_ref: str,
    target_ref: str,
    boundaries: Sequence[str],
) -> dict[str, Any]:
    """Return a deterministic structured integration pre-flight report."""

    repository = Path(repo).resolve()
    if not repository.exists():
        raise PreflightError(f"repository does not exist: {repository}")
    normalized_boundaries = tuple(pattern.strip() for pattern in boundaries if pattern.strip())
    if not normalized_boundaries:
        raise PreflightError("at least one declared task boundary is required")

    candidate_commit = _resolve_ref(repository, candidate_ref)
    target_commit = _resolve_ref(repository, target_ref)
    merge_base = _git(repository, "merge-base", target_commit, candidate_commit).stdout.strip()
    if not merge_base:
        raise PreflightError("candidate and target have no merge base")

    candidate_changed = _changed_files(repository, merge_base, candidate_commit)
    target_changed = _changed_files(repository, merge_base, target_commit)
    collisions = sorted(set(candidate_changed) & set(target_changed))
    outside = sorted(
        path for path in candidate_changed if not _matches_boundary(path, normalized_boundaries)
    )

    _merged_tree, hard_conflicts, schema_regressions = _merge_tree_simulation(
        repository,
        target_commit,
        candidate_commit,
        candidate_changed,
    )

    hard_failure = bool(hard_conflicts or outside or schema_regressions)
    if hard_failure:
        status = STATUS_HARD_CONFLICT
        exit_code = 1
    elif collisions:
        status = STATUS_AUTO_RESOLVABLE
        exit_code = 0
    else:
        status = STATUS_CLEAN
        exit_code = 0

    return {
        "schema_version": REPORT_SCHEMA_VERSION,
        "status": status,
        "exit_code": exit_code,
        "candidate": {
            "declared_ref": candidate_ref,
            "commit": candidate_commit,
        },
        "target": {
            "declared_ref": target_ref,
            "commit": target_commit,
        },
        "merge_base": merge_base,
        "boundaries": list(normalized_boundaries),
        "candidate_changed_files": candidate_changed,
        "target_changed_files": target_changed,
        "collisions": collisions,
        "hard_conflicts": hard_conflicts,
        "outside_boundaries": outside,
        "schema_regressions": schema_regressions,
        "merge_simulation": {
            "engine": "git merge-tree --write-tree",
            "temporary_object_database": True,
            "working_tree_mutated": False,
            "index_mutated": False,
        },
    }


def _safe_branch_name(candidate_ref: str) -> str:
    name = re.sub(r"[^A-Za-z0-9._-]+", "_", candidate_ref.strip()).strip("._")
    return name or "candidate"


def write_report(
    report: Mapping[str, Any],
    *,
    report_dir: str | Path,
    candidate_ref: str,
) -> Path:
    directory = Path(report_dir)
    directory.mkdir(parents=True, exist_ok=True)
    path = directory / f"integration_preflight_{_safe_branch_name(candidate_ref)}.json"
    path.write_text(json.dumps(report, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    return path


def _build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Simulate candidate integration without mutating the working tree"
    )
    parser.add_argument("--repo", type=Path, default=Path("."))
    parser.add_argument("--candidate", required=True, help="candidate branch/ref")
    parser.add_argument(
        "--target",
        required=True,
        help="target ref or exact declaration such as main@e3208766",
    )
    parser.add_argument(
        "--boundary",
        action="append",
        required=True,
        help="allowed candidate path glob; repeat for multiple task boundaries",
    )
    parser.add_argument("--report-dir", type=Path, default=Path("reports"))
    return parser


def _main(argv: Sequence[str] | None = None) -> int:
    args = _build_parser().parse_args(argv)
    try:
        report = simulate_integration(
            repo=args.repo,
            candidate_ref=args.candidate,
            target_ref=args.target,
            boundaries=tuple(args.boundary),
        )
        report_path = write_report(
            report,
            report_dir=args.report_dir,
            candidate_ref=args.candidate,
        )
        print(f"Integration preflight: {report['status']}")
        print(f"Report: {report_path}")
        return int(report["exit_code"])
    except PreflightError as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(_main())
