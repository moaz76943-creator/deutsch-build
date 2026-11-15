#!/usr/bin/env python3
"""Bounded, allowlisted process execution for repository automation tools.

Automation must never interpret repository, issue, manifest, or generated
content as shell source. Every command here is an argument vector executed
without a shell, and destructive Git operations are refused outright so a
generator bug cannot rewrite protected history.
"""
from __future__ import annotations

import subprocess
from typing import Sequence

DEFAULT_TIMEOUT_SECONDS = 300
DEFAULT_ALLOWED_EXECUTABLES = frozenset({"git", "flutter", "dart", "python3"})
PROTECTED_BRANCHES = frozenset({"main", "master", "refs/heads/main", "refs/heads/master"})
FORBIDDEN_PUSH_FLAGS = frozenset(
    {"--force", "-f", "--force-with-lease", "--force-if-includes", "--mirror", "--delete", "-d"}
)
DESTRUCTIVE_GIT_SUBCOMMANDS = {
    ("reset", "--hard"),
    ("reset", "--merge"),
    ("reset", "--keep"),
    ("clean", "-fd"),
    ("clean", "-fdx"),
    ("clean", "-xdf"),
    ("branch", "-D"),
    ("branch", "-d"),
    ("tag", "-d"),
    ("push", "--delete"),
    ("filter-branch", "--force"),
}


class UnsafeCommandError(ValueError):
    """Raised when automation asks for a command the policy forbids."""


def _executable(argv: Sequence[str]) -> str:
    return argv[0].rsplit("/", 1)[-1]


def validate_command(
    argv: Sequence[str],
    *,
    allowed_executables: frozenset[str] = DEFAULT_ALLOWED_EXECUTABLES,
    allow_protected_push: bool = False,
) -> list[str]:
    if isinstance(argv, str):
        raise UnsafeCommandError(
            "commands must be argument vectors, not shell strings: " + argv
        )
    cleaned = [str(item) for item in argv]
    if not cleaned:
        raise UnsafeCommandError("empty command vector")
    if _executable(cleaned) not in allowed_executables:
        raise UnsafeCommandError(f"executable not allowlisted: {cleaned[0]}")

    if _executable(cleaned) != "git":
        return cleaned

    arguments = cleaned[1:]
    if not arguments:
        return cleaned

    subcommand = arguments[0]
    for pair in DESTRUCTIVE_GIT_SUBCOMMANDS:
        if subcommand == pair[0] and pair[1] in arguments:
            raise UnsafeCommandError(f"destructive git operation refused: {' '.join(cleaned)}")

    if subcommand == "push":
        for argument in arguments[1:]:
            if argument in FORBIDDEN_PUSH_FLAGS:
                raise UnsafeCommandError(f"force or mirror push refused: {' '.join(cleaned)}")
            destination = argument.split(":", 1)[-1] if ":" in argument else argument
            if destination in PROTECTED_BRANCHES and not allow_protected_push:
                raise UnsafeCommandError(
                    f"direct push to a protected branch refused: {' '.join(cleaned)}"
                )

    return cleaned


def run(
    argv: Sequence[str],
    *,
    cwd: str | None = None,
    timeout: int = DEFAULT_TIMEOUT_SECONDS,
    check: bool = False,
    allow_protected_push: bool = False,
    allowed_executables: frozenset[str] = DEFAULT_ALLOWED_EXECUTABLES,
) -> subprocess.CompletedProcess[str]:
    """Execute an allowlisted argument vector with no shell and a hard timeout."""
    command = validate_command(
        argv,
        allowed_executables=allowed_executables,
        allow_protected_push=allow_protected_push,
    )
    return subprocess.run(
        command,
        cwd=cwd,
        shell=False,
        capture_output=True,
        text=True,
        timeout=timeout,
        check=check,
    )
