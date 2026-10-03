#!/usr/bin/env python3
"""Deterministic PR diff analyzer for inline architecture review comments.

This module consumes changed-file metadata plus read-only PR-head file snapshots.
It never executes code from the pull request.
"""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path
from typing import Any, Iterable, Mapping, Sequence

MAX_FILE_LINES = 1000
PRESENTATION_PREFIXES = (
    "lib/ui/",
    "lib/ui_v35/",
    "lib/presentation/",
    "lib/design_system/",
)
_HUNK = re.compile(r"^@@ -\d+(?:,\d+)? \+(?P<start>\d+)(?:,\d+)? @@")
_AUDIO_IMPORT = re.compile(
    r"""^\s*import\s+['"]package:(?:flutter_tts|speech_to_text)(?:/[^'"]*)?['"]\s*;"""
)
_IGNORE_LINT = re.compile(r"^\s*//\s*(?:ignore|ignore_for_file)\s*:")


class ReviewInputError(ValueError):
    """Raised when the analyzer receives malformed PR metadata."""


def _is_presentation(path: str) -> bool:
    normalized = path.replace("\\", "/")
    return (
        any(normalized.startswith(prefix) for prefix in PRESENTATION_PREFIXES)
        or "/presentation/" in normalized
    )


def _right_side_lines(patch: str) -> tuple[list[tuple[int, str, bool]], list[int]]:
    """Return right-side diff lines and the line numbers added by the PR."""
    current_new: int | None = None
    right_lines: list[tuple[int, str, bool]] = []
    additions: list[int] = []

    for raw in patch.splitlines():
        match = _HUNK.match(raw)
        if match:
            current_new = int(match.group("start"))
            continue
        if current_new is None:
            continue
        if raw.startswith("\\ No newline at end of file"):
            continue
        if raw.startswith("+") and not raw.startswith("+++"):
            text = raw[1:]
            right_lines.append((current_new, text, True))
            additions.append(current_new)
            current_new += 1
            continue
        if raw.startswith("-") and not raw.startswith("---"):
            continue
        if raw.startswith(" "):
            right_lines.append((current_new, raw[1:], False))
            current_new += 1

    return right_lines, additions


def _anchor_line(patch: str) -> int | None:
    right_lines, additions = _right_side_lines(patch)
    if additions:
        return additions[0]
    return right_lines[0][0] if right_lines else None


def _comment(path: str, line: int, body: str) -> dict[str, Any]:
    return {"path": path, "line": line, "side": "RIGHT", "body": body}


def analyze_file(
    *,
    path: str,
    patch: str,
    content: str | None,
    status: str = "modified",
) -> list[dict[str, Any]]:
    if not isinstance(path, str) or not path:
        raise ReviewInputError("changed file path must be a non-empty string")
    if not isinstance(patch, str):
        patch = ""
    if status == "removed":
        content = None

    findings: list[dict[str, Any]] = []
    right_lines, _ = _right_side_lines(patch)

    for line_no, text, is_added in right_lines:
        if not is_added:
            continue
        if _IGNORE_LINT.match(text):
            findings.append(
                _comment(
                    path,
                    line_no,
                    "⚠️ **Lint suppression:** an analyzer/lint ignore was added here. "
                    "Remove the suppression and fix the underlying warning instead.",
                )
            )
        if _is_presentation(path) and _AUDIO_IMPORT.match(text):
            findings.append(
                _comment(
                    path,
                    line_no,
                    "⚠️ **Presentation boundary:** device-facing speech packages such as "
                    "`flutter_tts` and `speech_to_text` must remain behind services/controllers.",
                )
            )

    if content is not None:
        line_count = len(content.splitlines())
        if line_count > MAX_FILE_LINES:
            anchor = _anchor_line(patch)
            if anchor is not None:
                findings.append(
                    _comment(
                        path,
                        anchor,
                        f"⚠️ **File-size boundary:** this changed file is {line_count} lines "
                        f"(maximum: {MAX_FILE_LINES}). Split by coherent responsibility.",
                    )
                )

    deduped: list[dict[str, Any]] = []
    seen: set[tuple[str, int, str]] = set()
    for item in findings:
        key = (item["path"], item["line"], item["body"])
        if key not in seen:
            seen.add(key)
            deduped.append(item)
    return deduped


def analyze_changed_files(
    files: Iterable[Mapping[str, Any]],
    *,
    head_root: Path,
) -> list[dict[str, Any]]:
    comments: list[dict[str, Any]] = []
    root = head_root.resolve()

    for entry in files:
        path = entry.get("filename")
        if not isinstance(path, str) or not path:
            raise ReviewInputError("each changed-file record requires filename")
        patch = entry.get("patch")
        status = entry.get("status")
        if not isinstance(status, str):
            status = "modified"

        content: str | None = None
        snapshot_ref = entry.get("snapshot")
        if status != "removed" and isinstance(snapshot_ref, str) and snapshot_ref:
            snapshot = (head_root / snapshot_ref).resolve()
            try:
                snapshot.relative_to(root)
            except ValueError as exc:
                raise ReviewInputError(f"snapshot escapes head root for {path!r}") from exc
            if snapshot.is_file():
                content = snapshot.read_text(encoding="utf-8")

        comments.extend(
            analyze_file(
                path=path,
                patch=patch if isinstance(patch, str) else "",
                content=content,
                status=status,
            )
        )
    return comments


def _build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Generate deterministic inline PR review comments"
    )
    parser.add_argument("--files-json", required=True, type=Path)
    parser.add_argument("--head-root", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    return parser


def main(argv: Sequence[str] | None = None) -> int:
    args = _build_parser().parse_args(argv)
    try:
        payload = json.loads(args.files_json.read_text(encoding="utf-8"))
        if not isinstance(payload, list):
            raise ReviewInputError("files JSON must be an array")
        comments = analyze_changed_files(payload, head_root=args.head_root)
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(
            json.dumps(comments, ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8",
        )
    except (OSError, UnicodeError, json.JSONDecodeError, ReviewInputError) as exc:
        print(f"inline review analysis failed: {exc}")
        return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
