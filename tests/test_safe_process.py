"""Untrusted text must never reach a shell; destructive git stays unreachable."""
from __future__ import annotations

from pathlib import Path
import re

import pytest

from tools.safe_process import UnsafeCommandError, run, validate_command

ROOT = Path(__file__).resolve().parents[1]
SOVEREIGN_TOOLS = sorted((ROOT / "tools").glob("sovereign_*.py"))


def test_automation_tools_never_request_a_shell():
    offenders = [
        f"{path.name}:{number}"
        for path in SOVEREIGN_TOOLS
        for number, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1)
        if "shell=True" in line
    ]
    assert not offenders, offenders


def test_automation_tools_never_force_push_or_write_main():
    offenders = []
    for path in SOVEREIGN_TOOLS:
        text = path.read_text(encoding="utf-8")
        for pattern in (r"--force\b", r"--force-with-lease", r"push\s+origin\s+main"):
            if re.search(pattern, text):
                offenders.append(f"{path.name}: {pattern}")
    assert not offenders, offenders


@pytest.mark.parametrize(
    "argv",
    [
        ["git", "push", "origin", "main"],
        ["git", "push", "origin", "staging/x:main"],
        ["git", "push", "--force", "origin", "staging/x"],
        ["git", "push", "-f", "origin", "topic"],
        ["git", "reset", "--hard", "HEAD~1"],
        ["git", "clean", "-fdx"],
        ["git", "branch", "-D", "topic"],
        ["git", "push", "origin", "--delete", "topic"],
        ["bash", "-c", "git status"],
        ["rm", "-rf", "lib"],
    ],
)
def test_destructive_commands_are_refused(argv):
    with pytest.raises(UnsafeCommandError):
        validate_command(argv)


def test_shell_strings_are_refused():
    with pytest.raises(UnsafeCommandError):
        validate_command("git status && rm -rf /")
    with pytest.raises(UnsafeCommandError):
        run("echo $(id)")


def test_safe_commands_are_allowed_and_executed_without_a_shell(tmp_path):
    result = run(["git", "init", str(tmp_path)])
    assert result.returncode == 0
    assert (tmp_path / ".git").is_dir()


def test_branch_push_is_allowed_but_protected_branch_push_is_not():
    assert validate_command(["git", "push", "origin", "staging/topic"]) == [
        "git",
        "push",
        "origin",
        "staging/topic",
    ]
    with pytest.raises(UnsafeCommandError):
        validate_command(["git", "push", "origin", "HEAD:main"])
