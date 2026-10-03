#!/usr/bin/env python3
"""Synchronize the managed status block in the living architecture ledger."""

from __future__ import annotations

import argparse
from datetime import datetime, timezone
import json
from pathlib import Path
import re
from typing import Sequence

BEGIN = "<!-- BEGIN POST_MERGE_SYNC -->"
END = "<!-- END POST_MERGE_SYNC -->"
SHA_RE = re.compile(r"^[0-9a-fA-F]{40}$")
PR_RE = re.compile(r"#(\d+)\b")


class SyncError(ValueError):
    """Raised when a post-merge ledger sync request is unsafe or malformed."""


def _clean(value: str) -> str:
    return " ".join(value.replace("\r", " ").replace("\n", " ").split())


def _infer_pr_number(title: str) -> int | None:
    match = PR_RE.search(title)
    return int(match.group(1)) if match else None


def sync_ledger_text(
    text: str,
    *,
    main_sha: str,
    pr_number: int | None,
    pr_title: str,
    merged_at: str,
) -> str:
    if not SHA_RE.fullmatch(main_sha):
        raise SyncError("main SHA must be a 40-character hexadecimal value")
    if text.count(BEGIN) != 1 or text.count(END) != 1:
        raise SyncError("ledger must contain exactly one managed post-merge sync block")
    begin = text.index(BEGIN)
    end = text.index(END, begin) + len(END)
    if end <= begin:
        raise SyncError("invalid post-merge sync marker order")

    title = _clean(pr_title) or "unknown"
    resolved_pr = pr_number if pr_number is not None else _infer_pr_number(title)
    pr_label = f"#{resolved_pr}" if resolved_pr is not None else "not encoded in merge commit"
    timestamp = _clean(merged_at) or datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")
    managed = (
        f"{BEGIN}\n"
        f"- Last synced main SHA: `{main_sha.lower()}`\n"
        f"- Last merged PR: {pr_label}\n"
        f"- Last merge title: {title}\n"
        f"- Synced at: {timestamp}\n"
        f"{END}"
    )
    return text[:begin] + managed + text[end:]


def _build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Update the managed post-merge architecture memory block")
    parser.add_argument("--repo-root", type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument("--ledger", type=Path)
    parser.add_argument("--main-sha", required=True)
    parser.add_argument("--pr-number", type=int)
    parser.add_argument("--pr-title", default="")
    parser.add_argument("--merged-at", default="")
    parser.add_argument("--report", action="store_true")
    return parser


def main(argv: Sequence[str] | None = None) -> int:
    args = _build_parser().parse_args(argv)
    ledger = args.ledger or (args.repo_root / "docs" / "architecture" / "DECISION_LOG.md")
    try:
        before = ledger.read_text(encoding="utf-8")
        after = sync_ledger_text(
            before,
            main_sha=args.main_sha,
            pr_number=args.pr_number,
            pr_title=args.pr_title,
            merged_at=args.merged_at,
        )
        if after != before:
            ledger.write_text(after, encoding="utf-8")
    except (OSError, SyncError) as exc:
        if args.report:
            print(json.dumps({"status": "FAIL", "error": str(exc)}, ensure_ascii=False, sort_keys=True))
        return 1

    if args.report:
        print(
            json.dumps(
                {"status": "PASS", "changed": after != before, "main_sha": args.main_sha.lower()},
                ensure_ascii=False,
                sort_keys=True,
            )
        )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
