#!/usr/bin/env python3
"""Deterministic JSON/CSV -> canonical language-pack ingestion for DEUTSCH بالعربي.

This is a build-time authoring boundary. Runtime remains the admitted indexed
SQLite corpus; raw JSON/CSV is never loaded into the Flutter UI isolate.
"""

from __future__ import annotations

import argparse
import csv
import io
import json
import re
import sys
from dataclasses import dataclass
from enum import Enum
from pathlib import Path
from typing import Any, Iterable, Mapping, Sequence


_ID_RE = re.compile(r"^[A-Za-z0-9][A-Za-z0-9._:-]{0,127}$")
_ALLOWED_PARTS_OF_SPEECH = {
    "noun",
    "verb",
    "adjective",
    "adverb",
    "pronoun",
    "preposition",
    "conjunction",
    "interjection",
    "determiner",
    "numeral",
    "phrase",
    "other",
}
_ALLOWED_REGISTERS = {"formal", "neutral", "informal"}
_ALLOWED_ARTICLES = {"", "der", "die", "das"}
_REQUIRED_FIELDS = {"id", "level", "german", "arabic"}
_ALLOWED_FIELDS = {
    "id",
    "level",
    "german",
    "arabic",
    "partOfSpeech",
    "article",
    "plural",
    "exampleGerman",
    "exampleArabic",
    "topic",
    "skill",
    "register",
    "accepted",
}


class ContentIngestionError(ValueError):
    """Raised when authoring content cannot be admitted safely."""


class CefrLevel(str, Enum):
    A1 = "A1"
    A2 = "A2"
    B1 = "B1"
    B2 = "B2"


@dataclass(frozen=True)
class IngestedContentItem:
    """Validated authoring model before compilation into a language pack."""

    id: str
    level: CefrLevel
    german: str
    arabic: str
    part_of_speech: str = "other"
    article: str = ""
    plural: str = ""
    example_german: str = ""
    example_arabic: str = ""
    topic: str = "general"
    skill: str = "vocabulary"
    register: str = "neutral"
    accepted: tuple[str, ...] = ()


def _visible_string(
    raw: Any,
    field: str,
    *,
    required: bool = False,
    default: str = "",
    max_length: int = 4000,
) -> str:
    if raw is None:
        if required:
            raise ContentIngestionError(f"{field} is required")
        return default
    if not isinstance(raw, str):
        raise ContentIngestionError(f"{field} must be a string")
    value = raw.strip()
    if required and not value:
        raise ContentIngestionError(f"{field} must be non-empty")
    if len(value) > max_length:
        raise ContentIngestionError(f"{field} exceeds {max_length} characters")
    return value or default


def _accepted_forms(raw: Any, field: str) -> tuple[str, ...]:
    if raw is None or raw == "":
        return ()
    if isinstance(raw, str):
        values: Sequence[Any] = raw.split("|")
    elif isinstance(raw, list):
        values = raw
    else:
        raise ContentIngestionError(
            f"{field} must be a list or pipe-delimited string"
        )

    output: list[str] = []
    seen: set[str] = set()
    for index, item in enumerate(values):
        value = _visible_string(
            item,
            f"{field}[{index}]",
            required=True,
            max_length=200,
        )
        if value in seen:
            continue
        seen.add(value)
        output.append(value)
    if len(output) > 32:
        raise ContentIngestionError(f"{field} may contain at most 32 forms")
    return tuple(output)


def _parse_level(raw: Any, field: str) -> CefrLevel:
    value = _visible_string(raw, field, required=True, max_length=2).upper()
    try:
        return CefrLevel(value)
    except ValueError as exc:
        raise ContentIngestionError(
            f"unsupported CEFR level {value!r}; expected A1, A2, B1, or B2"
        ) from exc


def _item_from_mapping(
    raw: Mapping[str, Any],
    index: int,
) -> IngestedContentItem:
    unknown = sorted(set(raw) - _ALLOWED_FIELDS)
    if unknown:
        raise ContentIngestionError(
            f"items[{index}] has unknown fields: {', '.join(unknown)}"
        )
    missing = sorted(field for field in _REQUIRED_FIELDS if field not in raw)
    if missing:
        raise ContentIngestionError(
            f"items[{index}] is missing required fields: {', '.join(missing)}"
        )

    content_id = _visible_string(
        raw.get("id"),
        f"items[{index}].id",
        required=True,
        max_length=128,
    )
    if not _ID_RE.fullmatch(content_id):
        raise ContentIngestionError(f"items[{index}].id is malformed")

    part_of_speech = _visible_string(
        raw.get("partOfSpeech"),
        f"items[{index}].partOfSpeech",
        default="other",
        max_length=64,
    ).lower()
    if part_of_speech not in _ALLOWED_PARTS_OF_SPEECH:
        raise ContentIngestionError(
            f"items[{index}].partOfSpeech is unsupported: {part_of_speech}"
        )

    register = _visible_string(
        raw.get("register"),
        f"items[{index}].register",
        default="neutral",
        max_length=16,
    ).lower()
    if register not in _ALLOWED_REGISTERS:
        raise ContentIngestionError(
            f"items[{index}].register must be formal, neutral, or informal"
        )

    article = _visible_string(
        raw.get("article"),
        f"items[{index}].article",
        max_length=8,
    ).lower()
    if article not in _ALLOWED_ARTICLES:
        raise ContentIngestionError(
            f"items[{index}].article must be der, die, das, or empty"
        )

    return IngestedContentItem(
        id=content_id,
        level=_parse_level(raw.get("level"), f"items[{index}].level"),
        german=_visible_string(
            raw.get("german"),
            f"items[{index}].german",
            required=True,
        ),
        arabic=_visible_string(
            raw.get("arabic"),
            f"items[{index}].arabic",
            required=True,
        ),
        part_of_speech=part_of_speech,
        article=article,
        plural=_visible_string(
            raw.get("plural"),
            f"items[{index}].plural",
        ),
        example_german=_visible_string(
            raw.get("exampleGerman"),
            f"items[{index}].exampleGerman",
        ),
        example_arabic=_visible_string(
            raw.get("exampleArabic"),
            f"items[{index}].exampleArabic",
        ),
        topic=_visible_string(
            raw.get("topic"),
            f"items[{index}].topic",
            default="general",
            max_length=120,
        ),
        skill=_visible_string(
            raw.get("skill"),
            f"items[{index}].skill",
            default="vocabulary",
            max_length=120,
        ),
        register=register,
        accepted=_accepted_forms(
            raw.get("accepted"),
            f"items[{index}].accepted",
        ),
    )


def _validate_unique_ids(
    items: Iterable[IngestedContentItem],
) -> list[IngestedContentItem]:
    output: list[IngestedContentItem] = []
    seen: set[str] = set()
    for item in items:
        if item.id in seen:
            raise ContentIngestionError(f"duplicate content id: {item.id}")
        seen.add(item.id)
        output.append(item)
    if not output:
        raise ContentIngestionError(
            "content input must contain at least one item"
        )
    return output


def parse_json_text(raw_text: str) -> list[IngestedContentItem]:
    try:
        payload = json.loads(raw_text)
    except json.JSONDecodeError as exc:
        raise ContentIngestionError(f"invalid JSON: {exc.msg}") from exc

    if isinstance(payload, list):
        raw_items = payload
    elif isinstance(payload, dict) and set(payload) == {"items"}:
        raw_items = payload["items"]
    else:
        raise ContentIngestionError(
            'JSON root must be an array or an object containing only "items"'
        )

    if not isinstance(raw_items, list):
        raise ContentIngestionError("items must be an array")

    parsed: list[IngestedContentItem] = []
    for index, raw in enumerate(raw_items):
        if not isinstance(raw, Mapping):
            raise ContentIngestionError(f"items[{index}] must be an object")
        parsed.append(_item_from_mapping(raw, index))
    return _validate_unique_ids(parsed)


def parse_csv_text(raw_text: str) -> list[IngestedContentItem]:
    reader = csv.DictReader(io.StringIO(raw_text.lstrip("\ufeff")))
    if reader.fieldnames is None:
        raise ContentIngestionError("CSV header is missing")

    headers = [header.strip() for header in reader.fieldnames]
    if len(headers) != len(set(headers)):
        raise ContentIngestionError(
            "CSV header contains duplicate columns"
        )
    unknown = sorted(set(headers) - _ALLOWED_FIELDS)
    if unknown:
        raise ContentIngestionError(
            f"CSV has unknown columns: {', '.join(unknown)}"
        )
    missing = sorted(_REQUIRED_FIELDS - set(headers))
    if missing:
        raise ContentIngestionError(
            f"CSV is missing required columns: {', '.join(missing)}"
        )

    parsed: list[IngestedContentItem] = []
    for index, row in enumerate(reader):
        extras = row.get(None)
        if isinstance(extras, list) and any(
            isinstance(value, str) and value.strip()
            for value in extras
        ):
            raise ContentIngestionError(
                f"CSV row {index + 2} contains undeclared cells"
            )

        normalized = {
            key.strip(): value
            for key, value in row.items()
            if key is not None
        }
        if not any(
            isinstance(value, str) and value.strip()
            for value in normalized.values()
        ):
            continue
        parsed.append(_item_from_mapping(normalized, index))
    return _validate_unique_ids(parsed)


def parse_content_file(path: Path) -> list[IngestedContentItem]:
    try:
        raw = path.read_text(encoding="utf-8")
    except (OSError, UnicodeDecodeError) as exc:
        raise ContentIngestionError(
            f"cannot read UTF-8 content source {path}: {exc}"
        ) from exc

    suffix = path.suffix.lower()
    if suffix == ".json":
        return parse_json_text(raw)
    if suffix == ".csv":
        return parse_csv_text(raw)
    raise ContentIngestionError("content source must use .json or .csv")


def _semantic_tags(item: IngestedContentItem) -> list[str]:
    output: list[str] = []
    for candidate in (item.topic, item.skill):
        value = candidate.strip()
        if value and value not in output:
            output.append(value)
    return output


def compile_language_pack_document(
    items: Iterable[IngestedContentItem],
    *,
    pack_id: str,
    version: str,
    display_name: str = "Deutsch بالعربي Content",
) -> dict[str, Any]:
    records = _validate_unique_ids(items)
    clean_pack_id = _visible_string(
        pack_id,
        "pack_id",
        required=True,
        max_length=64,
    )
    clean_version = _visible_string(
        version,
        "version",
        required=True,
        max_length=64,
    )
    clean_display_name = _visible_string(
        display_name,
        "display_name",
        required=True,
        max_length=200,
    )

    lexicon: list[dict[str, Any]] = []
    for item in sorted(records, key=lambda row: row.id):
        lexicon.append(
            {
                "id": item.id,
                "surface": item.german,
                "partOfSpeech": item.part_of_speech,
                "direction": "ltr",
                "fields": {
                    "translation": item.arabic,
                    "example": item.example_german,
                    "exampleTranslation": item.example_arabic,
                    "topic": item.topic,
                    "skill": item.skill,
                    "article": item.article,
                    "plural": item.plural,
                    "accepted": list(item.accepted),
                    "canonical": {
                        "senseId": item.id,
                        "register": item.register,
                        "cefr": item.level.value,
                        "semanticTags": _semantic_tags(item),
                    },
                },
            }
        )

    document: dict[str, Any] = {
        "schemaVersion": 1,
        "pack": {
            "id": clean_pack_id,
            "languageCode": "de",
            "displayName": clean_display_name,
            "version": clean_version,
            "contractVersion": "1.0.0",
            "textDirection": "ltr",
        },
        "requiredLocalizationKeys": ["app.title"],
        "localization": {
            "app.title": {
                "text": "Deutsch بالعربي",
                "direction": "ltr",
                "bidiOverride": False,
            }
        },
        "lexicon": lexicon,
        "grammar": [],
    }

    # Reuse the existing language-pack authority instead of creating a
    # parallel validator. This also normalizes/sorts deterministically.
    try:
        from tools.language_pack_factory import validate_source_document
    except ModuleNotFoundError:
        from language_pack_factory import validate_source_document

    try:
        return validate_source_document(document)
    except ValueError as exc:
        raise ContentIngestionError(
            f"compiled pack rejected: {exc}"
        ) from exc


def level_counts(
    items: Iterable[IngestedContentItem],
) -> dict[str, int]:
    counts = {level.value: 0 for level in CefrLevel}
    for item in items:
        counts[item.level.value] += 1
    return counts


def main(argv: Sequence[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description=(
            "Compile JSON/CSV vocabulary into a canonical offline "
            "language-pack source."
        )
    )
    parser.add_argument("--input", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--pack-id", default="de-core-content")
    parser.add_argument("--version", default="1.0.0")
    parser.add_argument(
        "--display-name",
        default="Deutsch بالعربي Content",
    )
    args = parser.parse_args(argv)

    try:
        items = parse_content_file(args.input)
        document = compile_language_pack_document(
            items,
            pack_id=args.pack_id,
            version=args.version,
            display_name=args.display_name,
        )
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(
            json.dumps(
                document,
                ensure_ascii=False,
                indent=2,
            )
            + "\n",
            encoding="utf-8",
            newline="\n",
        )
        print(
            json.dumps(
                {
                    "status": "compiled",
                    "input": str(args.input),
                    "output": str(args.output),
                    "items": len(items),
                    "levels": level_counts(items),
                },
                ensure_ascii=False,
                sort_keys=True,
            )
        )
        return 0
    except (ContentIngestionError, OSError) as exc:
        print(str(exc), file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
