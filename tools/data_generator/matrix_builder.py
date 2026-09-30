#!/usr/bin/env python3
"""Pure-Python utilities for canonical multilingual matrix seed datasets.

The module intentionally has no third-party runtime dependencies.  It validates
against the checked-in JSON Schema subset used by ``schema.json`` and then
applies semantic invariants that JSON Schema alone cannot express cleanly:
canonical-key uniqueness, directed-pair identity, and language direction tags.
"""

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

# Primary language subtags whose normal horizontal writing direction is RTL.
# The matrix remains language-count agnostic; these tags are only direction
# metadata used for fail-closed validation of seed records.
RTL_LANGUAGE_CODES = frozenset(
    {"ar", "ckb", "dv", "fa", "he", "ps", "sd", "ug", "ur", "yi"}
)


class MatrixValidationError(ValueError):
    """Raised when a matrix dataset violates schema or semantic invariants."""


def _type_matches(value: Any, expected: str) -> bool:
    if expected == "object":
        return isinstance(value, dict)
    if expected == "array":
        return isinstance(value, list)
    if expected == "string":
        return isinstance(value, str)
    if expected == "boolean":
        return isinstance(value, bool)
    if expected == "integer":
        return isinstance(value, int) and not isinstance(value, bool)
    if expected == "number":
        return isinstance(value, (int, float)) and not isinstance(value, bool)
    if expected == "null":
        return value is None
    raise MatrixValidationError(f"unsupported schema type: {expected}")


def _validate_schema(instance: Any, schema: Mapping[str, Any], path: str = "$") -> None:
    """Validate the JSON-Schema keywords used by this repository schema."""

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
            raise MatrixValidationError(f"{path}: string shorter than minLength={min_length}")
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
    return language_code.strip().lower()


def text_direction_for_language(language_code: str) -> str:
    """Return ``rtl`` for known RTL languages, otherwise ``ltr``.

    Direction is determined from the primary BCP-47-style subtag.  This covers
    Arabic and Urdu explicitly while keeping the pair engine generic.
    """

    normalized = _normalize_language_code(language_code)
    primary = normalized.split("-", 1)[0]
    return "rtl" if primary in RTL_LANGUAGE_CODES else "ltr"


def directed_pair_id(source_language: str, target_language: str) -> str:
    source = _normalize_language_code(source_language)
    target = _normalize_language_code(target_language)
    if source == target:
        raise ValueError("source and target language must differ")
    return f"{source}->{target}"


def build_directed_pair_matrix(language_codes: Sequence[str]) -> tuple[str, ...]:
    """Return all ordered non-self pairs for the supplied languages.

    Twenty unique languages produce 20 * 19 = 380 directed pairs.  No reverse
    direction is inferred from a content record; this utility only constructs
    pair identities.
    """

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
    """Group each unordered language pair into its two explicit directions."""

    normalized = tuple(_normalize_language_code(code) for code in language_codes)
    if len(normalized) < 2:
        raise ValueError("at least two languages are required")
    if len(set(normalized)) != len(normalized):
        raise ValueError("duplicate language code in matrix input")
    return tuple(
        (directed_pair_id(left, right), directed_pair_id(right, left))
        for left, right in combinations(normalized, 2)
    )


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


def build_seed_dataset(entries: Iterable[Mapping[str, Any]]) -> dict[str, Any]:
    """Create the canonical top-level dataset envelope without mutating entries."""

    return {"schema_version": SCHEMA_VERSION, "entries": [dict(entry) for entry in entries]}


def _canonical_key_fingerprint(value: str) -> str:
    return unicodedata.normalize("NFKC", value).strip().casefold()


def _validate_semantics(dataset: Mapping[str, Any]) -> None:
    seen_keys: dict[str, str] = {}
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
                f"$.entries[{index}].pair_identity.id: expected {expected_id!r}, "
                f"got {pair['id']!r}"
            )

        expected_source_direction = text_direction_for_language(source)
        if pair["source_direction"] != expected_source_direction:
            raise MatrixValidationError(
                f"$.entries[{index}].pair_identity.source_direction: expected "
                f"{expected_source_direction!r} for {source!r}"
            )

        expected_target_direction = text_direction_for_language(target)
        if pair["target_direction"] != expected_target_direction:
            raise MatrixValidationError(
                f"$.entries[{index}].pair_identity.target_direction: expected "
                f"{expected_target_direction!r} for {target!r}"
            )


def validate_dataset(
    dataset: Mapping[str, Any], *, schema_path: str | Path = DEFAULT_SCHEMA_PATH
) -> None:
    """Validate a dataset against the checked-in schema and semantic invariants."""

    schema = json.loads(Path(schema_path).read_text(encoding="utf-8"))
    _validate_schema(dataset, schema)
    _validate_semantics(dataset)


def load_and_validate(
    dataset_path: str | Path, *, schema_path: str | Path = DEFAULT_SCHEMA_PATH
) -> dict[str, Any]:
    path = Path(dataset_path)
    dataset = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(dataset, dict):
        raise MatrixValidationError("$: dataset root must be an object")
    validate_dataset(dataset, schema_path=schema_path)
    return dataset


def _main() -> int:
    parser = argparse.ArgumentParser(description="Validate a language-matrix seed dataset")
    parser.add_argument("dataset", type=Path, help="JSON dataset to validate")
    parser.add_argument("--schema", type=Path, default=DEFAULT_SCHEMA_PATH)
    args = parser.parse_args()

    dataset = load_and_validate(args.dataset, schema_path=args.schema)
    print(
        f"VALID schema={dataset['schema_version']} entries={len(dataset['entries'])} "
        f"file={args.dataset}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(_main())
