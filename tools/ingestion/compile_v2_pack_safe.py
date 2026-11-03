#!/usr/bin/env python3
"""Compatibility entrypoint for existing SQLite v2 build integrations.

The canonical implementation lives in compiler.py.  Keep the older import and
CLI paths working; do not maintain a second compiler.
"""
from __future__ import annotations

# Support both the historical direct script and the package import path.
if __package__:
    from .compiler import build, tag
else:
    from compiler import build, tag

__all__ = ["build", "tag"]


def main() -> int:
    import argparse
    import sqlite3
    import sys

    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", required=True)
    parser.add_argument("--output", required=True)
    args = parser.parse_args()
    try:
        build(args.source, args.output)
    except (ValueError, sqlite3.Error, KeyError, TypeError) as exc:
        print("REJECTED", exc, file=sys.stderr)
        return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
