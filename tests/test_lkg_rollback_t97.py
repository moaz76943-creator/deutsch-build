"""T97: safe rollback to the last known-good application and content-pack versions.

Fail-closed contracts: the LKG release record is promoted only from a
verified T96 traceability record, tampering with any bound field is
rejected, and the rollback plan is emitted only when the current release
fails verification (or is forced) and never as a no-op against itself.
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
TOOL = ROOT / "tools/polyglot/lkg_rollback.py"
TRACE_TOOL = ROOT / "tools/polyglot/release_traceability.py"
PROVENANCE = ROOT / "assets/registry/build_provenance.json"

sys.path.insert(0, str(ROOT / "tools/polyglot"))
import build_provenance  # noqa: E402
import lkg_rollback  # noqa: E402
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


def _run_trace(*args: str) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        [sys.executable, str(TRACE_TOOL), *args],
        cwd=ROOT,
        capture_output=True,
        text=True,
        env={k: v for k, v in os.environ.items() if k != "GITHUB_SHA"},
    )


@contextmanager
def _tmp():
    with tempfile.TemporaryDirectory(prefix="t97-") as directory:
        root = Path(directory)
        artifact = root / "deutsch-app.apk"
        artifact.write_bytes(bytes(range(256)) * 16)
        yield artifact, root / "release_traceability.json", root / "release_lkg.json"


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


class T97PromoteThenCheck(ProvenanceBackup):
    def _promote(self, artifact: Path, trace: Path, lkg: Path) -> subprocess.CompletedProcess[str]:
        self.regen()
        self.assertEqual(
            _run_trace("--write", "--artifact", str(artifact), "--kind", "apk",
                       "--output", str(trace)).returncode, 0)
        return _run("--promote", "--traceability", str(trace), "--artifact", str(artifact),
                    "--output", str(lkg), "--reason", "regression-free gold build")

    def test_promote_then_check_roundtrip_passes(self) -> None:
        with _tmp() as (artifact, trace, lkg):
            result = self._promote(artifact, trace, lkg)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertTrue(lkg.is_file())
            check = _run("--check", "--record", str(lkg))
            self.assertEqual(check.returncode, 0, check.stderr)
            self.assertIn("OK: LKG record valid", check.stdout)

    def test_promoted_record_binds_artifact_version_and_commit(self) -> None:
        with _tmp() as (artifact, trace, lkg):
            self._promote(artifact, trace, lkg)
            payload = json.loads(lkg.read_text(encoding="utf-8"))
            self.assertEqual(payload["reportId"], "polyglot-release-lkg")
            self.assertEqual(payload["kind"], "apk")
            self.assertEqual(payload["artifact"]["sha256"],
                             hashlib.sha256(artifact.read_bytes()).hexdigest())
            self.assertEqual(payload["artifact"]["bytes"], artifact.stat().st_size)
            self.assertEqual(payload["version"]["version"], "1.0.0")
            head = subprocess.run(
                ["git", "rev-parse", "HEAD"], cwd=ROOT,
                capture_output=True, text=True, check=True,
            ).stdout.strip()
            self.assertEqual(payload["sourceCommit"]["sha"], head)
            snapshot = payload["traceability"]["record"]
            snap_sha = hashlib.sha256(
                json.dumps(snapshot, sort_keys=True, separators=(",", ":")).encode("utf-8")
            ).hexdigest()
            self.assertEqual(payload["traceability"]["sha256"], snap_sha)

    def test_promote_writes_atomically_no_tmp_leftover(self) -> None:
        with _tmp() as (artifact, trace, lkg):
            self._promote(artifact, trace, lkg)
            leftovers = list(lkg.parent.glob(f".{lkg.name}.tmp.*"))
            self.assertEqual(leftovers, [])

    def test_promote_fails_closed_when_artifact_drifted(self) -> None:
        with _tmp() as (artifact, trace, lkg):
            self.regen()
            _run_trace("--write", "--artifact", str(artifact), "--kind", "apk",
                       "--output", str(trace))
            data = bytearray(artifact.read_bytes())
            data[0] ^= 0xFF
            artifact.write_bytes(bytes(data))
            result = _run("--promote", "--traceability", str(trace), "--artifact", str(artifact),
                          "--output", str(lkg))
            self.assertNotEqual(result.returncode, 0)
            self.assertIn("drift", result.stderr)
            self.assertFalse(lkg.exists())

    def test_promote_fails_closed_when_provenance_drifted(self) -> None:
        with _tmp() as (artifact, trace, lkg):
            self.regen()
            _run_trace("--write", "--artifact", str(artifact), "--kind", "apk",
                       "--output", str(trace))
            drifted = json.loads(PROVENANCE.read_text(encoding="utf-8"))
            first_key = next(iter(drifted["pinned"]["files"]))
            drifted["pinned"]["files"][first_key]["sha256"] = "0" * 64
            bad = artifact.with_suffix(".provenance.json")
            bad.write_text(json.dumps(drifted), encoding="utf-8")
            result = _run("--promote", "--traceability", str(trace), "--artifact", str(artifact),
                          "--provenance", str(bad), "--output", str(lkg))
            self.assertNotEqual(result.returncode, 0)
            self.assertFalse(lkg.exists())

    def test_promote_fails_closed_when_traceability_record_missing(self) -> None:
        with _tmp() as (artifact, trace, lkg):
            self.regen()
            result = _run("--promote", "--traceability", str(trace), "--artifact", str(artifact),
                          "--output", str(lkg))
            self.assertNotEqual(result.returncode, 0)
            self.assertIn("missing", result.stderr)
            self.assertFalse(lkg.exists())

    def test_promote_requires_artifact(self) -> None:
        result = _run("--promote", "--traceability", "x.json", "--output", "y.json")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("--artifact", result.stderr)


class T97CheckFailClosed(ProvenanceBackup):
    def _promote(self, tmp: Path, artifact: Path) -> dict:
        trace = tmp / "release_traceability.json"
        lkg = tmp / "release_lkg.json"
        self.regen()
        _run_trace("--write", "--artifact", str(artifact), "--kind", "apk",
                   "--output", str(trace))
        result = _run("--promote", "--traceability", str(trace), "--artifact", str(artifact),
                      "--output", str(lkg))
        self.assertEqual(result.returncode, 0, result.stderr)
        return json.loads(lkg.read_text(encoding="utf-8"))

    def test_check_without_artifact_verifies_record_only(self) -> None:
        with _tmp() as (artifact, trace, lkg):
            self._promote(lkg.parent, artifact)
            check = _run("--check", "--record", str(lkg))
            self.assertEqual(check.returncode, 0, check.stderr)

    def test_check_with_matching_artifact_passes(self) -> None:
        with _tmp() as (artifact, trace, lkg):
            self._promote(lkg.parent, artifact)
            check = _run("--check", "--record", str(lkg), "--artifact", str(artifact))
            self.assertEqual(check.returncode, 0, check.stderr)

    def test_check_fails_on_artifact_drift(self) -> None:
        with _tmp() as (artifact, trace, lkg):
            self._promote(lkg.parent, artifact)
            data = bytearray(artifact.read_bytes())
            data[5] ^= 0xFF
            artifact.write_bytes(bytes(data))
            check = _run("--check", "--record", str(lkg), "--artifact", str(artifact))
            self.assertNotEqual(check.returncode, 0)
            self.assertIn("artifact checksum drift", check.stderr)

    def test_check_fails_on_tampered_traceability_snapshot(self) -> None:
        with _tmp() as (artifact, trace, lkg):
            payload = self._promote(lkg.parent, artifact)
            payload["traceability"]["record"]["kind"] = "aab"
            lkg.write_text(json.dumps(payload), encoding="utf-8")
            check = _run("--check", "--record", str(lkg))
            self.assertNotEqual(check.returncode, 0)
            self.assertIn("traceability snapshot", check.stderr)

    def test_check_fails_on_unknown_source_commit(self) -> None:
        with _tmp() as (artifact, trace, lkg):
            payload = self._promote(lkg.parent, artifact)
            payload["sourceCommit"]["sha"] = "f" * 40
            payload["traceability"]["record"]["sourceCommit"]["sha"] = "f" * 40
            lkg.write_text(json.dumps(payload), encoding="utf-8")
            check = _run("--check", "--record", str(lkg))
            self.assertNotEqual(check.returncode, 0)
            self.assertIn("sourceCommit", check.stderr)

    def test_check_fails_on_schema_and_kind_tampering(self) -> None:
        with _tmp() as (artifact, trace, lkg):
            payload = self._promote(lkg.parent, artifact)
            payload["schemaVersion"] = 999
            lkg.write_text(json.dumps(payload), encoding="utf-8")
            check = _run("--check", "--record", str(lkg))
            self.assertNotEqual(check.returncode, 0)
            self.assertIn("schemaVersion", check.stderr)

    def test_check_fails_closed_on_missing_record(self) -> None:
        with _tmp() as (artifact, trace, lkg):
            check = _run("--check", "--record", str(lkg))
            self.assertNotEqual(check.returncode, 0)
            self.assertIn("missing", check.stderr)

    def test_check_allows_missing_record_only_with_flag(self) -> None:
        with _tmp() as (artifact, trace, lkg):
            skip = _run("--check", "--record", str(lkg), "--allow-missing")
            self.assertEqual(skip.returncode, 0, skip.stderr)
            self.assertIn("SKIP", skip.stdout)
            hard = _run("--check", "--record", str(lkg), "--require-artifact")
            self.assertNotEqual(hard.returncode, 0)

    def test_check_fails_closed_when_artifact_required_but_absent(self) -> None:
        with _tmp() as (artifact, trace, lkg):
            self._promote(lkg.parent, artifact)
            moved = artifact.with_name("elsewhere.apk")
            artifact.rename(moved)
            check = _run("--check", "--record", str(lkg), "--require-artifact")
            self.assertNotEqual(check.returncode, 0)
            self.assertIn("artifact missing", check.stderr)


class T97RollbackPlan(ProvenanceBackup):
    def _promote(self, tmp: Path, artifact: Path) -> dict:
        trace = tmp / "release_traceability.json"
        lkg = tmp / "release_lkg.json"
        self.regen()
        _run_trace("--write", "--artifact", str(artifact), "--kind", "apk",
                   "--output", str(trace))
        result = _run("--promote", "--traceability", str(trace), "--artifact", str(artifact),
                      "--output", str(lkg))
        self.assertEqual(result.returncode, 0, result.stderr)
        return json.loads(lkg.read_text(encoding="utf-8"))

    def test_plan_reports_no_rollback_when_current_verifies(self) -> None:
        with _tmp() as (artifact, trace, lkg):
            self._promote(lkg.parent, artifact)
            plan = _run("--plan", "--traceability", str(trace), "--artifact", str(artifact),
                        "--record", str(lkg))
            self.assertEqual(plan.returncode, 0, plan.stderr)
            payload = json.loads(plan.stdout)
            self.assertEqual(payload["decision"], "no-rollback-indicated")
            self.assertEqual(payload["current"]["verified"], True)

    def test_plan_emits_rollback_when_current_fails_verification(self) -> None:
        with _tmp() as (artifact, trace, lkg):
            self._promote(lkg.parent, artifact)
            data = bytearray(artifact.read_bytes())
            data[0] ^= 0xFF
            artifact.write_bytes(bytes(data))
            plan = _run("--plan", "--traceability", str(trace), "--artifact", str(artifact),
                        "--record", str(lkg))
            self.assertEqual(plan.returncode, 0, plan.stderr)
            payload = json.loads(plan.stdout)
            self.assertEqual(payload["decision"], "rollback")
            self.assertTrue(payload["current"]["errors"])
            self.assertEqual(payload["lastKnownGood"]["sha256"],
                             hashlib.sha256(bytes(range(256)) * 16).hexdigest())
            self.assertTrue(any("sha256" in step for step in payload["steps"]))

    def test_plan_refuses_noop_rollback_against_itself(self) -> None:
        with _tmp() as (artifact, trace, lkg):
            self._promote(lkg.parent, artifact)
            plan = _run("--plan", "--traceability", str(trace), "--artifact", str(artifact),
                        "--record", str(lkg), "--force")
            self.assertEqual(plan.returncode, 0, plan.stderr)
            payload = json.loads(plan.stdout)
            self.assertEqual(payload["decision"], "already-at-last-known-good")

    def test_plan_fails_closed_on_invalid_lkg_record(self) -> None:
        with _tmp() as (artifact, trace, lkg):
            self._promote(lkg.parent, artifact)
            payload = json.loads(lkg.read_text(encoding="utf-8"))
            payload["artifact"]["sha256"] = "0" * 64
            lkg.write_text(json.dumps(payload), encoding="utf-8")
            plan = _run("--plan", "--traceability", str(trace), "--artifact", str(artifact),
                        "--record", str(lkg))
            self.assertNotEqual(plan.returncode, 0)
            self.assertIn("refusing", plan.stderr)

    def test_plan_fails_closed_when_lkg_record_missing(self) -> None:
        with _tmp() as (artifact, trace, lkg):
            plan = _run("--plan", "--traceability", str(trace), "--artifact", str(artifact),
                        "--record", str(lkg))
            self.assertNotEqual(plan.returncode, 0)
            self.assertIn("missing", plan.stderr)

    def test_plan_requires_artifact(self) -> None:
        with _tmp() as (artifact, trace, lkg):
            plan = _run("--plan", "--traceability", str(trace), "--record", str(lkg))
            self.assertNotEqual(plan.returncode, 0)
            self.assertIn("--artifact", plan.stderr)


class T97WorkflowContracts(unittest.TestCase):
    def _workflow(self, name: str) -> str:
        return (ROOT / ".github/workflows" / name).read_text(encoding="utf-8")

    def test_apk_workflow_promotes_lkg_after_traceability(self) -> None:
        text = self._workflow("build_apk.yml")
        self.assertIn("lkg_rollback.py --promote", text)
        self.assertIn("release_lkg.json", text)

    def test_aab_workflow_promotes_lkg_after_traceability(self) -> None:
        text = self._workflow("build_aab.yml")
        self.assertIn("lkg_rollback.py --promote", text)
        self.assertIn("release_lkg.json", text)

    def test_tool_is_stdlib_only_and_no_network(self) -> None:
        source = (ROOT / "tools/polyglot" / "lkg_rollback.py").read_text(encoding="utf-8")
        for banned in ("import requests", "import socket", "urllib", "subprocess.Popen"):
            self.assertNotIn(banned, source)
        self.assertIn("subprocess.run", source)  # local git metadata only

    def test_pack_side_lkg_still_present(self) -> None:
        """T68 pack-side last-known-good must not regress while app-side lands."""
        installer = (ROOT / "lib/core/storage/atomic_database_installer.dart").read_text(
            encoding="utf-8")
        self.assertIn("lastknowngood", installer)


if __name__ == "__main__":
    unittest.main()
