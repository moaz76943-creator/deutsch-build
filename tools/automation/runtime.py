#!/usr/bin/env python3
"""Canonical command router for repository automation.

This module is the single supported execution reference for the planner,
atomic dispatcher, and state ledger. The implementation modules remain
importable for tests and compatibility, but orchestration should invoke this
router instead of duplicating script paths.
"""

from __future__ import annotations

import argparse
from typing import Sequence

try:
    from . import autonomous_daemon, dispatcher, state_manager
except ImportError:  # Direct script execution from tools/automation.
    import autonomous_daemon  # type: ignore
    import dispatcher  # type: ignore
    import state_manager  # type: ignore


COMPONENTS = ("planner", "dispatch", "state")


def _build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Canonical automation runtime router")
    parser.add_argument("component", choices=COMPONENTS)
    return parser


def main(argv: Sequence[str] | None = None) -> int:
    args, remainder = _build_parser().parse_known_args(argv)
    forwarded = list(remainder)
    if args.component == "planner":
        return dispatcher.main(forwarded)
    if args.component == "dispatch":
        return autonomous_daemon.main(forwarded)
    return state_manager.main(forwarded)


if __name__ == "__main__":
    raise SystemExit(main())
