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
