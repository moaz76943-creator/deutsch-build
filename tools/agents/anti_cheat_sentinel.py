#!/usr/bin/env python3
"""Fail closed on presentation audio imports and quality-rule bypasses."""

from __future__ import annotations

import argparse
import json
import re
import subprocess
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Iterable, Sequence

AUDIO_PACKAGES = frozenset(
    {
        "audioplayers",
        "flutter_sound",
        "flutter_tts",
        "just_audio",
        "record",
        "speech_to_text",
    }
)
PRESENTATION_PARTS = frozenset({"presentation", "screens", "ui", "ui_v35", "widgets"})
IMPORT_RE = re.compile(r"^\s*import\s+['\"]package:([^/'\"]+)")
BYPASS_PATTERNS: tuple[tuple[str, re.Pattern[str]], ...] = (
    ("dart-ignore", re.compile(r"^\s*//\s*ignore(?:_for_file)?\s*:", re.IGNORECASE)),
    ("python-noqa", re.compile(r"#\s*noqa\b", re.IGNORECASE)),
    ("python-type-ignore", re.compile(r"#\s*type\s*:\s*ignore\b", re.IGNORECASE)),
    ("python-lint-disable", re.compile(r"#\s*(?:pylint|pyright)\s*:\s*(?:disable|ignore)\b", re.IGNORECASE)),
    (
        "js-lint-disable",
        re.compile(
            r"^\s*(?://|/\*|\*)\s*(?:eslint-disable|@ts-ignore|@ts-nocheck)\b",
            re.IGNORECASE,
        ),
    ),
    (
        "non-fatal-analyzer",
        re.compile(r"\b(?:flutter|dart)\s+analy(?:ze|sis)\b[^\n]*(?:--no-fatal-warnings|--no-fatal-infos)", re.IGNORECASE),
    ),
    (
        "ignored-quality-exit",
        re.compile(r"\b(?:flutter\s+(?:analyze|test)|dart\s+analyze|pytest|quality_audit\.py|local_quality_gate\.sh)\b[^\n]*(?:\|\|\s*true|;\s*exit\s+0\b)", re.IGNORECASE),
    ),
)
TEXT_EXTENSIONS = frozenset(
    {
        ".dart",
        ".py",
        ".sh",
        ".bash",
        ".yml",
        ".yaml",
        ".json",
        ".toml",
        ".md",
        ".txt",
        ".gradle",
        ".kts",
        ".js",
        ".ts",
    }
)


@dataclass(frozen=True)
class Violation:
    path: str
    line: int
    rule: str
    message: str
    snippet: str


def _git(repo: Path, *args: str) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        ["git", "-C", str(repo), *args],
        check=False,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )


def _is_presentation(path: str) -> bool:
    parts = Path(path.replace("\\", "/")).parts
    return bool(parts and parts[0] == "lib" and PRESENTATION_PARTS.intersection(parts[1:-1]))


def _is_workflow(path: str) -> bool:
    normalized = path.replace("\\", "/")
    return normalized.startswith(".github/workflows/") and normalized.endswith((".yml", ".yaml"))


def _quality_bypass(line: str, path: str) -> str | None:
    for name, pattern in BYPASS_PATTERNS:
        if pattern.search(line):
            return name
    if _is_workflow(path) and re.search(r"^\s*continue-on-error\s*:\s*true\s*(?:#.*)?$", line, re.IGNORECASE):
        return "workflow-continue-on-error"
    if _is_workflow(path) and re.search(r"^\s*allow_failure\s*:\s*true\s*(?:#.*)?$", line, re.IGNORECASE):
        return "workflow-allow-failure"
    return None


def scan_text(path: str, text: str) -> list[Violation]:
    violations: list[Violation] = []
    presentation = _is_presentation(path)
    for line_number, line in enumerate(text.splitlines(), start=1):
        if presentation:
            imported = IMPORT_RE.search(line)
            if imported and imported.group(1).lower() in AUDIO_PACKAGES:
                violations.append(
                    Violation(
                        path=path,
                        line=line_number,
                        rule="presentation-audio-import",
                        message="presentation must depend on an audio abstraction, not an audio plugin",
                        snippet=line.strip()[:240],
                    )
                )
        bypass = _quality_bypass(line, path)
        if bypass:
            violations.append(
                Violation(
                    path=path,
                    line=line_number,
                    rule="quality-bypass",
                    message=f"quality or lint bypass is forbidden ({bypass})",
                    snippet=line.strip()[:240],
                )
            )
    return violations


def _looks_textual(path: Path) -> bool:
    return path.suffix.lower() in TEXT_EXTENSIONS or path.name in {
        "Dockerfile",
        "Makefile",
        "analysis_options.yaml",
    }


def scan_file(repo_root: Path, relative_path: str) -> list[Violation]:
    path = repo_root / relative_path
    if not path.is_file() or not _looks_textual(path):
        return []
    try:
        text = path.read_text(encoding="utf-8")
    except (UnicodeDecodeError, OSError):
        return []
    return scan_text(relative_path.replace("\\", "/"), text)


def _paths_from_git(repo_root: Path, args: Sequence[str]) -> list[str]:
    result = _git(repo_root, *args)
    if result.returncode != 0:
        detail = result.stderr.strip() or result.stdout.strip()
        raise ValueError(detail or "git path discovery failed")
    return sorted({line.strip() for line in result.stdout.splitlines() if line.strip()})


def changed_paths(repo_root: Path, base_ref: str) -> list[str]:
    return _paths_from_git(
        repo_root,
        ["diff", "--name-only", "--diff-filter=ACMR", f"{base_ref}...HEAD"],
    )


def staged_paths(repo_root: Path) -> list[str]:
    return _paths_from_git(repo_root, ["diff", "--cached", "--name-only", "--diff-filter=ACMR"])


def tracked_paths(repo_root: Path) -> list[str]:
    return _paths_from_git(repo_root, ["ls-files"])


def scan_paths(repo_root: Path, paths: Iterable[str]) -> list[Violation]:
    violations: list[Violation] = []
    for path in sorted(set(paths)):
        violations.extend(scan_file(repo_root, path))
    return violations


def _parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repo-root", type=Path, default=Path("."))
    source = parser.add_mutually_exclusive_group()
    source.add_argument("--changed", metavar="BASE_REF")
    source.add_argument("--staged", action="store_true")
    parser.add_argument("--json-report", type=Path)
    parser.add_argument("paths", nargs="*")
    return parser


def main(argv: Sequence[str] | None = None) -> int:
    args = _parser().parse_args(argv)
    root = args.repo_root.resolve()
    try:
        if args.paths:
            paths = args.paths
        elif args.changed:
            paths = changed_paths(root, args.changed)
        elif args.staged:
            paths = staged_paths(root)
        else:
            paths = tracked_paths(root)
        violations = scan_paths(root, paths)
        report = {
            "schema": 1,
            "accepted": not violations,
            "scanned_paths": len(set(paths)),
            "violations": [asdict(item) for item in violations],
        }
    except (OSError, ValueError) as exc:
        report = {
            "schema": 1,
            "accepted": False,
            "scanned_paths": 0,
            "violations": [],
            "error": str(exc),
        }

    rendered = json.dumps(report, indent=2, sort_keys=True)
    if args.json_report:
        args.json_report.parent.mkdir(parents=True, exist_ok=True)
        args.json_report.write_text(rendered + "\n", encoding="utf-8")
    print(rendered)
    return 0 if report["accepted"] else 2


if __name__ == "__main__":
    raise SystemExit(main())
