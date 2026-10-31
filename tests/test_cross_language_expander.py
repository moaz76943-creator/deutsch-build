import json
from pathlib import Path

try:
    from jsonschema import Draft202012Validator
except ImportError:  # CI installs only pytest; repository validation remains dependency-free.
    Draft202012Validator = None

from tools.data_generator.cross_language_expander import (
    DEFAULT_OUTPUT_DIR,
    build_pair_skeleton,
    validate_pair_skeleton,
    write_matrix_skeletons,
)

ROOT = Path(__file__).resolve().parents[1]
SCHEMA_PATH = ROOT / "tools" / "data_generator" / "schema.json"
REFERENCE_PATH = ROOT / "tools" / "data_generator" / "fixtures" / "de_ar_a1_core.json"


def _load_reference():
    return json.loads(REFERENCE_PATH.read_text(encoding="utf-8"))


def _entry_map(dataset):
    return {
        (entry["concept_id"], entry["pair_identity"]["id"]): entry
        for entry in dataset["entries"]
    }


def test_generated_skeletons_pass_draft_2020_12_and_preserve_concept_ids():
    reference = _load_reference()
    schema = json.loads(SCHEMA_PATH.read_text(encoding="utf-8"))
    assert schema["$schema"] == "https://json-schema.org/draft/2020-12/schema"
    validator = Draft202012Validator(schema) if Draft202012Validator is not None else None
    reference_concepts = {entry["concept_id"] for entry in reference["entries"]}

    for pair in (("de", "en"), ("en", "ar"), ("ar", "de")):
        skeleton = build_pair_skeleton(reference, *pair)
        if validator is not None:
            assert list(validator.iter_errors(skeleton)) == []
        validate_pair_skeleton(skeleton, schema_path=SCHEMA_PATH)
        assert {entry["concept_id"] for entry in skeleton["entries"]} == reference_concepts
        assert len(skeleton["entries"]) == 2 * len(reference_concepts)


def test_de_en_skeleton_is_symmetric_and_ltr_in_both_directions():
    skeleton = build_pair_skeleton(_load_reference(), "de", "en")
    by_key = _entry_map(skeleton)

    for concept_id in {entry["concept_id"] for entry in skeleton["entries"]}:
        forward = by_key[(concept_id, "de->en")]
        reverse = by_key[(concept_id, "en->de")]

        assert forward["source_text"] == reverse["target_text"]
        assert forward["target_text"] == reverse["source_text"]
        assert forward["pair_identity"]["record_id"] == reverse["pair_identity"]["reverse_record_id"]
        assert forward["pair_identity"]["reverse_record_id"] == reverse["pair_identity"]["record_id"]
        assert forward["sourceLanguageDirection"] == "ltr"
        assert forward["targetLanguageDirection"] == "ltr"
        assert reverse["sourceLanguageDirection"] == "ltr"
        assert reverse["targetLanguageDirection"] == "ltr"
        assert forward["rtl_flag"] is False
        assert reverse["rtl_flag"] is False
        assert forward["target_text"].startswith("__TEMPLATE_TEXT__:en:")
        assert reverse["source_text"].startswith("__TEMPLATE_TEXT__:en:")


def test_ar_de_skeleton_preserves_known_realizations_and_is_symmetric():
    reference = _load_reference()
    skeleton = build_pair_skeleton(reference, "ar", "de")
    by_key = _entry_map(skeleton)

    reference_by_key = {
        (entry["concept_id"], entry["pair_identity"]["id"]): entry
        for entry in reference["entries"]
    }
    for concept_id in {entry["concept_id"] for entry in skeleton["entries"]}:
        forward = by_key[(concept_id, "ar->de")]
        reverse = by_key[(concept_id, "de->ar")]
        assert forward["source_text"] == reference_by_key[(concept_id, "ar->de")]["source_text"]
        assert forward["target_text"] == reference_by_key[(concept_id, "ar->de")]["target_text"]
        assert reverse["source_text"] == forward["target_text"]
        assert reverse["target_text"] == forward["source_text"]
        assert forward["sourceLanguageDirection"] == "rtl"
        assert forward["targetLanguageDirection"] == "ltr"
        assert reverse["sourceLanguageDirection"] == "ltr"
        assert reverse["targetLanguageDirection"] == "rtl"
        assert "__TEMPLATE_TEXT__" not in forward["source_text"]
        assert "__TEMPLATE_TEXT__" not in forward["target_text"]


def test_en_ar_skeleton_is_symmetric_and_marks_arabic_as_rtl():
    skeleton = build_pair_skeleton(_load_reference(), "en", "ar")
    by_key = _entry_map(skeleton)

    for concept_id in {entry["concept_id"] for entry in skeleton["entries"]}:
        forward = by_key[(concept_id, "en->ar")]
        reverse = by_key[(concept_id, "ar->en")]

        assert forward["source_text"] == reverse["target_text"]
        assert forward["target_text"] == reverse["source_text"]
        assert forward["sourceLanguageDirection"] == "ltr"
        assert forward["targetLanguageDirection"] == "rtl"
        assert reverse["sourceLanguageDirection"] == "rtl"
        assert reverse["targetLanguageDirection"] == "ltr"
        assert forward["rtl_flag"] is True
        assert reverse["rtl_flag"] is True


def test_writer_emits_deterministic_pair_files(tmp_path):
    assert DEFAULT_OUTPUT_DIR == ROOT / "tools" / "data_generator" / "output" / "matrix_skeletons"
    paths = write_matrix_skeletons(
        [("de", "en"), ("en", "ar")],
        reference_path=REFERENCE_PATH,
        output_dir=tmp_path,
        schema_path=SCHEMA_PATH,
    )

    assert [path.name for path in paths] == [
        "de-en.skeleton.json",
        "en-ar.skeleton.json",
    ]
    for path in paths:
        payload = json.loads(path.read_text(encoding="utf-8"))
        assert payload["schema_version"] == "1.0.0"
        assert payload["entries"]
