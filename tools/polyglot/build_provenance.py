#!/usr/bin/env python3
"""T94: build artifact provenance (source SHA, environment, version, checksums).

Generates a deterministic, fail-closed provenance record for the build:

* ``version``       — name/version/build parsed from ``pubspec.yaml``;
* ``pinned``        — SHA-256 + byte size for every tracked build input file,
  regenerated deterministically from the working tree (no timestamps, no
  environment leakage); compared byte-for-byte by ``--check``;
* ``volatile``      — source commit SHA + subject, generation timestamp,
  build environment (Python/OS), CI run metadata from the environment.
  These are recorded for traceability but intentionally excluded from the
  ``--check`` comparison so the artifact stays reproducible.

Usage:
    python3 tools/polyglot/build_provenance.py --write   # regenerate artifact
    python3 tools/polyglot/build_provenance.py --check   # verify, exit 1 on drift

Output: assets/registry/build_provenance.json

The tool never prints secret material and reads only the local tree and
non-secret CI environment variables.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import platform
import re
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
ARTIFACT = REPO_ROOT / "assets/registry" / "build_provenance.json"

SCHEMA_VERSION = 1
REPORT_ID = "polyglot-build-provenance"

PUBSPEC = REPO_ROOT / "pubspec.yaml"

# Build inputs whose integrity must be traceable to exact source commits.
PINNED_FILES = (
    "pubspec.yaml",
    "lib/core/i18n/canonical_language_catalog.dart",
    "lib/core/i18n/language_registry.dart",
    "assets/registry/languages_100.json",
    "assets/registry/readiness_report.json",
    "assets/registry/content_inventory.json",
    "assets/lang_data/catalog.json",
    "assets/database/master_100_languages_spec.json",
)

_VERSION_RE = re.compile(r"^version:\s*(\S+)\s*$", re.MULTILINE)
_SHA_RE = re.compile(r"^[0-9a-f]{64}$")


class ProvenanceError(Exception):
    pass


def _sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1 << 20), b""):
            digest.update(chunk)
    return digest.hexdigest()


def _app_version() -> dict:
    if not PUBSPEC.is_file():
        raise ProvenanceError(f"missing {PUBSPEC}")
    match = _VERSION_RE.search(PUBSPEC.read_text(encoding="utf-8"))
    if not match:
        raise ProvenanceError("pubspec.yaml has no 'version:' line")
    raw = match.group(1)
    name, _, build = raw.partition("+")
    return {
        "name": "deutsch_bilarabi",
        "version": name,
        "buildNumber": int(build) if build.isdigit() else 0,
    }


def _source_commit() -> dict:
    sha = os.environ.get("GITHUB_SHA")
    if not sha:
        try:
            sha = subprocess.run(
                ["git", "rev-parse", "HEAD"],
                cwd=REPO_ROOT,
                capture_output=True,
                text=True,
                check=True,
            ).stdout.strip()
        except (OSError, subprocess.CalledProcessError):
            return {"sourceCommit": "unknown", "sourceCommitSubject": "unknown"}
    subject = "unknown"
    try:
        subject = subprocess.run(
            ["git", "log", "-1", "--format=%s", sha],
            cwd=REPO_ROOT,
            capture_output=True,
            text=True,
        ).stdout.strip() or "unknown"
    except (OSError, subprocess.CalledProcessError):
        pass
    return {"sourceCommit": sha, "sourceCommitSubject": subject}


def _build_environment() -> dict:
    env = {
        "pythonImplementation": platform.python_implementation(),
        "pythonVersion": platform.python_version(),
        "osName": platform.system(),
        "osRelease": platform.release(),
        "machine": platform.machine(),
    }
    for key in ("GITHUB_RUN_ID", "GITHUB_RUN_NUMBER", "GITHUB_WORKFLOW"):
        value = os.environ.get(key)
        if value:
            env[key] = value
    return env


def build_pinned() -> dict:
    files: dict[str, dict] = {}
    for rel in PINNED_FILES:
        path = REPO_ROOT / rel
        if not path.is_file():
            raise ProvenanceError(f"pinned file missing: {rel}")
        data = path.read_bytes()
        files[rel] = {"sha256": hashlib.sha256(data).hexdigest(), "bytes": len(data)}
    return {"files": files, "fileCount": len(files)}


def build_provenance() -> dict:
    return {
        "schemaVersion": SCHEMA_VERSION,
        "reportId": REPORT_ID,
        "version": _app_version(),
        "pinned": build_pinned(),
        "volatile": {
            "generatedAt": datetime.now(timezone.utc).isoformat(
                timespec="seconds"
            ),
            **_source_commit(),
            "buildEnvironment": _build_environment(),
        },
    }


def verify(payload: dict) -> list[str]:
    """Return a list of policy violations; empty means the artifact is sound."""
    errors: list[str] = []
    if payload.get("schemaVersion") != SCHEMA_VERSION:
        errors.append("schemaVersion mismatch")
    if payload.get("reportId") != REPORT_ID:
        errors.append("reportId mismatch")
    version = payload.get("version") or {}
    try:
        expected = _app_version()
    except ProvenanceError as exc:
        errors.append(f"pubspec unreadable: {exc}")
        expected = {}
    if version != expected:
        errors.append("version drift vs pubspec.yaml")
    pinned = payload.get("pinned") or {}
    files = pinned.get("files") or {}
    if not isinstance(files, dict) or not files:
        errors.append("pinned.files empty or malformed")
        return errors
    for rel in PINNED_FILES:
        entry = files.get(rel)
        if not isinstance(entry, dict) or not entry:
            errors.append(f"pinned entry missing: {rel}")
            continue
        if not _SHA_RE.match(str(entry.get("sha256", ""))):
            errors.append(f"pinned sha256 malformed: {rel}")
            continue
        path = REPO_ROOT / rel
        if not path.is_file():
            errors.append(f"pinned file missing from tree: {rel}")
            continue
        data = path.read_bytes()
        if hashlib.sha256(data).hexdigest() != entry["sha256"]:
            errors.append(f"checksum drift: {rel}")
        if entry.get("bytes") != len(data):
            errors.append(f"size drift: {rel}")
    if pinned.get("fileCount") != len(files):
        errors.append("pinned.fileCount mismatch")
    volatile = payload.get("volatile") or {}
    if not str(volatile.get("sourceCommit", "")):
        errors.append("volatile.sourceCommit missing")
    if not isinstance(volatile.get("buildEnvironment"), dict):
        errors.append("volatile.buildEnvironment missing")
    return errors


def cmd_write() -> int:
    payload = build_provenance()
    ARTIFACT.parent.mkdir(parents=True, exist_ok=True)
    ARTIFACT.write_text(
        json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8"
    )
    print(f"wrote {ARTIFACT} ({payload['pinned']['fileCount']} pinned files)")
    return 0


def cmd_check() -> int:
    if not ARTIFACT.is_file():
        print(f"FAIL: provenance artifact missing: {ARTIFACT}", file=sys.stderr)
        return 1
    payload = json.loads(ARTIFACT.read_text(encoding="utf-8"))
    errors = verify(payload)
    if errors:
        for err in errors:
            print(f"FAIL: {err}", file=sys.stderr)
        return 1
    commit = payload.get("volatile", {}).get("sourceCommit", "unknown")
    print(
        f"OK: build provenance valid "
        f"({payload['pinned']['fileCount']} pinned files, commit {commit})"
    )
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("--write", action="store_true", help="regenerate artifact")
    group.add_argument("--check", action="store_true", help="verify; fail closed")
    args = parser.parse_args()
    try:
        return cmd_write() if args.write else cmd_check()
    except ProvenanceError as exc:
        print(f"FAIL: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
