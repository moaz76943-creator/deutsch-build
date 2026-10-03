import json
import sqlite3

from tools.german_linguistic_qa import validate_german_source
from tools.language_pack_factory import build_catalog


def _verb_canonical():
    return {
        "senseId": "fahren.travel",
        "register": "neutral",
        "cefr": "A1",
        "verb": {
            "infinitive": "fahren",
            "reflexivity": "none",
            "auxiliary": "sein",
            "valencyFrames": [
                {
                    "id": "subject_only",
                    "governedCase": "nominative",
                    "semanticRole": "traveler",
                    "objectRequired": False,
                }
            ],
            "forms": [],
        },
    }


def _noun_canonical():
    return {
        "senseId": "fahrer.person",
        "register": "neutral",
        "cefr": "A1",
        "noun": {
            "gender": "masculine",
            "plural": "Fahrer",
            "declensionClass": "strong",
            "caseForms": {
                "nominativeSingular": "Fahrer",
                "accusativeSingular": "Fahrer",
                "dativeSingular": "Fahrer",
                "genitiveSingular": "Fahrers",
                "nominativePlural": "Fahrer",
                "accusativePlural": "Fahrer",
                "dativePlural": "Fahrern",
                "genitivePlural": "Fahrer",
            },
        },
    }


def _source():
    base = _verb_canonical()
    base["wordFamily"] = {
        "familyId": "fahren",
        "baseConceptId": "verb.fahren",
        "relationType": "base",
        "semanticDistance": "low",
        "pedagogicalLevel": "A1",
        "interferenceRisk": False,
    }
    member = _noun_canonical()
    member["wordFamily"] = {
        "familyId": "fahren",
        "baseConceptId": "verb.fahren",
        "relationType": "agent_noun",
        "suffix": "er",
        "semanticDistance": "low",
        "pedagogicalLevel": "A1",
        "interferenceRisk": False,
    }
    return {
        "schemaVersion": 1,
        "pack": {
            "id": "de-word-family",
            "languageCode": "de",
            "displayName": "Deutsch Word Families",
            "version": "1.0.0",
            "contractVersion": "1.0.0",
            "textDirection": "ltr",
        },
        "requiredLocalizationKeys": ["app.title"],
        "localization": {
            "app.title": {"text": "Deutsch lernen", "direction": "ltr"}
        },
        "lexicon": [
            {
                "id": "verb.fahren",
                "surface": "fahren",
                "partOfSpeech": "verb",
                "direction": "ltr",
                "fields": {"translation": "يقود / يذهب", "canonical": base},
            },
            {
                "id": "noun.fahrer",
                "surface": "Fahrer",
                "partOfSpeech": "noun",
                "direction": "ltr",
                "fields": {"translation": "سائق", "canonical": member},
            },
        ],
        "grammar": [],
    }


def test_factory_materializes_only_explicit_word_family_relations(tmp_path):
    source = tmp_path / "source.json"
    source.write_text(json.dumps(_source(), ensure_ascii=False), encoding="utf-8")

    compiled, _ = build_catalog(
        [source],
        tmp_path / "out",
        base_url="https://packs.example.test/v3",
        manifest_revision=30,
        allow_unsigned=True,
    )

    connection = sqlite3.connect(compiled[0].sqlite_path)
    try:
        assert connection.execute("PRAGMA user_version").fetchone() == (3,)
        assert connection.execute(
            "SELECT value FROM metadata WHERE key='canonicalSchemaVersion'"
        ).fetchone() == ("2",)
        assert connection.execute(
            "SELECT family_id, base_concept_id FROM german_word_families"
        ).fetchall() == [("fahren", "verb.fahren")]
        assert connection.execute(
            "SELECT concept_id, relation_type, suffix, semantic_distance, "
            "pedagogical_level, interference_risk "
            "FROM german_word_family_members ORDER BY concept_id"
        ).fetchall() == [
            ("noun.fahrer", "agent_noun", "er", "low", "A1", 0),
            ("verb.fahren", "base", None, "low", "A1", 0),
        ]
    finally:
        connection.close()


def test_qa_rejects_family_without_matching_explicit_base_relation():
    source = _source()
    source["lexicon"][0]["fields"]["canonical"]["wordFamily"]["relationType"] = (
        "semantic_relative"
    )

    report = validate_german_source(source)

    assert report.is_valid is False
    assert any(
        issue.code == "word_family.base_member_invalid"
        for issue in report.errors
    )


def test_qa_never_infers_family_from_surface_prefixes():
    source = _source()
    source["lexicon"].append(
        {
            "id": "verb.erfahren",
            "surface": "erfahren",
            "partOfSpeech": "verb",
            "direction": "ltr",
            "fields": {
                "translation": "يعرف / يكتشف",
                "canonical": {
                    **_verb_canonical(),
                    "senseId": "erfahren.learn",
                    "verb": {
                        **_verb_canonical()["verb"],
                        "infinitive": "erfahren",
                    },
                },
            },
        }
    )

    report = validate_german_source(source)

    assert report.is_valid is True
