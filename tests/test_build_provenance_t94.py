"""T94: build artifact provenance (source SHA, environment, version, checksums).

The provenance artifact must pin exact SHA-256 checksums of build inputs,
record version + source commit + build environment, and --check must fail
closed on any drift, missing file, or malformed record.
"""
from __future__ import annotations

import copy
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TOOL = ROOT / "tools/polyglot/build_provenance.py"
ARTIFACT = ROOT / "assets/registry/build_provenance.json"

sys.path.insert(0, str(ROOT / "tools/polyglot"))
import build_provenance  # noqa: E402


def _run(*args: str) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        [sys.executable, str(TOOL), *args],
        cwd=ROOT,
        capture_output=True,
        text=True,
    )


def test_check_exits_zero_on_clean_tree() -> None:
    result = _run("--check")
    assert result.returncode == 0, result.stdout + result.stderr


def test_artifact_schema_version_and_identity() -> None:
    payload = json.loads(ARTIFACT.read_text(encoding="utf-8"))
    assert payload["schemaVersion"] == 1
    assert payload["reportId"] == "polyglot-build-provenance"
    assert payload["version"]["name"] == "deutsch_bilarabi"
    assert payload["version"]["version"] == "1.0.0"
    assert payload["version"]["buildNumber"] == 1


def test_pinned_checksums_match_tree_bytes() -> None:
    payload = json.loads(ARTIFACT.read_text(encoding="utf-8"))
    files = payload["pinned"]["files"]
    assert payload["pinned"]["fileCount"] == len(files) > 0
    for rel, entry in files.items():
        data = (ROOT / rel).read_bytes()
        assert hashlib.sha256(data).hexdigest() == entry["sha256"], rel
        assert entry["bytes"] == len(data), rel


def test_volatile_records_source_commit_and_environment() -> None:
    payload = json.loads(ARTIFACT.read_text(encoding="utf-8"))
    volatile = payload["volatile"]
    assert len(str(volatile["sourceCommit"])) == 40
    assert volatile["sourceCommitSubject"]
    env = volatile["buildEnvironment"]
    assert env["pythonVersion"]
    assert env["osName"]


def test_verify_fails_closed_on_checksum_drift() -> None:
    payload = json.loads(ARTIFACT.read_text(encoding="utf-8"))
    tampered = copy.deepcopy(payload)
    first_key = next(iter(tampered["pinned"]["files"]))
    tampered["pinned"]["files"][first_key]["sha256"] = "0" * 64
    errors = build_provenance.verify(tampered)
    assert any("checksum drift" in e for e in errors)


def test_verify_fails_closed_on_missing_file_entry() -> None:
    payload = json.loads(ARTIFACT.read_text(encoding="utf-8"))
    tampered = copy.deepcopy(payload)
    del tampered["pinned"]["files"]["pubspec.yaml"]
    errors = build_provenance.verify(tampered)
    assert any("missing" in e for e in errors)


def test_verify_fails_closed_on_missing_source_commit() -> None:
    payload = json.loads(ARTIFACT.read_text(encoding="utf-8"))
    tampered = copy.deepcopy(payload)
    tampered["volatile"]["sourceCommit"] = ""
    errors = build_provenance.verify(tampered)
    assert any("sourceCommit" in e for e in errors)


def test_verify_fails_closed_on_version_drift() -> None:
    payload = json.loads(ARTIFACT.read_text(encoding="utf-8"))
    tampered = copy.deepcopy(payload)
    tampered["version"]["version"] = "999.999.999"
    errors = build_provenance.verify(tampered)
    assert any("version drift" in e for e in errors)


def test_verify_fails_closed_on_malformed_digest_shape() -> None:
    payload = json.loads(ARTIFACT.read_text(encoding="utf-8"))
    tampered = copy.deepcopy(payload)
    first_key = next(iter(tampered["pinned"]["files"]))
    tampered["pinned"]["files"][first_key]["sha256"] = "not-a-digest"
    errors = build_provenance.verify(tampered)
    assert any("malformed" in e for e in errors)


def test_write_then_check_roundtrip_is_stable() -> None:
    before = ARTIFACT.read_text(encoding="utf-8")
    try:
        assert _run("--write").returncode == 0
        after = ARTIFACT.read_text(encoding="utf-8")
        b, a = json.loads(before), json.loads(after)
        # pinned + version sections are deterministic; volatile (timestamp,
        # sourceCommit, environment) is descriptive only and moves with HEAD.
        assert a["pinned"] == b["pinned"]
        assert a["version"] == b["version"]
        assert a["volatile"]["buildEnvironment"]
        assert _run("--check").returncode == 0
    finally:
        ARTIFACT.write_text(before, encoding="utf-8")
    assert _run("--check").returncode == 0
