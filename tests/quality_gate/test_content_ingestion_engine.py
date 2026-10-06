from __future__ import annotations

import json

import pytest

from tools.content_ingestion_engine import (
    ContentIngestionError,
    compile_language_pack_document,
    parse_csv_text,
    parse_json_text,
)
from tools.language_pack_factory import validate_source_document


def _json_payload() -> str:
    return json.dumps(
        [
            {
                "id": "a1.house",
                "level": "A1",
                "german": "Haus",
                "arabic": "بيت",
                "partOfSpeech": "noun",
                "article": "das",
                "plural": "Häuser",
                "exampleGerman": "Das Haus ist groß.",
                "exampleArabic": "البيت كبير.",
                "topic": "home",
                "skill": "vocabulary",
                "register": "neutral",
                "accepted": ["das Haus", "Häuser"],
            },
            {
                "id": "a2.train",
                "level": "A2",
                "german": "Zug",
                "arabic": "قطار",
                "partOfSpeech": "noun",
                "article": "der",
                "plural": "Züge",
                "exampleGerman": "Der Zug kommt später.",
                "exampleArabic": "القطار يصل لاحقاً.",
                "topic": "travel",
                "skill": "vocabulary",
                "register": "neutral",
                "accepted": ["der Zug", "Züge"],
            },
            {
                "id": "b1.decide",
                "level": "B1",
                "german": "entscheiden",
                "arabic": "يقرر",
                "partOfSpeech": "verb",
                "exampleGerman": "Ich entscheide heute.",
                "exampleArabic": "أقرر اليوم.",
                "topic": "daily",
                "skill": "verbs",
                "register": "neutral",
                "accepted": ["entscheidet"],
            },
        ],
        ensure_ascii=False,
    )


def _csv_payload() -> str:
    return """id,level,german,arabic,partOfSpeech,article,plural,exampleGerman,exampleArabic,topic,skill,register,accepted
a1.house,A1,Haus,بيت,noun,das,Häuser,Das Haus ist groß.,البيت كبير.,home,vocabulary,neutral,das Haus|Häuser
a2.train,A2,Zug,قطار,noun,der,Züge,Der Zug kommt später.,القطار يصل لاحقاً.,travel,vocabulary,neutral,der Zug|Züge
b1.decide,B1,entscheiden,يقرر,verb,,,Ich entscheide heute.,أقرر اليوم.,daily,verbs,neutral,entscheidet
"""


def test_json_and_csv_parse_to_the_same_content_model():
    json_rows = parse_json_text(_json_payload())
    csv_rows = parse_csv_text(_csv_payload())

    assert json_rows == csv_rows
    assert [row.level.value for row in json_rows] == ["A1", "A2", "B1"]
    assert json_rows[0].article == "das"
    assert json_rows[0].accepted == ("das Haus", "Häuser")


def test_parser_rejects_duplicate_ids():
    payload = json.dumps(
        [
            {"id": "same", "level": "A1", "german": "Haus", "arabic": "بيت"},
            {"id": "same", "level": "A2", "german": "Wohnung", "arabic": "شقة"},
        ],
        ensure_ascii=False,
    )

    with pytest.raises(ContentIngestionError, match="duplicate content id"):
        parse_json_text(payload)


def test_parser_rejects_unsupported_cefr_level():
    payload = json.dumps(
        [{"id": "bad.level", "level": "C1", "german": "Wort", "arabic": "كلمة"}],
        ensure_ascii=False,
    )

    with pytest.raises(ContentIngestionError, match="unsupported CEFR level"):
        parse_json_text(payload)


def test_csv_rejects_cells_without_declared_headers():
    payload = "id,level,german,arabic\nx,A1,Haus,بيت,unexpected\n"

    with pytest.raises(ContentIngestionError, match="undeclared cells"):
        parse_csv_text(payload)


def test_compiler_emits_factory_compatible_canonical_cefr_and_runtime_fields():
    document = compile_language_pack_document(
        parse_json_text(_json_payload()),
        pack_id="de-core-v1",
        version="1.0.0",
        display_name="Deutsch بالعربي Core",
    )

    validated = validate_source_document(document)
    house = next(row for row in validated["lexicon"] if row["id"] == "a1.house")
    fields = house["fields"]

    assert validated["pack"]["languageCode"] == "de"
    assert fields["translation"] == "بيت"
    assert fields["example"] == "Das Haus ist groß."
    assert fields["exampleTranslation"] == "البيت كبير."
    assert fields["article"] == "das"
    assert fields["plural"] == "Häuser"
    assert fields["accepted"] == ["das Haus", "Häuser"]
    assert fields["canonical"]["cefr"] == "A1"
    assert fields["canonical"]["register"] == "neutral"


def test_compiler_is_deterministic_by_content_id():
    rows = list(reversed(parse_json_text(_json_payload())))

    document = compile_language_pack_document(
        rows,
        pack_id="de-core-v1",
        version="1.0.0",
    )

    assert [row["id"] for row in document["lexicon"]] == [
        "a1.house",
        "a2.train",
        "b1.decide",
    ]
