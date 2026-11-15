"""T40 contracts: registration is reported separately from content-complete
and production-ready status (tools/polyglot/registry_sync.py readiness report).

Run: PYTHONPATH=. pytest tests/test_registry_readiness_t40.py
"""

from __future__ import annotations

import importlib.util
import json
import subprocess
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
TOOL = REPO_ROOT / "tools" / "polyglot" / "registry_sync.py"
REPORT = REPO_ROOT / "assets" / "registry" / "readiness_report.json"
ARTIFACT = REPO_ROOT / "assets" / "registry" / "languages_100.json"

spec = importlib.util.spec_from_file_location("registry_sync", TOOL)
assert spec is not None and spec.loader is not None
registry_sync = importlib.util.module_from_spec(spec)
spec.loader.exec_module(registry_sync)


def _artifact() -> dict:
    return json.loads(ARTIFACT.read_text(encoding="utf-8"))


def _report() -> dict:
    return json.loads(REPORT.read_text(encoding="utf-8"))


def test_check_exit_zero_and_names_report():
    result = subprocess.run(
        [sys.executable, str(TOOL), "--check"],
        cwd=REPO_ROOT,
        capture_output=True,
        text=True,
    )
    assert result.returncode == 0, result.stdout + result.stderr
    assert "readiness" in result.stdout.lower() or "OK:" in result.stdout


def test_report_counts_match_artifact_per_state():
    artifact = _artifact()
    report = _report()
    for state in ("registered", "sourceApproved", "productionReady"):
        expected = sorted(
            language["id"]
            for language in artifact["languages"]
            if language["readiness"] == state
        )
        assert report["readinessCounts"][state] == len(expected)
        if state in ("sourceApproved", "productionReady"):
            assert report[state]["languages"] == expected
    # registration section lists every registry member, not just one readiness state
    assert report["registration"]["languages"] == sorted(
        language["id"] for language in artifact["languages"]
    )
    assert report["registration"]["registeredLanguageCount"] == len(artifact["languages"])


def test_registration_is_exactly_100_and_excludes_hebrew():
    report = _report()
    ids = report["registration"]["languages"]
    assert len(ids) == 100
    assert len(set(ids)) == 100
    assert "he" not in ids and "iw" not in ids
    assert set(report["registration"]["excludedLanguageIds"]) == {"he", "iw"}


def test_content_complete_not_inferred_from_registration():
    report = _report()
    assert report["contentComplete"]["derived"] is False
    assert report["contentComplete"]["languages"] == []
    # registration and production readiness must be separate, non-identical sets
    registered = set(report["registration"]["languages"])
    production = set(report["productionReady"]["languages"])
    assert production < registered
    assert len(registered) == report["registration"]["registeredLanguageCount"] == 100
    assert report["readinessCounts"]["registered"] == 98
    assert report["readinessCounts"]["productionReady"] == len(production)


def test_report_is_deterministic():
    artifact = _artifact()
    first = registry_sync.build_readiness_report(artifact)
    second = registry_sync.build_readiness_report(artifact)
    assert first == second
    assert REPORT.read_text(encoding="utf-8") == json.dumps(
        first, ensure_ascii=False, indent=2, sort_keys=True
    ) + "\n"


def test_check_fails_when_report_is_stale(monkeypatch, tmp_path):
    artifact = _artifact()
    stale = registry_sync.build_readiness_report(artifact)
    stale["readinessCounts"]["registered"] = 0  # drift the copy
    stale_path = tmp_path / "readiness_report.json"
    stale_path.write_text(
        json.dumps(stale, ensure_ascii=False, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )
    monkeypatch.setattr(registry_sync, "READINESS_REPORT", stale_path)
    assert registry_sync.main(["--check"]) == 1


def test_check_fails_when_report_missing(monkeypatch, tmp_path):
    monkeypatch.setattr(registry_sync, "READINESS_REPORT", tmp_path / "absent.json")
    assert registry_sync.main(["--check"]) == 1


def test_write_regenerates_report(monkeypatch, tmp_path):
    artifact_path = tmp_path / "languages_100.json"
    report_path = tmp_path / "readiness_report.json"
    monkeypatch.setattr(registry_sync, "JSON_REGISTRY", artifact_path)
    monkeypatch.setattr(registry_sync, "READINESS_REPORT", report_path)
    monkeypatch.setattr(
        registry_sync, "REPO_ROOT", tmp_path
    )  # _sync_pack_stubs: no assets/languages dir -> FAIL path, writes still happen
    assert registry_sync.main(["--write"]) == 1  # stub dir missing in tmp tree
    written = json.loads(report_path.read_text(encoding="utf-8"))
    assert written["readinessCounts"]["registered"] == 98
    assert written["readinessCounts"]["productionReady"] == 2
    assert written["contentComplete"]["derived"] is False
