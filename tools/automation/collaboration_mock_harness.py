#!/usr/bin/env python3
"""Offline-only collaboration-message inspection harness.

The harness intentionally has no provider client and no network execution path.
It reads a saved GitHub event payload, reports the collaboration text that would
be reviewed, and exposes whether the live billing guard *would* activate while
forcing provider execution to remain disabled.
"""

from __future__ import annotations

import argparse
import json
import os
from pathlib import Path
from typing import Any, Mapping, Sequence

SUPPORTED_EVENTS = frozenset(
    {"issues", "issue_comment", "pull_request", "pull_request_target", "pull_request_review"}
)


class MockHarnessError(ValueError):
    """Raised when a local collaboration event cannot be inspected safely."""


def _body(value: Any) -> str:
    return value if isinstance(value, str) else ""


def _messages(event_name: str, payload: Mapping[str, Any]) -> list[str]:
    if event_name == "issue_comment":
        comment = payload.get("comment")
        return [_body(comment.get("body"))] if isinstance(comment, Mapping) else [""]
    if event_name == "pull_request_review":
        review = payload.get("review")
        return [_body(review.get("body"))] if isinstance(review, Mapping) else [""]
    if event_name in {"pull_request", "pull_request_target"}:
        pr = payload.get("pull_request")
        return [_body(pr.get("body"))] if isinstance(pr, Mapping) else [""]
    issue = payload.get("issue")
    return [_body(issue.get("body"))] if isinstance(issue, Mapping) else [""]


def inspect_event(
    event_name: str,
    payload: Mapping[str, Any],
    *,
    env: Mapping[str, str] | None = None,
) -> dict[str, Any]:
    if event_name not in SUPPORTED_EVENTS:
        raise MockHarnessError(f"unsupported collaboration event: {event_name}")
    if not isinstance(payload, Mapping):
        raise MockHarnessError("event payload must be an object")

    variables = os.environ if env is None else env
    live_guard_would_activate = (
        variables.get("AI_COLLABORATION_ENABLED") == "true"
        and variables.get("AI_COLLABORATION_BILLING_APPROVED") == "true"
    )
    messages = _messages(event_name, payload)
    return {
        "status": "PASS",
        "mode": "MOCK_ONLY",
        "event_name": event_name,
        "message_count": len(messages),
        "messages": messages,
        "live_guard_would_activate": live_guard_would_activate,
        "provider_calls_executed": 0,
        "network_enabled": False,
        "billing_changes": 0,
        "zero_additional_billing_preserved": True,
    }


def _build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Inspect collaboration messages without provider calls")
    parser.add_argument("--event-name", required=True, choices=sorted(SUPPORTED_EVENTS))
    parser.add_argument("--event-file", required=True, type=Path)
    parser.add_argument("--report", action="store_true", help="emit the local JSON report")
    return parser


def main(argv: Sequence[str] | None = None) -> int:
    args = _build_parser().parse_args(argv)
    try:
        payload = json.loads(args.event_file.read_text(encoding="utf-8"))
        if not isinstance(payload, dict):
            raise MockHarnessError("event payload must be an object")
        report = inspect_event(args.event_name, payload)
    except (OSError, json.JSONDecodeError, MockHarnessError) as exc:
        if args.report:
            print(json.dumps({"status": "FAIL", "error": str(exc)}, ensure_ascii=False, sort_keys=True))
        return 2

    if args.report:
        print(json.dumps(report, ensure_ascii=False, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
