"""T71: measured, provenance-backed content inventory.

The inventory measures ONLY content units that exist as files in the repo.
It must never overclaim: no production-readiness derivation, no invented
counts, excluded product languages never reported, and --check fails closed
on drift.
"""
from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TOOL = ROOT / "tools/polyglot/content_inventory.py"
ARTIFACT = ROOT / "assets/registry/content_inventory.json"
EXCLUDED = {"he", "iw", "syc", "ber", "zgh"}


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


def test_inventory_schema_and_no_excluded_languages() -> None:
    payload = json.loads(ARTIFACT.read_text(encoding="utf-8"))
    assert payload["schemaVersion"] == 1
    assert payload["reportId"] == "polyglot-content-inventory"
    assert EXCLUDED.isdisjoint(payload["languages"].keys())
    assert payload["totals"]["entries"] == sum(
        data["entries"] for data in payload["languages"].values()
    )


def test_inventory_matches_file_level_counts() -> None:
    payload = json.loads(ARTIFACT.read_text(encoding="utf-8"))
    en = 0
    for f in (ROOT / "assets/lexicon/languages_corpus").glob(
            "english_sentences_r*.json"):
        en += len(json.loads(f.read_text(encoding="utf-8")))
    for f in (ROOT / "assets/lexicon/languages_corpus").glob(
            "english_verbs_r*.json"):
        en += len(json.loads(f.read_text(encoding="utf-8")))
    en += len(json.loads(
        (ROOT / "assets/lexicon/100_languages/en_arabic_verified.json")
        .read_text(encoding="utf-8")
    ))
    en += len(json.loads(
        (ROOT / "assets/lexicon/offline_dictionaries"
         "/english_arabic_professional_lexicon.json")
        .read_text(encoding="utf-8")
    ))
    assert payload["languages"]["en"]["entries"] == en


def test_report_prints_honest_totals() -> None:
    result = _run("--report")
    assert result.returncode == 0
    assert "languages_with_content=27" in result.stdout
    assert "entries=" in result.stdout


def test_artifact_note_forbids_readiness_inference() -> None:
    payload = json.loads(ARTIFACT.read_text(encoding="utf-8"))
    assert "NOT a production-readiness" in payload["note"]
    assert "productionReady" not in payload
    assert "sourceApproved" not in payload
