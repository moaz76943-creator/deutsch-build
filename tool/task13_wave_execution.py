#!/usr/bin/env python3
"""TASK 13: execute Waves 2-4 as quarantined candidates and derive pairs."""
from __future__ import annotations

import argparse
from dataclasses import dataclass
import json
from pathlib import Path
import sqlite3
import sys
from typing import Any, Mapping, Sequence

ROOT = Path(__file__).resolve().parents[1]
CONTRACT_PATH = ROOT / "tool" / "task13_wave_contract.json"
PAIR_PATH = (
    ROOT
    / "assets"
    / "local_language_databases"
    / "task13_directed_pairs.json"
)


class Task13Error(ValueError):
    pass


@dataclass(frozen=True)
class PromotionDecision:
    allowed: bool
    missing_evidence: tuple[str, ...]


def _text(value: Any, field: str) -> str:
    if not isinstance(value, str) or not value.strip():
        raise Task13Error(f"{field} must be a non-empty string")
    return value.strip()


def _integer(value: Any, field: str, minimum: int = 0) -> int:
    if isinstance(value, bool) or not isinstance(value, int) or value < minimum:
        raise Task13Error(f"{field} must be an integer >= {minimum}")
    return value


def load_contract(path: Path = CONTRACT_PATH) -> dict[str, Any]:
    value = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(value, dict):
        raise Task13Error("TASK 13 contract root must be an object")
    if value.get("schema_version") != 1:
        raise Task13Error("unsupported TASK 13 contract schema")
    if value.get("candidate_policy") != "CANDIDATE_IS_NOT_CANONICAL":
        raise Task13Error("candidate/canonical separation must fail closed")
    if value.get("default_mutation_parallelism") != 1:
        raise Task13Error("TASK 13 mutation parallelism must remain serial")
    return value


def assess_canonical_promotion(
    evidence: Mapping[str, bool],
    *,
    contract: Mapping[str, Any],
) -> PromotionDecision:
    required = contract["canonical_promotion_required_evidence"]
    if not isinstance(required, list) or not required:
        raise Task13Error("canonical promotion evidence contract is invalid")
    missing = tuple(
        item
        for item in required
        if not isinstance(item, str) or evidence.get(item) is not True
    )
    return PromotionDecision(not missing, missing)


def _wave(contract: Mapping[str, Any], wave: int) -> Mapping[str, Any]:
    waves = contract["waves"]
    if not isinstance(waves, dict):
        raise Task13Error("waves must be an object")
    raw = waves.get(str(wave))
    if not isinstance(raw, dict):
        raise Task13Error(f"wave {wave} contract is missing")
    return raw


def _languages(contract: Mapping[str, Any], wave: int) -> tuple[str, ...]:
    raw = _wave(contract, wave).get("languages")
    if not isinstance(raw, list) or not raw:
        raise Task13Error(f"wave {wave} languages must be a non-empty list")
    values = tuple(_text(item, f"wave {wave} language") for item in raw)
    if len(values) != len(set(values)):
        raise Task13Error(f"wave {wave} languages contain duplicates")
    return values


def _semantic_template(contract: Mapping[str, Any]) -> tuple[Mapping[str, Any], ...]:
    raw = contract["semantic_template"]
    if not isinstance(raw, list) or len(raw) != 16:
        raise Task13Error("semantic template must contain exactly 16 cards")
    result: list[Mapping[str, Any]] = []
    ids: set[str] = set()
    for item in raw:
        if not isinstance(item, dict):
            raise Task13Error("semantic template rows must be objects")
        semantic_id = _text(item.get("semanticId"), "semanticId")
        if semantic_id in ids:
            raise Task13Error("semantic template IDs must be unique")
        ids.add(semantic_id)
        if item.get("register") not in {"neutral", "formal"}:
            raise Task13Error("semantic template register is invalid")
        if item.get("cefr") != "A1":
            raise Task13Error("TASK 13 candidate template must remain A1")
        _text(item.get("category"), "category")
        result.append(item)
    return tuple(result)


def _verify_contract_shape(contract: Mapping[str, Any]) -> None:
    expected = {
        2: ("es", "fr", "it", "pt", "nl"),
        3: ("tr", "pl", "sv", "el", "id"),
        4: ("ja", "ko", "fa", "ur"),
    }
    for wave, languages in expected.items():
        if _languages(contract, wave) != languages:
            raise Task13Error(f"wave {wave} language assignment drift")
        if _wave(contract, wave).get("state") != "CANDIDATE_QUARANTINED":
            raise Task13Error(f"wave {wave} must remain candidate quarantined")
    if _wave(contract, 2).get("next_wave_prep") != 3:
        raise Task13Error("wave 2 must prepare wave 3")
    if _wave(contract, 3).get("next_wave_prep") != 4:
        raise Task13Error("wave 3 must prepare wave 4")
    if _wave(contract, 4).get("next_wave_prep") is not None:
        raise Task13Error("wave 4 is the terminal approved roadmap wave")
    if contract.get("anchor_language") != "ar":
        raise Task13Error("TASK 13 directed-pair anchor must remain ar")
    _semantic_template(contract)


def _load_json(path: Path) -> dict[str, Any]:
    value = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(value, dict):
        raise Task13Error(f"{path} root must be an object")
    return value


def _source_path(wave: int, language: str) -> Path:
    return (
        ROOT
        / "assets"
        / "local_language_databases"
        / f"wave{wave}"
        / "source"
        / f"{language}.json"
    )


def _sql_path(wave: int, language: str) -> Path:
    return (
        ROOT
        / "assets"
        / "local_language_databases"
        / f"wave{wave}"
        / "sqlite"
        / f"{language}.sql"
    )


def _verify_source(
    *,
    contract: Mapping[str, Any],
    wave: int,
    language: str,
    legacy_wave2: bool,
) -> dict[str, Any]:
    path = _source_path(wave, language)
    if not path.is_file():
        raise Task13Error(f"candidate source missing: {path.relative_to(ROOT)}")
    source = _load_json(path)
    if source.get("schemaVersion") != 1:
        raise Task13Error(f"{path.name} schemaVersion must be 1")
    pack = source.get("pack")
    if not isinstance(pack, dict):
        raise Task13Error(f"{path.name} pack must be an object")
    expected_pack = f"wave{wave}-{language}-core"
    if pack.get("id") != expected_pack or pack.get("languageCode") != language:
        raise Task13Error(f"{path.name} pack identity mismatch")
    cards = source.get("cards")
    if not isinstance(cards, list) or len(cards) != 16:
        raise Task13Error(f"{path.name} must contain 16 candidate cards")

    template = _semantic_template(contract)
    card_ids: set[str] = set()
    semantic_ids: set[str] = set()
    expected_origin = (
        "wave2-local-agent-candidate"
        if legacy_wave2
        else f"task13-wave{wave}-local-agent-candidate"
    )
    for index, (card, semantic) in enumerate(zip(cards, template), start=1):
        if not isinstance(card, dict):
            raise Task13Error(f"{path.name} card {index} must be an object")
        expected_id = f"wave{wave}-{language}-core-{index:03d}"
        if card.get("id") != expected_id or expected_id in card_ids:
            raise Task13Error(f"{path.name} candidate card ID mismatch")
        card_ids.add(expected_id)
        semantic_id = semantic["semanticId"]
        if card.get("semanticId") != semantic_id or semantic_id in semantic_ids:
            raise Task13Error(f"{path.name} semantic sequence mismatch")
        semantic_ids.add(semantic_id)
        if card.get("languageCode") != language:
            raise Task13Error(f"{path.name} language identity mismatch")
        _text(card.get("text"), f"{path.name} card text")
        if card.get("register") != semantic["register"]:
            raise Task13Error(f"{path.name} register mismatch")
        metadata = card.get("metadata")
        if not isinstance(metadata, dict):
            raise Task13Error(f"{path.name} metadata must be an object")
        expected_metadata = {
            "cefr": "A1",
            "category": semantic["category"],
            "wave": str(wave),
            "reviewStatus": "pending",
            "culturalReview": "pending",
            "provenanceStatus": "pending-qualified-review",
            "origin": expected_origin,
        }
        if metadata != expected_metadata:
            raise Task13Error(f"{path.name} candidate metadata drift")
    return source


def _verify_sql(
    *,
    wave: int,
    language: str,
    source: Mapping[str, Any],
) -> None:
    path = _sql_path(wave, language)
    if not path.is_file():
        raise Task13Error(f"candidate SQLite script missing: {path.relative_to(ROOT)}")
    connection = sqlite3.connect(":memory:")
    try:
        connection.executescript(path.read_text(encoding="utf-8"))
        metadata = dict(connection.execute("SELECT key, value FROM pack_metadata"))
        expected_metadata = {
            "schemaVersion": "1",
            "packId": f"wave{wave}-{language}-core",
            "languageCode": language,
            "wave": str(wave),
            "canonicalCount": "0",
            "quarantineCount": "16",
            "admissionState": "CANDIDATE_ONLY",
        }
        if metadata != expected_metadata:
            raise Task13Error(f"{path.name} SQLite metadata drift")
        canonical_count = connection.execute(
            "SELECT COUNT(*) FROM content_cards"
        ).fetchone()[0]
        rows = connection.execute(
            "SELECT id, semantic_id, language_code, surface, reasons_json, payload_json "
            "FROM quarantine_cards ORDER BY id"
        ).fetchall()
        if canonical_count != 0 or len(rows) != 16:
            raise Task13Error(f"{path.name} candidate/canonical count violation")
        source_cards = {card["id"]: card for card in source["cards"]}
        for row in rows:
            card_id, semantic_id, row_language, surface, reasons_json, payload_json = row
            if card_id not in source_cards:
                raise Task13Error(f"{path.name} quarantine row is not in source")
            card = source_cards[card_id]
            if (
                semantic_id != card["semanticId"]
                or row_language != language
                or surface != card["text"]
                or json.loads(reasons_json) != ["cultural.review_required"]
                or json.loads(payload_json) != card
            ):
                raise Task13Error(f"{path.name} quarantine row/source mismatch")
    finally:
        connection.close()


def _verify_wave2_audit(contract: Mapping[str, Any]) -> None:
    root = ROOT / "assets" / "local_language_databases" / "wave2"
    audit = _load_json(root / "audit.json")
    manifest = _load_json(root / "pipeline_manifest.json")
    languages = list(_languages(contract, 2))
    if audit.get("languages") != languages:
        raise Task13Error("wave 2 audit language order drift")
    if audit.get("admissionState") != "CANDIDATE_ONLY":
        raise Task13Error("wave 2 audit must remain CANDIDATE_ONLY")
    expected = audit.get("expectedPipelineResult")
    if expected != {
        "processedPacks": 5,
        "validPacks": 5,
        "invalidPacks": 0,
        "canonicalCards": 0,
        "quarantinedCards": 80,
        "structuralCards": 80,
    }:
        raise Task13Error("wave 2 audit result drift")
    packs = manifest.get("packs")
    if not isinstance(packs, list):
        raise Task13Error("wave 2 pipeline manifest packs missing")
    if [pack.get("languageCode") for pack in packs] != languages:
        raise Task13Error("wave 2 pipeline manifest language drift")


def _expected_prep(contract: Mapping[str, Any], wave: int) -> dict[str, Any]:
    profiles = contract["language_profiles"]
    if not isinstance(profiles, dict):
        raise Task13Error("language_profiles must be an object")
    languages: list[dict[str, Any]] = []
    for language in _languages(contract, wave):
        profile = profiles.get(language)
        if not isinstance(profile, dict):
            raise Task13Error(f"profile missing for {language}")
        script = _text(profile.get("script"), f"{language} script")
        direction = profile.get("textDirection")
        if direction not in {"ltr", "rtl"}:
            raise Task13Error(f"{language} text direction is invalid")
        languages.append(
            {
                "languageCode": language,
                "script": script,
                "textDirection": direction,
                "plannedRoles": ["USER", "SOURCE", "TARGET"],
                "roleReadiness": "UNASSESSED",
            }
        )
    return {
        "schemaVersion": 1,
        "wave": wave,
        "preparedFromWave": wave - 1,
        "state": "ONE_WAVE_AHEAD_PREP_SATISFIED",
        "canonical": False,
        "contentPromotionAuthorized": False,
        "productionActivationAuthorized": False,
        "mutationParallelism": 1,
        "languages": languages,
        "requiredBeforeCanonical": contract[
            "canonical_promotion_required_evidence"
        ],
    }


def _verify_prep(contract: Mapping[str, Any], wave: int) -> None:
    path = (
        ROOT
        / "assets"
        / "local_language_databases"
        / f"wave{wave}"
        / "prep.json"
    )
    actual = _load_json(path)
    if actual != _expected_prep(contract, wave):
        raise Task13Error(f"wave {wave} one-wave-ahead prep drift")


def _verify_pipeline_manifest(contract: Mapping[str, Any], wave: int) -> None:
    path = (
        ROOT
        / "assets"
        / "local_language_databases"
        / f"wave{wave}"
        / "pipeline_manifest.json"
    )
    value = _load_json(path)
    expected = {
        "schemaVersion": 1,
        "maxParallel": 1,
        "cachePath": f".agent-pulse-cache/wave{wave}_content_validation_cache.json",
        "packs": [
            {
                "id": f"wave{wave}-{language}-core",
                "languageCode": language,
                "path": (
                    f"assets/local_language_databases/wave{wave}/"
                    f"source/{language}.json"
                ),
            }
            for language in _languages(contract, wave)
        ],
    }
    if value != expected:
        raise Task13Error(f"wave {wave} pipeline manifest drift")


def _expected_pairs(contract: Mapping[str, Any]) -> dict[str, Any]:
    anchor = contract["anchor_language"]
    required = contract["canonical_promotion_required_evidence"]
    rows: list[dict[str, Any]] = []
    for wave in (2, 3, 4):
        for language in _languages(contract, wave):
            for source, target in ((anchor, language), (language, anchor)):
                rows.append(
                    {
                        "id": f"{source}->{target}",
                        "wave": wave,
                        "sourceLanguage": source,
                        "targetLanguage": target,
                        "status": "CANDIDATE_DERIVED",
                        "canonical": False,
                        "reverseReadinessInherited": False,
                        "pivotAllowed": False,
                        "readiness": "UNASSESSED",
                        "requiredEvidence": required,
                    }
                )
    return {
        "schemaVersion": 1,
        "baselineMain": contract["baseline_main"],
        "derivationPolicy": (
            "EXPLICIT_DIRECTED_AR_PAIR_NO_REVERSE_INHERITANCE_NO_PIVOT"
        ),
        "pairCount": len(rows),
        "canonicalPromotions": [],
        "pairs": rows,
    }


def _verify_pairs(contract: Mapping[str, Any]) -> None:
    actual = _load_json(PAIR_PATH)
    expected = _expected_pairs(contract)
    if actual != expected:
        raise Task13Error("directed-pair derivation artifact drift")
    ids = {row["id"] for row in actual["pairs"]}
    if len(ids) != 28:
        raise Task13Error("TASK 13 must derive exactly 28 directed pairs")
    for row in actual["pairs"]:
        reverse = f'{row["targetLanguage"]}->{row["sourceLanguage"]}'
        if reverse not in ids:
            raise Task13Error(f"explicit reverse candidate missing for {row['id']}")


def verify() -> int:
    contract = load_contract()
    _verify_contract_shape(contract)
    _verify_wave2_audit(contract)

    card_count = 0
    for wave in (2, 3, 4):
        if wave in (3, 4):
            _verify_prep(contract, wave)
            _verify_pipeline_manifest(contract, wave)
        for language in _languages(contract, wave):
            source = _verify_source(
                contract=contract,
                wave=wave,
                language=language,
                legacy_wave2=wave == 2,
            )
            _verify_sql(wave=wave, language=language, source=source)
            card_count += len(source["cards"])

    _verify_pairs(contract)
    if card_count != 224:
        raise Task13Error(f"candidate card count mismatch: {card_count}")
    if _load_json(PAIR_PATH).get("canonicalPromotions") != []:
        raise Task13Error("TASK 13 must not promote candidate data to canonical")
    return card_count


def _command_check(_: argparse.Namespace) -> int:
    card_count = verify()
    print("TASK 13 WAVES 2-4: PASS")
    print("WAVE2_CANDIDATE_QUARANTINE: PASS")
    print("WAVE3_CANDIDATE_QUARANTINE: PASS")
    print("WAVE4_CANDIDATE_QUARANTINE: PASS")
    print("ONE_WAVE_AHEAD_PREP: PASS")
    print("DIRECTED_PAIR_DERIVATION: PASS")
    print(f"CANDIDATE_CARDS: {card_count}")
    print("DIRECTED_PAIRS: 28")
    print("CANONICAL_PROMOTIONS: 0")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser()
    sub = parser.add_subparsers(dest="command", required=True)
    check = sub.add_parser("check")
    check.set_defaults(func=_command_check)
    args = parser.parse_args()
    try:
        return args.func(args)
    except (
        OSError,
        KeyError,
        TypeError,
        ValueError,
        json.JSONDecodeError,
        sqlite3.Error,
        Task13Error,
    ) as exc:
        print(f"TASK 13 WAVES 2-4: FAIL — {exc}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
