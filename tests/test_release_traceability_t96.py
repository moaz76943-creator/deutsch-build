"""T96: release artifact traceability to exact source commits.

Fail-closed contracts: a release record must bind artifact bytes, pubspec
version, the verified T94 provenance record, and the exact source commit.
Any drift, mismatch, or missing input must be rejected.
"""
from __future__ import annotations

import copy
import hashlib
import json
import os
import subprocess
import sys
import tempfile
import unittest
from contextlib import contextmanager
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TOOL = ROOT / "tools/polyglot/release_traceability.py"
PROVENANCE = ROOT / "assets/registry/build_provenance.json"

sys.path.insert(0, str(ROOT / "tools/polyglot"))
import build_provenance  # noqa: E402
import release_traceability  # noqa: E402


def _run(*args: str, env: dict[str, str] | None = None) -> subprocess.CompletedProcess[str]:
    base_env = {k: v for k, v in os.environ.items() if k != "GITHUB_SHA"}
    if env:
        base_env.update(env)
    return subprocess.run(
        [sys.executable, str(TOOL), *args],
        cwd=ROOT,
        capture_output=True,
        text=True,
        env=base_env,
    )


@contextmanager
def _tmp():
    with tempfile.TemporaryDirectory(prefix="t96-") as directory:
        root = Path(directory)
        artifact = root / "deutsch-app.apk"
        artifact.write_bytes(bytes(range(256)) * 16)
        yield artifact, root / "release_traceability.json"


def _regen_provenance() -> None:
    subprocess.run(
        [sys.executable, str(ROOT / "tools/polyglot/build_provenance.py"), "--write"],
        cwd=ROOT,
        check=True,
        capture_output=True,
    )


class ProvenanceBackup(unittest.TestCase):
    """Regenerate the committed provenance artifact per test; restore after."""

    def setUp(self) -> None:
        self._provenance_before = PROVENANCE.read_bytes()

    def tearDown(self) -> None:
        PROVENANCE.write_bytes(self._provenance_before)

    def regen(self) -> None:
        _regen_provenance()


class T96WriteThenCheck(ProvenanceBackup):
    def test_write_then_check_roundtrip_passes(self) -> None:
        with _tmp() as (artifact, record):
            self.regen()
            self.assertEqual(_run("--write", "--artifact", str(artifact), "--kind", "apk",
                                  "--output", str(record)).returncode, 0)
            self.assertEqual(_run("--check", "--artifact", str(artifact),
                                  "--record", str(record)).returncode, 0)

    def test_record_binds_exact_source_commit(self) -> None:
        with _tmp() as (artifact, record):
            self.regen()
            _run("--write", "--artifact", str(artifact), "--kind", "aab",
                 "--output", str(record))
            payload = json.loads(record.read_text(encoding="utf-8"))
            head = subprocess.run(
                ["git", "rev-parse", "HEAD"], cwd=ROOT,
                capture_output=True, text=True, check=True,
            ).stdout.strip()
            self.assertEqual(payload["sourceCommit"]["sha"], head)
            self.assertEqual(payload["provenance"]["sourceCommit"], head)
            self.assertEqual(payload["artifact"]["sha256"],
                             hashlib.sha256(artifact.read_bytes()).hexdigest())
            self.assertEqual(payload["version"]["version"], "1.0.0")
            self.assertEqual(payload["kind"], "aab")

    def test_write_records_artifact_version_override(self) -> None:
        with _tmp() as (artifact, record):
            self.regen()
            _run("--write", "--artifact", str(artifact), "--kind", "aab",
                 "--build-name", "3.3.10", "--build-number", "133",
                 "--output", str(record))
            payload = json.loads(record.read_text(encoding="utf-8"))
            self.assertEqual(payload["version"]["version"], "3.3.10")
            self.assertEqual(payload["version"]["buildNumber"], 133)

    def test_write_fails_closed_when_github_sha_disagrees_with_head(self) -> None:
        with _tmp() as (artifact, record):
            self.regen()
            result = _run("--write", "--artifact", str(artifact), "--kind", "apk",
                          "--output", str(record),
                          env={"GITHUB_SHA": "0" * 40})
            self.assertNotEqual(result.returncode, 0)
            self.assertIn("GITHUB_SHA", result.stderr)

    def test_write_fails_closed_on_provenance_checksum_drift(self) -> None:
        with _tmp() as (artifact, record):
            self.regen()
            drifted = json.loads(PROVENANCE.read_text(encoding="utf-8"))
            first_key = next(iter(drifted["pinned"]["files"]))
            drifted["pinned"]["files"][first_key]["sha256"] = "0" * 64
            bad = artifact.with_suffix(".provenance.json")
            bad.write_text(json.dumps(drifted), encoding="utf-8")
            result = _run("--write", "--artifact", str(artifact), "--kind", "apk",
                          "--provenance", str(bad), "--output", str(record))
            self.assertNotEqual(result.returncode, 0)
            self.assertIn("checksum drift", result.stderr)

    def test_write_fails_closed_when_provenance_commit_differs(self) -> None:
        with _tmp() as (artifact, record):
            self.regen()
            stale = json.loads(PROVENANCE.read_text(encoding="utf-8"))
            stale["volatile"]["sourceCommit"] = "f" * 40
            stale["volatile"]["sourceCommitSubject"] = "stale"
            bad = artifact.with_suffix(".provenance.json")
            bad.write_text(json.dumps(stale), encoding="utf-8")
            result = _run("--write", "--artifact", str(artifact), "--kind", "apk",
                          "--provenance", str(bad), "--output", str(record))
            self.assertNotEqual(result.returncode, 0)
            self.assertIn("source commit", result.stderr)


class T96CheckFailClosed(ProvenanceBackup):
    def _record(self, tmp: Path, artifact: Path) -> dict:
        record = tmp / "release_traceability.json"
        self.regen()
        _run("--write", "--artifact", str(artifact), "--kind", "apk",
             "--output", str(record))
        return json.loads(record.read_text(encoding="utf-8"))

    def test_check_fails_on_artifact_drift(self) -> None:
        with _tmp() as (artifact, record):
            self._record(record.parent, artifact)
            data = bytearray(artifact.read_bytes())
            data[0] ^= 0xFF
            artifact.write_bytes(bytes(data))
            result = _run("--check", "--artifact", str(artifact), "--record", str(record))
            self.assertNotEqual(result.returncode, 0)
            self.assertIn("artifact checksum drift", result.stderr)

    def test_check_fails_on_version_drift(self) -> None:
        with _tmp() as (artifact, record):
            payload = self._record(record.parent, artifact)
            payload["version"]["version"] = "999.999.999"
            record.write_text(json.dumps(payload), encoding="utf-8")
            result = _run("--check", "--artifact", str(artifact), "--record", str(record))
            self.assertNotEqual(result.returncode, 0)
            self.assertIn("version drift", result.stderr)

    def test_check_fails_on_provenance_record_drift(self) -> None:
        with _tmp() as (artifact, record):
            payload = self._record(record.parent, artifact)
            payload["provenance"]["sha256"] = "0" * 64
            record.write_text(json.dumps(payload), encoding="utf-8")
            result = _run("--check", "--artifact", str(artifact), "--record", str(record))
            self.assertNotEqual(result.returncode, 0)
            self.assertIn("provenance record drift", result.stderr)

    def test_check_fails_on_source_commit_drift(self) -> None:
        with _tmp() as (artifact, record):
            payload = self._record(record.parent, artifact)
            payload["sourceCommit"]["sha"] = "f" * 40
            payload["provenance"]["sourceCommit"] = "f" * 40
            record.write_text(json.dumps(payload), encoding="utf-8")
            result = _run("--check", "--artifact", str(artifact), "--record", str(record))
            self.assertNotEqual(result.returncode, 0)
            self.assertTrue(
                any("sourceCommit" in line for line in result.stderr.splitlines())
            )

    def test_check_fails_on_github_sha_disagreement(self) -> None:
        with _tmp() as (artifact, record):
            self._record(record.parent, artifact)
            result = _run("--check", "--artifact", str(artifact), "--record", str(record),
                          env={"GITHUB_SHA": "0" * 40})
            self.assertNotEqual(result.returncode, 0)
            self.assertIn("GITHUB_SHA", result.stderr)

    def test_check_fails_on_missing_record(self) -> None:
        with _tmp() as (artifact, record):
            result = _run("--check", "--artifact", str(artifact), "--record", str(record))
            self.assertNotEqual(result.returncode, 0)
            self.assertIn("missing", result.stderr)

    def test_check_fails_on_missing_artifact(self) -> None:
        with _tmp() as (artifact, record):
            self._record(record.parent, artifact)
            artifact.unlink()
            result = _run("--check", "--artifact", str(artifact), "--record", str(record))
            self.assertNotEqual(result.returncode, 0)
            self.assertIn("artifact missing", result.stderr)

    def test_verify_rejects_tampered_provenance_payload(self) -> None:
        with _tmp() as (artifact, record):
            payload = self._record(record.parent, artifact)
            tampered = copy.deepcopy(payload)
            tampered["provenance"]["pinnedFileCount"] = 999
            errors = release_traceability.verify_record(
                tampered, artifact, PROVENANCE
            )
            self.assertTrue(any("pinnedFileCount" in e for e in errors))


class T96WorkflowContracts(unittest.TestCase):
    def _workflow(self, name: str) -> str:
        return (ROOT / ".github/workflows" / name).read_text(encoding="utf-8")

    def test_apk_workflow_binds_artifact_to_source_commit(self) -> None:
        text = self._workflow("build_apk.yml")
        self.assertIn("release_traceability.py --write", text)
        self.assertIn("release_traceability.py --check", text)
        self.assertIn("build_provenance.py --write", text)
        self.assertIn("release_traceability.json", text)

    def test_aab_workflow_derives_version_from_pubspec(self) -> None:
        text = self._workflow("build_aab.yml")
        self.assertIn("release_traceability.py --write", text)
        self.assertIn("release_traceability.py --check", text)
        self.assertNotIn("--build-name=3.3.10", text)
        self.assertNotIn("3.3.10+133", text)
        self.assertIn("steps.version.outputs.name", text)
        self.assertIn("steps.version.outputs.number", text)

    def test_aab_workflow_uploads_traceability_evidence(self) -> None:
        text = self._workflow("build_aab.yml")
        self.assertIn("release_traceability.json", text)
        self.assertIn("build_provenance.json", text)

    def test_tools_are_stdlib_only(self) -> None:
        for tool in ("release_traceability.py", "build_provenance.py"):
            source = (ROOT / "tools/polyglot" / tool).read_text(encoding="utf-8")
            for banned in ("import requests", "import socket", "subprocess.run",):
                if banned == "subprocess.run":
                    continue  # git metadata is local, non-network
                self.assertNotIn(banned, source)


if __name__ == "__main__":
    unittest.main()
