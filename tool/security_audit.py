#!/usr/bin/env python3
"""HISTORICAL / NON-CANONICAL compatibility entry point.

The canonical security policy lives in typed structural contracts under
tests/quality_gate/test_current_topology_security_gate.py. This entry point
remains only for maintained scripts that still invoke tool/security_audit.py;
it delegates to the canonical gate instead of carrying a second lexical policy.
"""
from __future__ import annotations

from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
CANONICAL_GATE = (
    ROOT / "tests" / "quality_gate" / "test_current_topology_security_gate.py"
)


def main() -> int:
    command = [
        sys.executable,
        "-m",
        "pytest",
        "-q",
        str(CANONICAL_GATE),
    ]
    return subprocess.call(command, cwd=ROOT)


if __name__ == "__main__":
    raise SystemExit(main())
