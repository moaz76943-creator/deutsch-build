#!/usr/bin/env python3
"""T97: safe rollback to the last known-good application and content-pack versions.

T68 (merged) ships the pack-side half: the installer backs up the active
pack to ``<target>.lastknowngood`` before atomic replacement and restores it
on failure. This tool ships the application-side half: a *fail-closed*
last-known-good (LKG) release record, promoted only after the T96 traceability
record for the exact artifact verifies, plus a rollback plan emitter.

What it does
------------
* ``--promote``: bind the verified T96 release artifact (APK/AAB) into
  ``release-metadata/release_lkg.json`` (or ``--output``). The traceability
  record is re-verified against the actual artifact, the committed T94
  provenance record and the current checkout — any drift fails closed and
  nothing is promoted.
* ``--check``: verify an LKG record — structure, embedded-traceability
  snapshot integrity (SHA-256), internal consistency, and that the recorded
  source commit exists in this repository. With ``--artifact`` the artifact
  bytes are re-hashed. With ``--require-artifact`` a missing artifact fails
  closed. Without ``--require-artifact`` and without ``--artifact`` the check
  verifies the *record* only (the artifact bytes live in the release system,
  not the git tree).
* ``--plan``: given the *current* release traceability record and the LKG
  record, emit a JSON rollback plan (re-publish the LKG artifact pinned by
  SHA-256, rebuild from the LKG source commit, verify). Refuses to roll back
  when the current release verifies clean (and ``--force`` is not passed),
  when the LKG record is invalid, or when the LKG artifact is byte-identical
  to the current one (already the LKG build — rollback would be a no-op).

Exit codes: 0 ok, 1 fail-closed (reasons printed), 2 usage/environment error.

This tool never prints secret material, never touches the network, and reads
only the local tree and non-secret CI environment variables. Publishing a
rollback (release re-publication, Play Store promotion) is an explicit,
owner-authorized action performed outside this tool.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
DEFAULT_TRACEABILITY = REPO_ROOT / "release-metadata" / "release_traceability.json"
DEFAULT_OUTPUT = REPO_ROOT / "release-metadata" / "release_lkg.json"
DEFAULT_PROVENANCE = REPO_ROOT / "assets/registry" / "build_provenance.json"

sys.path.insert(0, str(Path(__file__).resolve().parent))
import build_provenance  # noqa: E402
import release_traceability  # noqa: E402

SCHEMA_VERSION = 1
REPORT_ID = "polyglot-release-lkg"
KINDS = ("apk", "aab")


class RollbackError(Exception):
    pass


def _sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1 << 20), b""):
            digest.update(chunk)
    return digest.hexdigest()


def _canonical_bytes(payload) -> bytes:
    return json.dumps(payload, sort_keys=True, separators=(",", ":")).encode("utf-8")


def _git_commit_exists(commit: str) -> bool:
    result = subprocess.run(
        ["git", "cat-file", "-e", f"{commit}^{{commit}}"],
        cwd=REPO_ROOT,
        capture_output=True,
        check=False,
    )
    return result.returncode == 0


def _load_json(path: Path, what: str):
    if not path.is_file():
        raise RollbackError(f"{what} missing: {path}")
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        raise RollbackError(f"{what} malformed: {exc}") from exc


def build_lkg_record(
    traceability_path: Path,
    artifact_path: Path,
    provenance_path: Path,
    reason: str | None = None,
) -> dict:
    traceability_path = Path(traceability_path)
    artifact_path = Path(artifact_path)
    provenance_path = Path(provenance_path)

    trace = _load_json(traceability_path, "traceability record")
    if not isinstance(trace, dict):
        raise RollbackError("traceability record is not a JSON object")

    # The artifact must verify against its T96 record *and* the committed T94
    # provenance record before it can be certified last-known-good.
    errors = release_traceability.verify_record(trace, artifact_path, provenance_path)
    if errors:
        raise RollbackError("traceability verification failed: " + "; ".join(errors))

    kind = trace.get("kind")
    if kind not in KINDS:
        raise RollbackError(f"traceability kind invalid: {kind!r}")

    source = trace.get("sourceCommit") or {}
    artifact = trace.get("artifact") or {}
    version = trace.get("version") or {}

    record = {
        "schemaVersion": SCHEMA_VERSION,
        "reportId": REPORT_ID,
        "kind": kind,
        "artifact": {
            "name": artifact.get("name"),
            "sha256": artifact.get("sha256"),
            "bytes": artifact.get("bytes"),
        },
        "version": dict(version),
        "sourceCommit": {
            "sha": source.get("sha"),
            "subject": source.get("subject"),
        },
        "traceability": {
            "path": str(traceability_path),
            "sha256": hashlib.sha256(_canonical_bytes(trace)).hexdigest(),
            "record": trace,
        },
        "reason": (reason or "promoted after verified release build").strip(),
        "promotedAt": datetime.now(timezone.utc).isoformat(timespec="seconds"),
        "promotedBy": {
            "workflow": os.environ.get("GITHUB_WORKFLOW", "local"),
            "runId": os.environ.get("GITHUB_RUN_ID", ""),
        },
    }
    # Fail closed: refuse to write a record we cannot verify ourselves.
    self_errors = verify_lkg(record, artifact_path=artifact_path, require_artifact=True)
    if self_errors:
        raise RollbackError("refusing to promote unverifiable record: " + "; ".join(self_errors))
    return record


def verify_lkg(
    record,
    artifact_path: Path | None = None,
    require_artifact: bool = False,
) -> list[str]:
    """Return policy violations; empty means the LKG record is trustworthy."""
    errors: list[str] = []
    if not isinstance(record, dict):
        return ["record is not a JSON object"]
    if record.get("schemaVersion") != SCHEMA_VERSION:
        errors.append("schemaVersion mismatch")
    if record.get("reportId") != REPORT_ID:
        errors.append("reportId mismatch")
    kind = record.get("kind")
    if kind not in KINDS:
        errors.append("kind mismatch")

    artifact = record.get("artifact") or {}
    sha = artifact.get("sha256")
    size = artifact.get("bytes")
    if not isinstance(sha, str) or len(sha) != 64 or any(c not in "0123456789abcdef" for c in sha):
        errors.append("artifact.sha256 missing or malformed")
    if not isinstance(size, int) or size <= 0:
        errors.append("artifact.bytes missing or invalid")

    version = record.get("version") or {}
    for field in ("name", "version"):
        if not version.get(field):
            errors.append(f"version.{field} missing")
    if not isinstance(version.get("buildNumber"), int):
        errors.append("version.buildNumber missing or not an integer")

    source = record.get("sourceCommit") or {}
    commit = source.get("sha")
    if not isinstance(commit, str) or len(commit) != 40 or any(c not in "0123456789abcdef" for c in commit):
        errors.append("sourceCommit.sha missing or malformed")
        commit = None
    elif not _git_commit_exists(commit):
        errors.append("sourceCommit does not exist in this repository")

    traceability = record.get("traceability") or {}
    snapshot = traceability.get("record")
    if snapshot is None:
        errors.append("traceability.record snapshot missing")
    else:
        snapshot_sha = hashlib.sha256(_canonical_bytes(snapshot)).hexdigest()
        if traceability.get("sha256") != snapshot_sha:
            errors.append("traceability snapshot checksum mismatch")
        snap_artifact = (snapshot or {}).get("artifact") or {}
        if snap_artifact.get("sha256") != sha:
            errors.append("traceability snapshot artifact sha256 inconsistent")
        if snap_artifact.get("bytes") != size:
            errors.append("traceability snapshot artifact bytes inconsistent")
        if (snapshot or {}).get("kind") != kind:
            errors.append("traceability snapshot kind inconsistent")
        snap_source = (snapshot or {}).get("sourceCommit") or {}
        if snap_source.get("sha") != commit:
            errors.append("traceability snapshot sourceCommit inconsistent")

    candidate = artifact_path
    if candidate is None and require_artifact:
        name = artifact.get("name")
        candidate = Path(name) if name else None
        if candidate is None:
            errors.append("require-artifact set but record has no artifact name")
    if candidate is not None:
        candidate = Path(candidate)
        if not candidate.is_file():
            errors.append(f"artifact missing: {candidate}")
        else:
            data = candidate.read_bytes()
            if hashlib.sha256(data).hexdigest() != sha:
                errors.append("artifact checksum drift vs LKG record")
            if len(data) != size:
                errors.append("artifact size drift vs LKG record")

    return errors


def cmd_promote(args: argparse.Namespace) -> int:
    record = build_lkg_record(
        traceability_path=Path(args.traceability),
        artifact_path=Path(args.artifact),
        provenance_path=Path(args.provenance),
        reason=args.reason,
    )
    output = Path(args.output)
    output.parent.mkdir(parents=True, exist_ok=True)
    tmp = output.with_name(f".{output.name}.tmp.{os.getpid()}")
    tmp.write_text(json.dumps(record, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    os.replace(tmp, output)  # atomic: readers never see a partial LKG record
    print(
        f"promoted {output} (artifact {record['artifact']['sha256']}, "
        f"source commit {record['sourceCommit']['sha']})"
    )
    return 0


def cmd_check(args: argparse.Namespace) -> int:
    record_path = Path(args.record)
    if not record_path.is_file():
        if args.allow_missing:
            print(f"SKIP: no LKG record at {record_path} (nothing promoted yet)")
            return 0
        print(f"FAIL: LKG record missing: {record_path}", file=sys.stderr)
        return 1
    try:
        record = json.loads(record_path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        print(f"FAIL: LKG record malformed: {exc}", file=sys.stderr)
        return 1
    artifact = Path(args.artifact) if args.artifact else None
    errors = verify_lkg(record, artifact_path=artifact, require_artifact=args.require_artifact)
    if errors:
        for err in errors:
            print(f"FAIL: {err}", file=sys.stderr)
        return 1
    commit = (record.get("sourceCommit") or {}).get("sha", "unknown")
    print(
        f"OK: LKG record valid (artifact {record['artifact']['sha256']}, "
        f"source commit {commit}, version {record['version'].get('version')})"
    )
    return 0


def cmd_plan(args: argparse.Namespace) -> int:
    record_path = Path(args.record)
    if not record_path.is_file():
        print(f"FAIL: LKG record missing: {record_path}", file=sys.stderr)
        return 1
    try:
        lkg = json.loads(record_path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        print(f"FAIL: LKG record malformed: {exc}", file=sys.stderr)
        return 1
    lkg_errors = verify_lkg(lkg)
    if lkg_errors:
        print("FAIL: LKG record invalid; refusing to plan a rollback", file=sys.stderr)
        for err in lkg_errors:
            print(f"FAIL: {err}", file=sys.stderr)
        return 1

    trace = _load_json(Path(args.traceability), "current traceability record")
    artifact = Path(args.artifact)
    current_errors = release_traceability.verify_record(
        trace, artifact, Path(args.provenance)
    )
    lkg_sha = lkg["artifact"]["sha256"]
    # Compare the bytes actually on disk, not the record's claimed sha: a
    # drifted artifact fails verification yet still "claims" the LKG digest.
    actual_sha = _sha256_file(artifact) if artifact.is_file() else None
    current_sha = actual_sha or ((trace or {}).get("artifact") or {}).get("sha256")
    plan = {
        "schemaVersion": SCHEMA_VERSION,
        "reportId": "polyglot-release-rollback-plan",
        "decision": None,
        "current": {
            "artifact": str(artifact),
            "sha256": current_sha,
            "verified": not current_errors,
            "errors": current_errors,
        },
        "lastKnownGood": {
            "kind": lkg["kind"],
            "artifactName": lkg["artifact"]["name"],
            "sha256": lkg_sha,
            "bytes": lkg["artifact"]["bytes"],
            "version": lkg["version"],
            "sourceCommit": lkg["sourceCommit"],
            "traceabilitySnapshotSha256": lkg["traceability"]["sha256"],
        },
        "steps": [
            f"fetch the LKG artifact whose SHA-256 is {lkg_sha} (release assets / CI artifacts)",
            "verify it byte-for-byte: sha256sum -c against the LKG record artifact.sha256",
            f"re-publish it: re-run the release workflow at source commit {lkg['sourceCommit']['sha']} or promote the stored artifact with allowUpdates",
            "verify the re-published artifact with release_traceability.py --check",
            "rebuild content packs from the LKG source commit if any pack changed since it",
        ],
    }
    if current_errors or args.force:
        if current_sha == lkg_sha:
            plan["decision"] = "already-at-last-known-good"
            plan["note"] = "current artifact is byte-identical to the LKG record; rollback is a no-op"
        else:
            plan["decision"] = "rollback"
            plan["reason"] = (
                "current release failed verification" if current_errors
                else "forced by operator (--force)"
            )
    else:
        plan["decision"] = "no-rollback-indicated"
        plan["note"] = "current release verifies clean; pass --force to emit a rollback plan anyway"
    json.dump(plan, sys.stdout, indent=2, sort_keys=True)
    sys.stdout.write("\n")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("--promote", action="store_true", help="certify the verified artifact as last-known-good")
    group.add_argument("--check", action="store_true", help="verify an LKG record; fail closed")
    group.add_argument("--plan", action="store_true", help="emit a JSON rollback plan vs the LKG record")
    parser.add_argument("--traceability", default=str(DEFAULT_TRACEABILITY),
                        help="T96 traceability record (promote/plan)")
    parser.add_argument("--provenance", default=str(DEFAULT_PROVENANCE))
    parser.add_argument("--artifact", default=None,
                        help="path to the APK/AAB artifact (promote/plan; optional for --check)")
    parser.add_argument("--record", default=str(DEFAULT_OUTPUT),
                        help="LKG record path (check/plan; promote writes here)")
    parser.add_argument("--output", default=str(DEFAULT_OUTPUT),
                        help="where --promote writes the LKG record")
    parser.add_argument("--require-artifact", action="store_true",
                        help="--check: fail closed when the artifact bytes are absent")
    parser.add_argument("--allow-missing", action="store_true",
                        help="--check: exit 0 with a SKIP note when no LKG record exists yet")
    parser.add_argument("--reason", default=None, help="why this build is last-known-good")
    parser.add_argument("--force", action="store_true",
                        help="--plan: emit a rollback plan even when the current release verifies")
    args = parser.parse_args()
    try:
        if args.promote:
            if not args.artifact:
                raise RollbackError("--promote requires --artifact")
            return cmd_promote(args)
        if args.check:
            return cmd_check(args)
        if not args.artifact:
            raise RollbackError("--plan requires --artifact")
        return cmd_plan(args)
    except RollbackError as exc:
        print(f"FAIL: {exc}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    sys.exit(main())
