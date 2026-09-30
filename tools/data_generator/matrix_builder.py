#!/usr/bin/env python3
"""Pure-Python 20-language matrix dataset generation and ingestion helpers."""

from __future__ import annotations

import argparse
import json
import re
import unicodedata
from itertools import combinations
from pathlib import Path
from typing import Any, Iterable, Mapping, Sequence

SCHEMA_VERSION = "1.0.0"
DEFAULT_SCHEMA_PATH = Path(__file__).with_name("schema.json")
RTL_LANGUAGE_CODES = frozenset(
    {"ar", "ckb", "dv", "fa", "he", "ps", "sd", "ug", "ur", "yi"}
)


class MatrixValidationError(ValueError):
    """Raised when schema or multilingual semantic invariants are violated."""


def _type_matches(value: Any, expected: str) -> bool:
    if expected == "object":
        return isinstance(value, dict)
    if expected == "array":
        return isinstance(value, list)
    if expected == "string":
        return isinstance(value, str)
    if expected == "boolean":
        return isinstance(value, bool)
    raise MatrixValidationError(f"unsupported schema type: {expected}")


def _validate_schema(instance: Any, schema: Mapping[str, Any], path: str = "$") -> None:
    expected_type = schema.get("type")
    if expected_type is not None and not _type_matches(instance, expected_type):
        raise MatrixValidationError(
            f"{path}: expected {expected_type}, got {type(instance).__name__}"
        )

    if "const" in schema and instance != schema["const"]:
        raise MatrixValidationError(f"{path}: expected constant {schema['const']!r}")
    if "enum" in schema and instance not in schema["enum"]:
        raise MatrixValidationError(f"{path}: value {instance!r} is not in enum")

    if isinstance(instance, str):
        min_length = schema.get("minLength")
        if min_length is not None and len(instance) < min_length:
            raise MatrixValidationError(
                f"{path}: string shorter than minLength={min_length}"
            )
        pattern = schema.get("pattern")
        if pattern is not None and re.fullmatch(pattern, instance) is None:
            raise MatrixValidationError(f"{path}: value {instance!r} does not match pattern")

    if isinstance(instance, list):
        min_items = schema.get("minItems")
        if min_items is not None and len(instance) < min_items:
            raise MatrixValidationError(f"{path}: array shorter than minItems={min_items}")
        item_schema = schema.get("items")
        if item_schema is not None:
            for index, item in enumerate(instance):
                _validate_schema(item, item_schema, f"{path}[{index}]")

    if isinstance(instance, dict):
        properties = schema.get("properties", {})
        for required_key in schema.get("required", []):
            if required_key not in instance:
                raise MatrixValidationError(f"{path}.{required_key}: required property missing")
        if schema.get("additionalProperties") is False:
            unexpected = sorted(set(instance) - set(properties))
            if unexpected:
                raise MatrixValidationError(
                    f"{path}: unexpected properties: {', '.join(unexpected)}"
                )
        for key, value in instance.items():
            child_schema = properties.get(key)
            if child_schema is not None:
                _validate_schema(value, child_schema, f"{path}.{key}")


def _normalize_language_code(language_code: str) -> str:
    if not isinstance(language_code, str) or not language_code.strip():
        raise ValueError("language code must be a non-empty string")
    normalized = language_code.strip().lower()
    if re.fullmatch(r"[a-z]{2,3}(?:-[a-z0-9]{2,8})*", normalized) is None:
        raise ValueError(f"invalid language code: {language_code!r}")
    return normalized


def text_direction_for_language(language_code: str) -> str:
    normalized = _normalize_language_code(language_code)
    primary = normalized.split("-", 1)[0]
    return "rtl" if primary in RTL_LANGUAGE_CODES else "ltr"


def directed_pair_id(source_language: str, target_language: str) -> str:
    source = _normalize_language_code(source_language)
    target = _normalize_language_code(target_language)
    if source == target:
        raise ValueError("source and target language must differ")
    return f"{source}->{target}"


def make_pair_identity(source_language: str, target_language: str) -> dict[str, str]:
    source = _normalize_language_code(source_language)
    target = _normalize_language_code(target_language)
    return {
        "id": directed_pair_id(source, target),
        "source_language": source,
        "target_language": target,
        "source_direction": text_direction_for_language(source),
        "target_direction": text_direction_for_language(target),
    }


def pair_requires_rtl(source_language: str, target_language: str) -> bool:
    return (
        text_direction_for_language(source_language) == "rtl"
        or text_direction_for_language(target_language) == "rtl"
    )


def build_directed_pair_matrix(language_codes: Sequence[str]) -> tuple[str, ...]:
    normalized = tuple(_normalize_language_code(code) for code in language_codes)
    if len(normalized) < 2:
        raise ValueError("at least two languages are required")
    if len(set(normalized)) != len(normalized):
        raise ValueError("duplicate language code in matrix input")
    return tuple(
        directed_pair_id(source, target)
        for source in normalized
        for target in normalized
        if source != target
    )


def build_bidirectional_pair_sets(
    language_codes: Sequence[str],
) -> tuple[tuple[str, str], ...]:
    normalized = tuple(_normalize_language_code(code) for code in language_codes)
    if len(normalized) < 2:
        raise ValueError("at least two languages are required")
    if len(set(normalized)) != len(normalized):
        raise ValueError("duplicate language code in matrix input")
    return tuple(
        (directed_pair_id(left, right), directed_pair_id(right, left))
        for left, right in combinations(normalized, 2)
    )


def make_entry(
    *,
    canonical_key: str,
    cefr_level: str,
    source_text: str,
    target_text: str,
    source_language: str,
    target_language: str,
    source_phonetics: str,
    target_phonetics: str,
    part_of_speech: str,
    bidirectional_flag: bool,
) -> dict[str, Any]:
    return {
        "canonical_key": canonical_key,
        "cefr_level": cefr_level,
        "source_text": source_text,
        "target_text": target_text,
        "pair_identity": make_pair_identity(source_language, target_language),
        "phonetics": {"source": source_phonetics, "target": target_phonetics},
        "part_of_speech": part_of_speech,
        "bidirectional_flag": bidirectional_flag,
        "rtl_flag": pair_requires_rtl(source_language, target_language),
    }


def generate_bidirectional_pair(
    *,
    canonical_key: str,
    cefr_level: str,
    source_text: str,
    target_text: str,
    source_language: str,
    target_language: str,
    source_phonetics: str,
    target_phonetics: str,
    part_of_speech: str,
) -> tuple[dict[str, Any], dict[str, Any]]:
    """Generate two explicit directed records; no reverse direction is implicit."""
    forward = make_entry(
        canonical_key=f"{canonical_key}.forward",
        cefr_level=cefr_level,
        source_text=source_text,
        target_text=target_text,
        source_language=source_language,
        target_language=target_language,
        source_phonetics=source_phonetics,
        target_phonetics=target_phonetics,
        part_of_speech=part_of_speech,
        bidirectional_flag=True,
    )
    reverse = make_entry(
        canonical_key=f"{canonical_key}.reverse",
        cefr_level=cefr_level,
        source_text=target_text,
        target_text=source_text,
        source_language=target_language,
        target_language=source_language,
        source_phonetics=target_phonetics,
        target_phonetics=source_phonetics,
        part_of_speech=part_of_speech,
        bidirectional_flag=True,
    )
    return forward, reverse


def build_seed_dataset(entries: Iterable[Mapping[str, Any]]) -> dict[str, Any]:
    return {"schema_version": SCHEMA_VERSION, "entries": [dict(entry) for entry in entries]}


def _canonical_key_fingerprint(value: str) -> str:
    return unicodedata.normalize("NFKC", value).strip().casefold()


def _reverse_signature(entry: Mapping[str, Any]) -> tuple[str, str, str, str]:
    pair = entry["pair_identity"]
    return (
        pair["target_language"],
        pair["source_language"],
        entry["target_text"],
        entry["source_text"],
    )


def _entry_signature(entry: Mapping[str, Any]) -> tuple[str, str, str, str]:
    pair = entry["pair_identity"]
    return (
        pair["source_language"],
        pair["target_language"],
        entry["source_text"],
        entry["target_text"],
    )


def _validate_semantics(dataset: Mapping[str, Any]) -> None:
    seen_keys: dict[str, str] = {}
    signatures = {_entry_signature(entry) for entry in dataset["entries"]}

    for index, entry in enumerate(dataset["entries"]):
        canonical_key = entry["canonical_key"]
        fingerprint = _canonical_key_fingerprint(canonical_key)
        if fingerprint in seen_keys:
            raise MatrixValidationError(
                f"$.entries[{index}].canonical_key: duplicate canonical_key "
                f"{canonical_key!r}; first seen as {seen_keys[fingerprint]!r}"
            )
        seen_keys[fingerprint] = canonical_key

        pair = entry["pair_identity"]
        source = _normalize_language_code(pair["source_language"])
        target = _normalize_language_code(pair["target_language"])
        if source == target:
            raise MatrixValidationError(
                f"$.entries[{index}].pair_identity: source and target language must differ"
            )

        expected_id = directed_pair_id(source, target)
        if pair["id"] != expected_id:
            raise MatrixValidationError(
                f"$.entries[{index}].pair_identity.id: expected {expected_id!r}, got {pair['id']!r}"
            )

        expected_source_direction = text_direction_for_language(source)
        expected_target_direction = text_direction_for_language(target)
        if pair["source_direction"] != expected_source_direction:
            raise MatrixValidationError(
                f"$.entries[{index}].pair_identity.source_direction: expected "
                f"{expected_source_direction!r} for {source!r}"
            )
        if pair["target_direction"] != expected_target_direction:
            raise MatrixValidationError(
                f"$.entries[{index}].pair_identity.target_direction: expected "
                f"{expected_target_direction!r} for {target!r}"
            )

        expected_rtl = pair_requires_rtl(source, target)
        if entry["rtl_flag"] is not expected_rtl:
            raise MatrixValidationError(
                f"$.entries[{index}].rtl_flag: expected {expected_rtl!r} for {expected_id!r}"
            )

        if entry["bidirectional_flag"] and _reverse_signature(entry) not in signatures:
            raise MatrixValidationError(
                f"$.entries[{index}].bidirectional_flag: explicit reciprocal record missing"
            )


def validate_dataset(
    dataset: Mapping[str, Any], *, schema_path: str | Path = DEFAULT_SCHEMA_PATH
) -> None:
    schema = json.loads(Path(schema_path).read_text(encoding="utf-8"))
    _validate_schema(dataset, schema)
    _validate_semantics(dataset)


def load_and_validate(
    dataset_path: str | Path, *, schema_path: str | Path = DEFAULT_SCHEMA_PATH
) -> dict[str, Any]:
    dataset = json.loads(Path(dataset_path).read_text(encoding="utf-8"))
    if not isinstance(dataset, dict):
        raise MatrixValidationError("$: dataset root must be an object")
    validate_dataset(dataset, schema_path=schema_path)
    return dataset


def ingest_datasets(
    dataset_paths: Iterable[str | Path], *, schema_path: str | Path = DEFAULT_SCHEMA_PATH
) -> dict[str, Any]:
    entries: list[Mapping[str, Any]] = []
    for path in dataset_paths:
        validated = load_and_validate(path, schema_path=schema_path)
        entries.extend(validated["entries"])
    combined = build_seed_dataset(entries)
    validate_dataset(combined, schema_path=schema_path)
    return combined


def _main() -> int:
    parser = argparse.ArgumentParser(description="Validate a language-matrix dataset")
    parser.add_argument("dataset", type=Path, nargs="+", help="JSON dataset(s) to validate/ingest")
    parser.add_argument("--schema", type=Path, default=DEFAULT_SCHEMA_PATH)
    args = parser.parse_args()

    dataset = ingest_datasets(args.dataset, schema_path=args.schema)
    print(f"VALID schema={dataset['schema_version']} entries={len(dataset['entries'])}")
    return 0


if __name__ == "__main__":
    raise SystemExit(_main())
