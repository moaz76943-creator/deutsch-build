import copy
import json
from pathlib import Path

import pytest

from tools.data_generator.matrix_builder import (
    MatrixValidationError,
    build_bidirectional_pair_sets,
    build_directed_pair_matrix,
    generate_bidirectional_pair,
    ingest_datasets,
    load_and_validate,
    make_entry,
    text_direction_for_language,
    validate_dataset,
)

HERE = Path(__file__).resolve().parent
SCHEMA_PATH = HERE / "schema.json"
FIXTURE_PATH = HERE / "fixtures" / "sample_de_ar_a1.json"


def load_fixture():
    return json.loads(FIXTURE_PATH.read_text(encoding="utf-8"))


def test_sample_fixture_validates_end_to_end():
    dataset = load_and_validate(FIXTURE_PATH, schema_path=SCHEMA_PATH)
    assert dataset["schema_version"] == "1.0.0"
    assert [entry["pair_identity"]["id"] for entry in dataset["entries"]] == [
        "de->ar",
        "ar->de",
    ]


def test_schema_declares_required_canonical_fields_including_rtl_flag():
    schema = json.loads(SCHEMA_PATH.read_text(encoding="utf-8"))
    item = schema["properties"]["entries"]["items"]
    required = {
        "cefr_level",
        "source_text",
        "target_text",
        "pair_identity",
        "phonetics",
        "part_of_speech",
        "bidirectional_flag",
        "rtl_flag",
    }
    assert required.issubset(item["required"])
    assert item["properties"]["rtl_flag"] == {"type": "boolean"}
    assert item["properties"]["cefr_level"]["enum"] == ["A1", "A2", "B1", "B2"]


def test_generate_bidirectional_pair_emits_two_explicit_directed_records():
    forward, reverse = generate_bidirectional_pair(
        canonical_key="de-ar.a1.hallo",
        cefr_level="A1",
        source_text="Hallo",
        target_text="مرحباً",
        source_language="de",
        target_language="ar",
        source_phonetics="haˈloː",
        target_phonetics="mar.ħa.ban",
        part_of_speech="interjection",
    )
    dataset = {"schema_version": "1.0.0", "entries": [forward, reverse]}
    validate_dataset(dataset, schema_path=SCHEMA_PATH)
    assert forward["pair_identity"]["id"] == "de->ar"
    assert reverse["pair_identity"]["id"] == "ar->de"
    assert forward["rtl_flag"] is True
    assert reverse["rtl_flag"] is True


def test_bidirectional_flag_requires_explicit_reciprocal_record():
    dataset = load_fixture()
    dataset["entries"].pop()
    with pytest.raises(MatrixValidationError, match="reciprocal record missing"):
        validate_dataset(dataset, schema_path=SCHEMA_PATH)


def test_duplicate_canonical_keys_are_rejected_after_unicode_normalization():
    dataset = load_fixture()
    duplicate = copy.deepcopy(dataset["entries"][0])
    duplicate["canonical_key"] = dataset["entries"][0]["canonical_key"].upper()
    dataset["entries"].append(duplicate)
    with pytest.raises(MatrixValidationError, match="duplicate canonical_key"):
        validate_dataset(dataset, schema_path=SCHEMA_PATH)


def test_invalid_cefr_level_is_rejected_by_schema():
    dataset = load_fixture()
    dataset["entries"][0]["cefr_level"] = "C1"
    with pytest.raises(MatrixValidationError, match="cefr_level"):
        validate_dataset(dataset, schema_path=SCHEMA_PATH)


@pytest.mark.parametrize(
    ("language", "expected"),
    [("ar", "rtl"), ("ur", "rtl"), ("de", "ltr"), ("en", "ltr")],
)
def test_language_direction_registry(language, expected):
    assert text_direction_for_language(language) == expected


def test_mismatched_direction_tag_is_rejected():
    dataset = load_fixture()
    dataset["entries"][0]["pair_identity"]["target_direction"] = "ltr"
    with pytest.raises(MatrixValidationError, match="target_direction"):
        validate_dataset(dataset, schema_path=SCHEMA_PATH)


def test_mismatched_rtl_flag_is_rejected():
    dataset = load_fixture()
    dataset["entries"][0]["rtl_flag"] = False
    with pytest.raises(MatrixValidationError, match="rtl_flag"):
        validate_dataset(dataset, schema_path=SCHEMA_PATH)


def test_pair_identity_must_match_source_and_target_languages():
    dataset = load_fixture()
    dataset["entries"][0]["pair_identity"]["id"] = "ar->de"
    with pytest.raises(MatrixValidationError, match="pair_identity.id"):
        validate_dataset(dataset, schema_path=SCHEMA_PATH)


def test_ltr_to_ltr_entry_sets_rtl_flag_false():
    entry = make_entry(
        canonical_key="de-en.a1.hello",
        cefr_level="A1",
        source_text="Hallo",
        target_text="Hello",
        source_language="de",
        target_language="en",
        source_phonetics="haˈloː",
        target_phonetics="həˈloʊ",
        part_of_speech="interjection",
        bidirectional_flag=False,
    )
    assert entry["rtl_flag"] is False


def test_twenty_languages_produce_380_directed_pairs_and_190_bidirectional_sets():
    languages = [
        "ar", "de", "en", "ur", "fr", "es", "it", "pt", "nl", "pl",
        "tr", "ru", "uk", "fa", "he", "hi", "zh", "ja", "ko", "id",
    ]
    directed = build_directed_pair_matrix(languages)
    bidirectional = build_bidirectional_pair_sets(languages)
    assert len(directed) == 380
    assert len(set(directed)) == 380
    assert len(bidirectional) == 190
    assert all(
        reverse == f"{forward.split('->')[1]}->{forward.split('->')[0]}"
        for forward, reverse in bidirectional
    )


def test_pair_matrix_rejects_duplicate_language_codes():
    with pytest.raises(ValueError, match="duplicate language code"):
        build_directed_pair_matrix(["de", "ar", "DE"])


def test_ingest_datasets_revalidates_duplicates_across_files(tmp_path):
    first = tmp_path / "first.json"
    second = tmp_path / "second.json"
    fixture = load_fixture()
    first.write_text(json.dumps(fixture, ensure_ascii=False), encoding="utf-8")
    second.write_text(json.dumps(fixture, ensure_ascii=False), encoding="utf-8")
    with pytest.raises(MatrixValidationError, match="duplicate canonical_key"):
        ingest_datasets([first, second], schema_path=SCHEMA_PATH)

def test_de_ar_a1_core_fixture_is_curated_unique_and_bidirectionally_consistent():
    import re
    from collections import Counter
    from tools.data_generator.de_ar_a1_core_generator import CONCEPTS, build_core_dataset

    core_path = HERE / "fixtures" / "de_ar_a1_core.json"
    dataset = load_and_validate(core_path, schema_path=SCHEMA_PATH)
    assert dataset == build_core_dataset()
    entries = dataset["entries"]
    assert len(CONCEPTS) == 106
    assert len(entries) == 212

    forward = [entry for entry in entries if entry["pair_identity"]["id"] == "ar->de"]
    reverse = [entry for entry in entries if entry["pair_identity"]["id"] == "de->ar"]
    assert len(forward) == 106
    assert len(reverse) == 106
    assert len({entry["concept_id"] for entry in entries}) == 106
    assert all(entry["cefr_level"] == "A1" for entry in entries)
    assert {entry["part_of_speech"] for entry in entries} <= {"noun", "verb", "adjective", "adverb", "phrase"}

    assert Counter(entry["domain"] for entry in forward) == {
        "workplace_healthcare": 15,
        "emergency": 10,
        "bureaucracy_registration": 14,
        "daily_essentials": 30,
        "healthcare_pharmacy": 13,
        "directions_transport": 12,
        "emergency_basic": 12,
    }

    assert all(entry["source_rtl"] is True and entry["target_rtl"] is False for entry in forward)
    assert all(entry["source_rtl"] is False and entry["target_rtl"] is True for entry in reverse)
    assert all(entry["pair_identity"]["source_direction"] == "rtl" for entry in forward)
    assert all(entry["pair_identity"]["target_direction"] == "ltr" for entry in forward)
    assert all(entry["bidirectional_flag"] is True for entry in entries)

    canonical_keys = [entry["canonical_key"] for entry in entries]
    record_ids = [entry["pair_identity"]["record_id"] for entry in entries]
    assert len(set(canonical_keys)) == len(canonical_keys) == 212
    assert len(set(record_ids)) == len(record_ids) == 212

    forward_nouns = [entry for entry in forward if entry["part_of_speech"] == "noun"]
    assert len(forward_nouns) == 77
    assert all(entry["plural_form"].strip() for entry in forward_nouns)
    assert all(re.match(r"^(der|die|das)\s+", entry["target_text"]) for entry in forward_nouns)
    assert all(
        entry.get("plural_form", "").strip()
        for entry in entries
        if entry["part_of_speech"] == "noun"
    )

    by_record_id = {entry["pair_identity"]["record_id"]: entry for entry in entries}
    for entry in entries:
        reverse_entry = by_record_id[entry["pair_identity"]["reverse_record_id"]]
        assert reverse_entry["pair_identity"]["reverse_record_id"] == entry["pair_identity"]["record_id"]
        assert reverse_entry["concept_id"] == entry["concept_id"]
        assert reverse_entry["source_text"] == entry["target_text"]
        assert reverse_entry["target_text"] == entry["source_text"]
        assert reverse_entry["example_sentence"]["source"] == entry["example_sentence"]["target"]
        assert reverse_entry["example_sentence"]["target"] == entry["example_sentence"]["source"]
