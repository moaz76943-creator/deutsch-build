import json
import sqlite3

import pytest

from tools.german_linguistic_qa import (
    GermanLinguisticQaError,
    assert_german_source,
    audit_sqlite_connection,
    validate_german_source,
)
from tools.language_pack_factory import PackFactoryValidationError, compile_pack


def _document():
    return {
        "schemaVersion": 1,
        "pack": {
            "id": "de-qa",
            "languageCode": "de",
            "displayName": "Deutsch QA",
            "version": "1.0.0",
            "contractVersion": "1.0.0",
            "textDirection": "ltr",
        },
        "requiredLocalizationKeys": ["app.title"],
        "localization": {
            "app.title": {
                "text": "Deutsch lernen",
                "direction": "ltr",
                "bidiOverride": False,
            }
        },
        "lexicon": [
            {
                "id": "noun.student",
                "surface": "Student",
                "partOfSpeech": "noun",
                "direction": "ltr",
                "bidiOverride": False,
                "fields": {
                    "translation": "طالب",
                    "canonical": {
                        "senseId": "student.person",
                        "register": "neutral",
                        "cefr": "A1",
                        "semanticTags": ["people"],
                        "noun": {
                            "gender": "masculine",
                            "plural": "Studenten",
                            "declensionClass": "weak",
                            "caseForms": {
                                "nominativeSingular": "Student",
                                "accusativeSingular": "Studenten",
                                "dativeSingular": "Studenten",
                                "genitiveSingular": "Studenten",
                                "nominativePlural": "Studenten",
                                "accusativePlural": "Studenten",
                                "dativePlural": "Studenten",
                                "genitivePlural": "Studenten",
                            },
                        },
                    },
                },
            },
            {
                "id": "verb.warten",
                "surface": "warten",
                "partOfSpeech": "verb",
                "direction": "ltr",
                "bidiOverride": False,
                "fields": {
                    "translation": "ينتظر",
                    "canonical": {
                        "senseId": "warten.wait",
                        "register": "neutral",
                        "cefr": "A1",
                        "semanticTags": [],
                        "verb": {
                            "infinitive": "warten",
                            "separablePrefix": None,
                            "inseparablePrefix": None,
                            "reflexivity": "none",
                            "auxiliary": "haben",
                            "participleII": "gewartet",
                            "preterite": "wartete",
                            "imperative": "warte",
                            "valencyFrames": [
                                {
                                    "id": "prep_auf",
                                    "governedCase": None,
                                    "preposition": "auf",
                                    "prepositionCase": "accusative",
                                    "semanticRole": "target",
                                    "objectRequired": True,
                                }
                            ],
                            "forms": [
                                {
                                    "tense": "present",
                                    "personKey": "ich",
                                    "form": "warte",
                                }
                            ],
                        },
                    },
                },
            },
        ],
        "grammar": [],
    }


def test_source_qa_accepts_consistent_canonical_german_data():
    report = validate_german_source(_document())

    assert report.is_valid
    assert report.errors == ()


def test_source_qa_fails_closed_on_noun_and_valency_inconsistency():
    payload = _document()
    noun = payload["lexicon"][0]["fields"]["canonical"]["noun"]
    noun["caseForms"]["nominativePlural"] = "Studente"
    verb = payload["lexicon"][1]["fields"]["canonical"]["verb"]
    verb["valencyFrames"][0]["prepositionCase"] = None

    report = validate_german_source(payload)
    codes = {issue.code for issue in report.errors}

    assert "noun.plural_mismatch" in codes
    assert "valency.preposition_case_pair" in codes
    with pytest.raises(GermanLinguisticQaError):
        assert_german_source(payload)


def test_language_pack_factory_invokes_german_qa_before_emission(tmp_path):
    payload = _document()
    payload["lexicon"][1]["fields"]["canonical"]["verb"]["auxiliary"] = "unknown"
    source = tmp_path / "bad.json"
    source.write_text(json.dumps(payload, ensure_ascii=False), encoding="utf-8")

    with pytest.raises(PackFactoryValidationError, match="verb.auxiliary_unresolved"):
        compile_pack(
            source,
            tmp_path / "out",
            base_url="https://packs.example.test",
        )


def test_sqlite_audit_detects_relational_semantic_corruption():
    connection = sqlite3.connect(":memory:")
    connection.executescript(
        """
        CREATE TABLE metadata (key TEXT PRIMARY KEY, value TEXT NOT NULL);
        INSERT INTO metadata VALUES ('languageCode', 'de');
        CREATE TABLE concepts (
          concept_id TEXT PRIMARY KEY,
          lemma TEXT NOT NULL,
          part_of_speech TEXT NOT NULL
        );
        CREATE TABLE german_nouns (
          concept_id TEXT PRIMARY KEY,
          gender TEXT NOT NULL,
          plural TEXT,
          declension_class TEXT NOT NULL,
          nominative_singular TEXT NOT NULL,
          accusative_singular TEXT NOT NULL,
          dative_singular TEXT NOT NULL,
          genitive_singular TEXT NOT NULL,
          nominative_plural TEXT,
          accusative_plural TEXT,
          dative_plural TEXT,
          genitive_plural TEXT
        );
        CREATE TABLE german_verbs (
          concept_id TEXT PRIMARY KEY,
          infinitive TEXT NOT NULL,
          separable_prefix TEXT,
          inseparable_prefix TEXT,
          reflexivity TEXT NOT NULL,
          auxiliary TEXT NOT NULL
        );
        CREATE TABLE verb_valency_frames (
          concept_id TEXT NOT NULL,
          frame_id TEXT NOT NULL,
          governed_case TEXT,
          preposition TEXT,
          preposition_case TEXT,
          semantic_role TEXT NOT NULL,
          object_required INTEGER NOT NULL
        );
        INSERT INTO concepts VALUES ('noun.bad', 'Haus', 'noun');
        INSERT INTO german_nouns VALUES (
          'noun.bad', 'unknown', 'Haeuser', 'unknown',
          'Haus', 'Haus', 'Haus', 'Hauses',
          'Häuser', 'Häuser', 'Häusern', 'Häuser'
        );
        """
    )

    report = audit_sqlite_connection(connection)
    codes = {issue.code for issue in report.errors}

    assert "noun.gender_unresolved" in codes
    assert "noun.declension_unresolved" in codes
    assert "noun.plural_mismatch" in codes
