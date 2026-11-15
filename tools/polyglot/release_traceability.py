#!/usr/bin/env python3
"""T96: release artifact traceability to exact source commits.

T94 pins the integrity of the build inputs (SHA-256 per file) and records the
source commit and environment in ``assets/registry/build_provenance.json``.
This tool closes the remaining gap: it binds a *release artifact* (APK/AAB) to

* the exact source commit (``GITHUB_SHA`` or ``git rev-parse HEAD``; when
  ``GITHUB_SHA`` is set the two must agree, fail-closed),
* the pubspec application version (``version:`` line),
* the committed provenance record (file SHA-256 + verified pinned section,
  i.e. the artifact traces to byte-identical build inputs),
* the artifact's own bytes (SHA-256 + size).

It never prints secret material and reads only the local tree and non-secret
CI environment variables.

Usage:
    python3 tools/polyglot/release_traceability.py --write \\
        --artifact deutsch-app.apk --kind apk \\
        [--provenance assets/registry/build_provenance.json] \\
        [--output release-metadata/release_traceability.json] \\
        [--build-name 1.0.0 --build-number 1]
    python3 tools/polyglot/release_traceability.py --check \\
        --artifact deutsch-app.apk \\
        [--record release-metadata/release_traceability.json] \\
        [--provenance assets/registry/build_provenance.json]

Exit codes: 0 ok, 1 fail-closed (reasons printed), 2 on usage/environment
errors.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import platform
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
DEFAULT_PROVENANCE = REPO_ROOT / "assets/registry" / "build_provenance.json"
DEFAULT_OUTPUT = REPO_ROOT / "release-metadata" / "release_traceability.json"

sys.path.insert(0, str(Path(__file__).resolve().parent))
import build_provenance  # noqa: E402

SCHEMA_VERSION = 1
REPORT_ID = "polyglot-release-traceability"
KINDS = ("apk", "aab")


class TraceabilityError(Exception):
    pass


def _sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1 << 20), b""):
            digest.update(chunk)
    return digest.hexdigest()


def _git_head() -> str:
    result = subprocess.run(
        ["git", "rev-parse", "HEAD"],
        cwd=REPO_ROOT,
        capture_output=True,
        text=True,
        check=True,
    )
    return result.stdout.strip()


def _git_subject(commit: str) -> str:
    try:
        result = subprocess.run(
            ["git", "log", "-1", "--format=%s", commit],
            cwd=REPO_ROOT,
            capture_output=True,
            text=True,
            check=True,
        )
        return result.stdout.strip() or "unknown"
    except subprocess.CalledProcessError:
        return "unknown"


def current_source_commit() -> str:
    """Resolve the exact source commit; fail closed when env/HEAD disagree."""
    env_sha = (os.environ.get("GITHUB_SHA") or "").strip()
    try:
        head = _git_head()
    except subprocess.CalledProcessError as exc:
        raise TraceabilityError("git HEAD unavailable") from exc
    if env_sha and env_sha != head:
        raise TraceabilityError(
            f"GITHUB_SHA ({env_sha}) != git HEAD ({head}); refusing to trace artifact"
        )
    return env_sha or head


def _build_environment() -> dict:
    env = {
        "pythonImplementation": platform.python_implementation(),
        "pythonVersion": platform.python_version(),
        "osName": platform.system(),
        "machine": platform.machine(),
    }
    for key in ("GITHUB_RUN_ID", "GITHUB_RUN_NUMBER", "GITHUB_WORKFLOW"):
        value = os.environ.get(key)
        if value:
            env[key] = value
    return env


def build_record(
    artifact_path: Path,
    kind: str,
    provenance_path: Path,
    build_name: str | None = None,
    build_number: int | None = None,
) -> dict:
    if kind not in KINDS:
        raise TraceabilityError(f"kind must be one of {KINDS}, got {kind!r}")
    if not artifact_path.is_file():
        raise TraceabilityError(f"artifact missing: {artifact_path}")
    artifact_bytes = artifact_path.read_bytes()

    provenance_file = Path(provenance_path)
    if not provenance_file.is_file():
        raise TraceabilityError(f"provenance record missing: {provenance_file}")
    provenance_bytes = provenance_file.read_bytes()
    try:
        provenance = json.loads(provenance_bytes)
    except json.JSONDecodeError as exc:
        raise TraceabilityError(f"provenance record malformed: {exc}") from exc

    # The tree itself must be clean against the committed provenance record,
    # otherwise the artifact cannot be traced to byte-identical inputs.
    errors = build_provenance.verify(provenance)
    if errors:
        raise TraceabilityError(
            "provenance verification failed: " + "; ".join(errors)
        )

    source_commit = current_source_commit()
    provenance_commit = str(provenance.get("volatile", {}).get("sourceCommit", ""))
    if source_commit != provenance_commit:
        raise TraceabilityError(
            f"source commit ({source_commit}) != provenance volatile.sourceCommit "
            f"({provenance_commit}); regenerate the provenance record from this "
            "checkout (build_provenance.py --write) before building"
        )

    pinned = provenance.get("pinned") or {}
    artifact_version = dict(build_provenance._app_version())
    if build_name is not None:
        artifact_version["version"] = str(build_name)
    if build_number is not None:
        artifact_version["buildNumber"] = int(build_number)

    return {
        "schemaVersion": SCHEMA_VERSION,
        "reportId": REPORT_ID,
        "kind": kind,
        "artifact": {
            "name": artifact_path.name,
            "sha256": hashlib.sha256(artifact_bytes).hexdigest(),
            "bytes": len(artifact_bytes),
        },
        "version": artifact_version,
        "sourceCommit": {
            "sha": source_commit,
            "subject": _git_subject(source_commit),
        },
        "provenance": {
            "path": str(provenance_file),
            "sha256": hashlib.sha256(provenance_bytes).hexdigest(),
            "pinnedFileCount": pinned.get("fileCount"),
            "sourceCommit": provenance_commit,
        },
        "buildEnvironment": _build_environment(),
        "generatedAt": datetime.now(timezone.utc).isoformat(timespec="seconds"),
    }


def verify_record(
    record: dict,
    artifact_path: Path,
    provenance_path: Path,
) -> list[str]:
    """Return a list of policy violations; empty means the artifact is traced."""
    errors: list[str] = []
    if not isinstance(record, dict):
        return ["record is not a JSON object"]
    if record.get("schemaVersion") != SCHEMA_VERSION:
        errors.append("schemaVersion mismatch")
    if record.get("reportId") != REPORT_ID:
        errors.append("reportId mismatch")
    if record.get("kind") not in KINDS:
        errors.append("kind mismatch")

    artifact = record.get("artifact") or {}
    if not artifact_path.is_file():
        errors.append(f"artifact missing: {artifact_path}")
    else:
        data = artifact_path.read_bytes()
        if artifact.get("sha256") != hashlib.sha256(data).hexdigest():
            errors.append("artifact checksum drift")
        if artifact.get("bytes") != len(data):
            errors.append("artifact size drift")

    version = record.get("version") or {}
    try:
        expected = build_provenance._app_version()
        drift = (
            version.get("name") != expected["name"]
            or version.get("version") != expected["version"]
            or version.get("buildNumber") != expected["buildNumber"]
        )
        if drift:
            errors.append("artifact version drift vs pubspec.yaml")
    except build_provenance.ProvenanceError as exc:
        errors.append(f"pubspec unreadable: {exc}")

    provenance_file = Path(provenance_path)
    if not provenance_file.is_file():
        errors.append(f"provenance record missing: {provenance_file}")
    else:
        provenance_bytes = provenance_file.read_bytes()
        provenance_meta = record.get("provenance") or {}
        if provenance_meta.get("sha256") != hashlib.sha256(provenance_bytes).hexdigest():
            errors.append("provenance record drift")
        try:
            provenance = json.loads(provenance_bytes)
        except json.JSONDecodeError:
            errors.append("provenance record malformed")
            provenance = {}
        if provenance:
            errors.extend(
                f"provenance invalid: {err}" for err in build_provenance.verify(provenance)
            )
            provenance_commit = str(provenance.get("volatile", {}).get("sourceCommit", ""))
            if provenance_commit != (record.get("sourceCommit") or {}).get("sha"):
                errors.append("sourceCommit != provenance volatile.sourceCommit")
            if provenance_meta.get("pinnedFileCount") != (
                (provenance.get("pinned") or {}).get("fileCount")
            ):
                errors.append("provenance pinnedFileCount drift")

    try:
        expected_commit = current_source_commit()
    except TraceabilityError as exc:
        errors.append(str(exc))
        expected_commit = None
    if expected_commit and (record.get("sourceCommit") or {}).get("sha") != expected_commit:
        errors.append("sourceCommit drift vs current checkout")

    return errors


def cmd_write(args: argparse.Namespace) -> int:
    record = build_record(
        artifact_path=Path(args.artifact),
        kind=args.kind,
        provenance_path=Path(args.provenance),
        build_name=args.build_name,
        build_number=args.build_number,
    )
    output = Path(args.output)
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(
        json.dumps(record, indent=2, sort_keys=True) + "\n", encoding="utf-8"
    )
    print(f"wrote {output} (artifact {record['artifact']['sha256']})")
    return 0


def cmd_check(args: argparse.Namespace) -> int:
    record_path = Path(args.record)
    if not record_path.is_file():
        print(f"FAIL: traceability record missing: {record_path}", file=sys.stderr)
        return 1
    try:
        record = json.loads(record_path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        print(f"FAIL: traceability record malformed: {exc}", file=sys.stderr)
        return 1
    errors = verify_record(record, Path(args.artifact), Path(args.provenance))
    if errors:
        for err in errors:
            print(f"FAIL: {err}", file=sys.stderr)
        return 1
    commit = (record.get("sourceCommit") or {}).get("sha", "unknown")
    print(
        f"OK: artifact traced to source commit {commit} "
        f"(sha256 {record['artifact']['sha256']}, kind {record['kind']})"
    )
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("--write", action="store_true", help="write the traceability record")
    group.add_argument("--check", action="store_true", help="verify; fail closed")
    parser.add_argument("--artifact", required=True, help="path to the APK/AAB artifact")
    parser.add_argument("--kind", choices=KINDS, default="apk")
    parser.add_argument("--provenance", default=str(DEFAULT_PROVENANCE))
    parser.add_argument("--output", default=str(DEFAULT_OUTPUT))
    parser.add_argument("--record", default=str(DEFAULT_OUTPUT))
    parser.add_argument("--build-name", default=None, help="override artifact version (AAB build flags)")
    parser.add_argument("--build-number", type=int, default=None, help="override artifact build number")
    args = parser.parse_args()
    try:
        return cmd_write(args) if args.write else cmd_check(args)
    except TraceabilityError as exc:
        print(f"FAIL: {exc}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    sys.exit(main())
