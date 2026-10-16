#!/usr/bin/env python3
"""Unified anti-skip policy guard for DEUTSCH / Polyglot.

Enforces zero-skip policy across agents (Jules, Gemini, Codex), automated
bots, commit generators, and preflight checks.

Prohibited directives on integration targets:
- [skip ci]
- [ci skip]
- [no ci]
- [skip actions]
- [actions skip]
- skip-checks: true
- skip-checks:true
"""
from __future__ import annotations

import argparse
import re
import subprocess
import sys
from typing import Sequence

PROHIBITED_SKIP_PATTERNS = [
    re.compile(r"\[(?:skip ci|ci skip|no ci|skip actions|actions skip)\]", re.IGNORECASE),
    re.compile(r"(?im)^skip-checks\s*:\s*true\s*$"),
    re.compile(r"skip-checks\s*:\s*true", re.IGNORECASE),
]


def find_skip_directives(text: str) -> list[str]:
    """Return all detected skip directives in text."""
    if not text:
        return []
    matches: list[str] = []
    for pattern in PROHIBITED_SKIP_PATTERNS:
        for m in pattern.finditer(text):
            val = m.group(0).strip()
            if val not in matches:
                matches.append(val)
    return matches


def contains_skip_directive(text: str) -> bool:
    """Return True if text contains any prohibited skip directive."""
    return len(find_skip_directives(text)) > 0


def assert_no_skip_directives(text: str, context: str = "commit message") -> None:
    """Raise ValueError if text contains any prohibited skip directive."""
    directives = find_skip_directives(text)
    if directives:
        joined = ", ".join(directives)
        raise ValueError(
            f"Prohibited skip directive(s) [{joined}] detected in {context}. "
            "Integration changes must never skip CI. Remove skip directives and verify."
        )


def sanitize_skip_directives(text: str) -> str:
    """Remove any skip directives from a message or title cleanly."""
    result = text
    for pattern in PROHIBITED_SKIP_PATTERNS:
        result = pattern.sub("", result)
    # Clean up double spaces or dangling brackets
    result = re.sub(r" +", " ", result).strip()
    return result


def get_git_head_message(repo_root: str = ".") -> str:
    """Return the commit message of HEAD in the repository."""
    try:
        return subprocess.check_output(
            ["git", "-C", repo_root, "log", "-1", "--format=%B"],
            text=True,
            stderr=subprocess.PIPE,
        ).strip()
    except subprocess.CalledProcessError as exc:
        raise RuntimeError(f"Failed to read git HEAD commit message: {exc}") from exc


def main(argv: Sequence[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Enforce anti-skip policy")
    parser.add_argument("--check-message", help="Check given commit message")
    parser.add_argument("--check-pr-title", help="Check given PR title")
    parser.add_argument("--check-head", action="store_true", help="Check current git HEAD commit message")
    parser.add_argument("--repo-root", default=".", help="Repository root directory")
    args = parser.parse_args(argv)

    failures: list[str] = []

    if args.check_message:
        directives = find_skip_directives(args.check_message)
        if directives:
            failures.append(f"Commit message contains skip directive(s): {directives}")

    if args.check_pr_title:
        directives = find_skip_directives(args.check_pr_title)
        if directives:
            failures.append(f"PR title contains skip directive(s): {directives}")

    if args.check_head:
        msg = get_git_head_message(args.repo_root)
        directives = find_skip_directives(msg)
        if directives:
            failures.append(f"HEAD commit message contains skip directive(s): {directives}")

    if failures:
        for f in failures:
            print(f"FAIL: {f}", file=sys.stderr)
        return 1

    print("PASS: No skip directives detected.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
