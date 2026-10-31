from collections import Counter
from pathlib import Path

from tools.data_generator.de_ar_a1_core_generator import (
    PRACTICAL_KEYS,
    PRACTICAL_TOPIC_CONCEPTS,
    build_core_dataset,
)
from tools.data_generator.matrix_builder import load_and_validate, validate_dataset

ROOT = Path(__file__).resolve().parents[1]
SCHEMA_PATH = ROOT / "tools" / "data_generator" / "schema.json"
FIXTURE_PATH = ROOT / "tools" / "data_generator" / "fixtures" / "de_ar_a1_core.json"


def _practical_entries(dataset):
    return [
        entry
        for entry in dataset["entries"]
        if (entry["domain"], entry["concept_id"].rsplit(".", 1)[-1]) in PRACTICAL_KEYS
    ]


def test_practical_topic_expansion_adds_exactly_50_unique_a1_concepts():
    assert len(PRACTICAL_TOPIC_CONCEPTS) == 50
    assert len(PRACTICAL_KEYS) == 50
    counts = Counter(item[0] for item in PRACTICAL_TOPIC_CONCEPTS)
    assert counts == {
        "healthcare_pharmacy": 13,
        "daily_essentials": 13,
        "directions_transport": 12,
        "emergency_basic": 12,
    }


def test_practical_topic_records_follow_schema_v1_metadata_contract():
    dataset = build_core_dataset()
    validate_dataset(dataset, schema_path=SCHEMA_PATH)
    practical = _practical_entries(dataset)
    assert len(practical) == 100

    for entry in practical:
        assert entry["cefr_level"] == "A1"
        assert entry["partOfSpeech"] == entry["part_of_speech"]
        assert entry["transliteration"]["source"].strip()
        assert entry["transliteration"]["target"].strip()
        assert entry["audioMarker"]["source"] in {"ar-SA", "de-DE"}
        assert entry["audioMarker"]["target"] in {"ar-SA", "de-DE"}
        assert entry["audioMarker"]["source"] != entry["audioMarker"]["target"]
        assert entry["example_sentence"]["contextNote"].strip()


def test_canonical_fixture_has_zero_validation_errors_and_matches_generator():
    fixture = load_and_validate(FIXTURE_PATH, schema_path=SCHEMA_PATH)
    assert fixture == build_core_dataset()
