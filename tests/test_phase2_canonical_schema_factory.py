import json
import sqlite3

from tools.language_pack_factory import build_catalog


def _source():
    return {
        "schemaVersion": 1,
        "pack": {
            "id": "de-canonical",
            "languageCode": "de",
            "displayName": "Deutsch Canonical",
            "version": "2.0.0",
            "contractVersion": "1.0.0",
            "textDirection": "ltr",
        },
        "requiredLocalizationKeys": ["app.title"],
        "localization": {
            "app.title": {"text": "Deutsch lernen", "direction": "ltr"}
        },
        "lexicon": [
            {
                "id": "noun.student",
                "surface": "Student",
                "partOfSpeech": "noun",
                "direction": "ltr",
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
                "fields": {
                    "translation": "ينتظر",
                    "canonical": {
                        "senseId": "warten.wait",
                        "register": "neutral",
                        "cefr": "A1",
                        "verb": {
                            "infinitive": "warten",
                            "reflexivity": "none",
                            "auxiliary": "haben",
                            "participleII": "gewartet",
                            "preterite": "wartete",
                            "imperative": "warte",
                            "valencyFrames": [
                                {
                                    "id": "prep_auf",
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


def test_factory_dual_writes_legacy_and_canonical_relational_schema(tmp_path):
    source = tmp_path / "source.json"
    source.write_text(json.dumps(_source(), ensure_ascii=False), encoding="utf-8")

    compiled, _ = build_catalog(
        [source],
        tmp_path / "out",
        base_url="https://packs.example.test/v2",
        manifest_revision=20,
        allow_unsigned=True,
    )
    connection = sqlite3.connect(compiled[0].sqlite_path)
    try:
        tables = {
            row[0]
            for row in connection.execute(
                "SELECT name FROM sqlite_master WHERE type='table'"
            )
        }
        assert {
            "lexicon",
            "concepts",
            "german_nouns",
            "german_verbs",
            "verb_valency_frames",
            "german_verb_forms",
        }.issubset(tables)
        assert connection.execute("PRAGMA user_version").fetchone() == (3,)
        assert connection.execute(
            "SELECT value FROM metadata WHERE key='canonicalSchemaVersion'"
        ).fetchone() == ("2",)

        # Legacy Phase-1 row remains intact during structural migration.
        assert connection.execute(
            "SELECT surface FROM lexicon WHERE id='noun.student'"
        ).fetchone() == ("Student",)

        assert connection.execute(
            "SELECT sense_id, register, cefr FROM concepts "
            "WHERE concept_id='noun.student'"
        ).fetchone() == ("student.person", "neutral", "A1")
        assert connection.execute(
            "SELECT gender, declension_class, dative_singular "
            "FROM german_nouns WHERE concept_id='noun.student'"
        ).fetchone() == ("masculine", "weak", "Studenten")
        assert connection.execute(
            "SELECT auxiliary, participle_ii FROM german_verbs "
            "WHERE concept_id='verb.warten'"
        ).fetchone() == ("haben", "gewartet")
        assert connection.execute(
            "SELECT preposition, preposition_case FROM verb_valency_frames "
            "WHERE concept_id='verb.warten' AND frame_id='prep_auf'"
        ).fetchone() == ("auf", "accusative")
    finally:
        connection.close()


def test_factory_backfills_generic_concept_without_inventing_morphology(tmp_path):
    payload = _source()
    payload["lexicon"] = [
        {
            "id": "legacy.haus",
            "surface": "Haus",
            "partOfSpeech": "noun",
            "direction": "ltr",
            "fields": {"cefr": "A1"},
        }
    ]
    source = tmp_path / "legacy.json"
    source.write_text(json.dumps(payload, ensure_ascii=False), encoding="utf-8")

    compiled, _ = build_catalog(
        [source],
        tmp_path / "out",
        base_url="https://packs.example.test/v2",
        manifest_revision=21,
        allow_unsigned=True,
    )
    connection = sqlite3.connect(compiled[0].sqlite_path)
    try:
        assert connection.execute(
            "SELECT sense_id, lemma, register FROM concepts "
            "WHERE concept_id='legacy.haus'"
        ).fetchone() == ("legacy.haus", "Haus", "neutral")
        assert connection.execute(
            "SELECT COUNT(*) FROM german_nouns WHERE concept_id='legacy.haus'"
        ).fetchone() == (0,)
    finally:
        connection.close()
