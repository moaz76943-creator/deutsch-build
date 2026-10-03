#!/usr/bin/env python3
"""Deterministic merge-tree diagnostics and isolated auto-rebase previews."""

from __future__ import annotations

import argparse
import json
import re
import shutil
import subprocess
import tempfile
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Sequence

_SHA_RE = re.compile(r"^[0-9a-f]{40}$")
_CONFLICT_RE = re.compile(r"^CONFLICT .* in (.+)$", re.MULTILINE)
_STAGE_PATH_RE = re.compile(r"^[0-9]{6} [0-9a-f]{40} [123]\t(.+)$", re.MULTILINE)


@dataclass(frozen=True)
class GitResult:
    returncode: int
    stdout: str
    stderr: str


@dataclass(frozen=True)
class DryRunResult:
    clean: bool
    base_head: str
    source_head: str
    tree_sha: str | None
    collided_paths: list[str]
    diagnostics: str


@dataclass(frozen=True)
class RebaseResult:
    success: bool
    applied: bool
    base_head: str
    source_head: str
    rebased_head: str | None
    collided_paths: list[str]
    diagnostics: str


def _git(repo: Path, args: Sequence[str]) -> GitResult:
    proc = subprocess.run(
        ["git", "-C", str(repo), *args],
        check=False,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    return GitResult(proc.returncode, proc.stdout.strip(), proc.stderr.strip())


def _require_git_repo(repo: Path) -> Path:
    root = repo.resolve()
    result = _git(root, ["rev-parse", "--show-toplevel"])
    if result.returncode != 0:
        raise ValueError(f"not a git repository: {root}")
    return Path(result.stdout).resolve()


def _resolve(repo: Path, ref: str) -> str:
    result = _git(repo, ["rev-parse", "--verify", f"{ref}^{{commit}}"])
    if result.returncode != 0 or not _SHA_RE.fullmatch(result.stdout):
        detail = result.stderr or result.stdout or "unknown ref"
        raise ValueError(f"cannot resolve ref {ref!r}: {detail}")
    return result.stdout


def _conflicted_paths(text: str) -> list[str]:
    paths = set(_CONFLICT_RE.findall(text))
    paths.update(_STAGE_PATH_RE.findall(text))
    return sorted(path.strip() for path in paths if path.strip())


def tree_dry_run(repo: Path, base_ref: str, source_ref: str) -> DryRunResult:
    """Ask Git to synthesize the merge tree without touching the worktree."""
    root = _require_git_repo(repo)
    base_head = _resolve(root, base_ref)
    source_head = _resolve(root, source_ref)
    result = _git(root, ["merge-tree", "--write-tree", base_head, source_head])
    diagnostics = "\n".join(part for part in (result.stdout, result.stderr) if part)
    first_line = result.stdout.splitlines()[0].strip() if result.stdout else ""
    tree_sha = first_line if _SHA_RE.fullmatch(first_line) else None
    return DryRunResult(
        clean=result.returncode == 0,
        base_head=base_head,
        source_head=source_head,
        tree_sha=tree_sha,
        collided_paths=_conflicted_paths(diagnostics),
        diagnostics=diagnostics,
    )


def _is_local_branch(repo: Path, ref: str) -> bool:
    if ref.startswith("-") or ref.startswith("refs/"):
        return False
    result = _git(repo, ["show-ref", "--verify", "--quiet", f"refs/heads/{ref}"])
    return result.returncode == 0


def attempt_auto_rebase(
    repo: Path,
    base_ref: str,
    source_ref: str,
    *,
    apply: bool = False,
) -> RebaseResult:
    """Rebase in a disposable detached worktree; update a local ref only if requested."""
    root = _require_git_repo(repo)
    base_head = _resolve(root, base_ref)
    source_head = _resolve(root, source_ref)
    if apply and not _is_local_branch(root, source_ref):
        raise ValueError("--apply-rebase requires source_ref to name a local branch")

    worktree = Path(tempfile.mkdtemp(prefix="merge-arbiter-"))
    added = False
    try:
        add_result = _git(root, ["worktree", "add", "--detach", str(worktree), source_head])
        if add_result.returncode != 0:
            diagnostics = "\n".join(
                part for part in (add_result.stdout, add_result.stderr) if part
            )
            return RebaseResult(
                success=False,
                applied=False,
                base_head=base_head,
                source_head=source_head,
                rebased_head=None,
                collided_paths=[],
                diagnostics=diagnostics,
            )
        added = True

        rebase = _git(worktree, ["rebase", base_head])
        diagnostics = "\n".join(part for part in (rebase.stdout, rebase.stderr) if part)
        if rebase.returncode != 0:
            unmerged = _git(worktree, ["diff", "--name-only", "--diff-filter=U"])
            collided = sorted(
                path.strip() for path in unmerged.stdout.splitlines() if path.strip()
            )
            _git(worktree, ["rebase", "--abort"])
            return RebaseResult(
                success=False,
                applied=False,
                base_head=base_head,
                source_head=source_head,
                rebased_head=None,
                collided_paths=collided,
                diagnostics=diagnostics,
            )

        rebased_head = _resolve(worktree, "HEAD")
        applied = False
        if apply:
            update = _git(
                root,
                ["update-ref", f"refs/heads/{source_ref}", rebased_head, source_head],
            )
            if update.returncode != 0:
                detail = "\n".join(part for part in (update.stdout, update.stderr) if part)
                return RebaseResult(
                    success=False,
                    applied=False,
                    base_head=base_head,
                    source_head=source_head,
                    rebased_head=rebased_head,
                    collided_paths=[],
                    diagnostics=f"{diagnostics}\n{detail}".strip(),
                )
            applied = True

        return RebaseResult(
            success=True,
            applied=applied,
            base_head=base_head,
            source_head=source_head,
            rebased_head=rebased_head,
            collided_paths=[],
            diagnostics=diagnostics,
        )
    finally:
        if added:
            _git(root, ["worktree", "remove", "--force", str(worktree)])
        shutil.rmtree(worktree, ignore_errors=True)


def build_report(
    repo: Path,
    base_ref: str,
    source_ref: str,
    *,
    auto_rebase: bool,
    apply_rebase: bool,
) -> tuple[dict[str, object], int]:
    dry = tree_dry_run(repo, base_ref, source_ref)
    rebase: RebaseResult | None = None
    if auto_rebase:
        rebase = attempt_auto_rebase(repo, base_ref, source_ref, apply=apply_rebase)

    accepted = dry.clean and (rebase is None or rebase.success)
    if not dry.clean and rebase is not None and rebase.success:
        accepted = True

    reasons: list[str] = []
    if dry.clean:
        reasons.append("tree-dry-run-clean")
    else:
        reasons.append("tree-dry-run-conflict")
    if rebase is not None:
        reasons.append("auto-rebase-clean" if rebase.success else "auto-rebase-conflict")
        if rebase.applied:
            reasons.append("source-ref-updated")
        elif rebase.success:
            reasons.append("preview-only-no-ref-update")

    collided = set(dry.collided_paths)
    if rebase is not None:
        collided.update(rebase.collided_paths)

    report: dict[str, object] = {
        "schema": 1,
        "base_ref": base_ref,
        "source_ref": source_ref,
        "base_head": dry.base_head,
        "source_head": dry.source_head,
        "accepted": accepted,
        "tree_dry_run": asdict(dry),
        "auto_rebase": asdict(rebase) if rebase is not None else None,
        "collided_paths": sorted(collided),
        "reasons": reasons,
    }
    return report, 0 if accepted else 2


def _parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repo-root", type=Path, default=Path("."))
    parser.add_argument("--base", required=True, help="target ref or commit")
    parser.add_argument("--source", required=True, help="source ref or commit")
    parser.add_argument(
        "--auto-rebase",
        action="store_true",
        help="simulate a rebase in a disposable worktree",
    )
    parser.add_argument(
        "--apply-rebase",
        action="store_true",
        help="move a local source branch after a clean isolated rebase",
    )
    parser.add_argument("--json-report", type=Path)
    return parser


def main(argv: Sequence[str] | None = None) -> int:
    parser = _parser()
    args = parser.parse_args(argv)
    if args.apply_rebase and not args.auto_rebase:
        parser.error("--apply-rebase requires --auto-rebase")

    try:
        report, status = build_report(
            args.repo_root,
            args.base,
            args.source,
            auto_rebase=args.auto_rebase,
            apply_rebase=args.apply_rebase,
        )
    except (OSError, ValueError) as exc:
        report = {"schema": 1, "accepted": False, "error": str(exc)}
        status = 2

    rendered = json.dumps(report, indent=2, sort_keys=True)
    if args.json_report:
        args.json_report.parent.mkdir(parents=True, exist_ok=True)
        args.json_report.write_text(rendered + "\n", encoding="utf-8")
    print(rendered)
    return status


if __name__ == "__main__":
    raise SystemExit(main())
