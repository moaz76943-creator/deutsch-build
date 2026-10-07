from __future__ import annotations

import importlib.util
import json
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]
TOOL = ROOT / "tool" / "task13_wave_execution.py"
CONTRACT = ROOT / "tool" / "task13_wave_contract.json"
PAIRS = ROOT / "assets" / "local_language_databases" / "task13_directed_pairs.json"


def _load_module():
    spec = importlib.util.spec_from_file_location("task13_wave_execution", TOOL)
    assert spec is not None and spec.loader is not None
    module = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module


def test_task13_end_to_end_contract_passes():
    result = subprocess.run(
        [sys.executable, str(TOOL), "check"],
        cwd=ROOT,
        text=True,
        capture_output=True,
        check=False,
        timeout=30,
    )
    assert result.returncode == 0, result.stderr or result.stdout
    assert "TASK 13 WAVES 2-4: PASS" in result.stdout
    assert "WAVE2_CANDIDATE_QUARANTINE: PASS" in result.stdout
    assert "WAVE3_CANDIDATE_QUARANTINE: PASS" in result.stdout
    assert "WAVE4_CANDIDATE_QUARANTINE: PASS" in result.stdout
    assert "ONE_WAVE_AHEAD_PREP: PASS" in result.stdout
    assert "DIRECTED_PAIR_DERIVATION: PASS" in result.stdout
    assert "CANDIDATE_CARDS: 224" in result.stdout
    assert "CANONICAL_PROMOTIONS: 0" in result.stdout


def test_roadmap_language_assignments_are_exact():
    contract = json.loads(CONTRACT.read_text(encoding="utf-8"))
    assert contract["waves"]["2"]["languages"] == ["es", "fr", "it", "pt", "nl"]
    assert contract["waves"]["3"]["languages"] == ["tr", "pl", "sv", "el", "id"]
    assert contract["waves"]["4"]["languages"] == ["ja", "ko", "fa", "ur"]
    assert contract["waves"]["2"]["next_wave_prep"] == 3
    assert contract["waves"]["3"]["next_wave_prep"] == 4
    assert contract["waves"]["4"]["next_wave_prep"] is None


def test_wave3_and_wave4_sources_remain_candidate_only():
    for wave, languages in {
        3: ["tr", "pl", "sv", "el", "id"],
        4: ["ja", "ko", "fa", "ur"],
    }.items():
        for language in languages:
            source = json.loads(
                (
                    ROOT
                    / "assets"
                    / "local_language_databases"
                    / f"wave{wave}"
                    / "source"
                    / f"{language}.json"
                ).read_text(encoding="utf-8")
            )
            assert len(source["cards"]) == 16
            for card in source["cards"]:
                metadata = card["metadata"]
                assert metadata["reviewStatus"] == "pending"
                assert metadata["culturalReview"] == "pending"
                assert metadata["provenanceStatus"] == "pending-qualified-review"
                assert metadata["origin"] == f"task13-wave{wave}-local-agent-candidate"


def test_directed_pairs_are_explicit_asymmetric_candidates():
    payload = json.loads(PAIRS.read_text(encoding="utf-8"))
    rows = payload["pairs"]
    assert len(rows) == 28
    assert payload["canonicalPromotions"] == []
    ids = {row["id"] for row in rows}
    assert len(ids) == 28
    for row in rows:
        reverse = f'{row["targetLanguage"]}->{row["sourceLanguage"]}'
        assert reverse in ids
        assert row["status"] == "CANDIDATE_DERIVED"
        assert row["canonical"] is False
        assert row["reverseReadinessInherited"] is False
        assert row["pivotAllowed"] is False


def test_candidate_cannot_be_promoted_without_complete_evidence():
    module = _load_module()
    contract = module.load_contract()
    required = contract["canonical_promotion_required_evidence"]
    blocked = module.assess_canonical_promotion(
        {key: True for key in required if key != "qualified_linguistic_review"},
        contract=contract,
    )
    allowed = module.assess_canonical_promotion(
        {key: True for key in required},
        contract=contract,
    )
    assert blocked.allowed is False
    assert "qualified_linguistic_review" in blocked.missing_evidence
    assert allowed.allowed is True
    assert allowed.missing_evidence == ()


def test_task13_surfaces_stay_under_line_ceiling():
    contract = json.loads(CONTRACT.read_text(encoding="utf-8"))
    dynamic = []
    for wave in (3, 4):
        root = ROOT / "assets" / "local_language_databases" / f"wave{wave}"
        dynamic.extend(root.joinpath("source").glob("*.json"))
        dynamic.extend(root.joinpath("sqlite").glob("*.sql"))
    paths = [ROOT / relative for relative in contract["task13_surfaces"]]
    paths.extend(dynamic)
    for path in paths:
        assert len(path.read_text(encoding="utf-8").splitlines()) <= 1000, path
