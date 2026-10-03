#!/usr/bin/env python3
"""Build deterministic, language-neutral offline content packs.

The factory is intentionally dependency-free. It validates raw language input,
emits canonical JSON plus SQLite, wraps both in the runtime json-gzip-v1
envelope, calculates SHA-256, and writes a PackManagerService-compatible
catalog manifest.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import sqlite3
import sys
import unicodedata
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Iterable, Mapping, Sequence
from urllib.parse import urlparse

try:
    from tools.language_pack_artifacts import (
        canonical_json_bytes as _canonical_json_bytes,
        runtime_envelope as _runtime_envelope,
    )
    from tools.language_pack_sqlite import build_sqlite_bytes
except ModuleNotFoundError:
    from language_pack_artifacts import (
        canonical_json_bytes as _canonical_json_bytes,
        runtime_envelope as _runtime_envelope,
    )
    from language_pack_sqlite import build_sqlite_bytes

try:
    from tools.pack_manifest_signing import PackManifestSigningError, sign_catalog
except ModuleNotFoundError:
    from pack_manifest_signing import PackManifestSigningError, sign_catalog

try:
    from tools.german_linguistic_qa import (
        GermanLinguisticQaError,
        assert_german_source,
        assert_german_sqlite,
    )
except ModuleNotFoundError:
    from german_linguistic_qa import (
        GermanLinguisticQaError,
        assert_german_source,
        assert_german_sqlite,
    )

FACTORY_SCHEMA_VERSION = 1
RUNTIME_MANIFEST_SCHEMA_VERSION = 2
BUNDLE_FORMAT = "json-gzip-v1"
PACK_CONTRACT_VERSION = "1.0.0"
SQLITE_SCHEMA_VERSION = 3
CANONICAL_SCHEMA_VERSION = 2
_ALLOWED_DIRECTION = {"ltr", "rtl"}
_PACK_ID_RE = re.compile(r"^[a-z0-9][a-z0-9._-]{1,63}$")
_LANGUAGE_RE = re.compile(r"^[A-Za-z]{2,8}(?:-[A-Za-z0-9]{1,8})*$")
_ENTRY_ID_RE = re.compile(r"^[A-Za-z0-9][A-Za-z0-9._:-]{0,127}$")
_FALLBACK_RE = re.compile(
    r"(?:__TEMPLATE_TEXT__|<untranslated>|TRANSLATE_ME|\\bTODO\\b|\\bTBD\\b)",
    re.IGNORECASE,
)
_GRAMMAR_NODE_TYPES = {"rule", "sequence", "choice", "token", "reference"}


class PackFactoryValidationError(ValueError):
    """Raised when source language data cannot be safely packaged."""


@dataclass(frozen=True)
class CompiledPack:
    descriptor: dict[str, Any]
    archive_path: Path
    sqlite_path: Path
    canonical_json_path: Path


def _require_mapping(value: Any, path: str) -> Mapping[str, Any]:
    if not isinstance(value, Mapping):
        raise PackFactoryValidationError(f"{path} must be an object")
    return value


def _require_list(value: Any, path: str) -> list[Any]:
    if not isinstance(value, list):
        raise PackFactoryValidationError(f"{path} must be a list")
    return value


def _require_string(value: Any, path: str, *, max_length: int = 2000) -> str:
    if not isinstance(value, str):
        raise PackFactoryValidationError(f"{path} must be a string")
    clean = value.strip()
    if not clean or len(clean) > max_length:
        raise PackFactoryValidationError(f"{path} must be non-empty and <= {max_length} chars")
    return clean


def _reject_unknown_keys(
    value: Mapping[str, Any],
    allowed: set[str],
    path: str,
) -> None:
    unknown = sorted(set(value) - allowed)
    if unknown:
        raise PackFactoryValidationError(f"{path} has unknown keys: {', '.join(unknown)}")


def _strong_direction(text: str) -> str | None:
    for char in text:
        bidi = unicodedata.bidirectional(char)
        if bidi in {"R", "AL"}:
            return "rtl"
        if bidi == "L":
            return "ltr"
    return None


def _validate_text_direction(
    text: str,
    declared: str,
    path: str,
    *,
    override: bool = False,
) -> None:
    if declared not in _ALLOWED_DIRECTION:
        raise PackFactoryValidationError(f"{path}.direction must be ltr or rtl")
    if override:
        return
    actual = _strong_direction(text)
    if actual is not None and actual != declared:
        raise PackFactoryValidationError(
            f"{path} starts with {actual} text but declares {declared}; "
            "set bidiOverride=true only for an intentional boundary exception"
        )


def _contains_fallback(text: str) -> bool:
    return bool(_FALLBACK_RE.search(text))


def _validate_localization(
    localization: Any,
    required_keys: set[str],
    pack_direction: str,
) -> dict[str, dict[str, Any]]:
    raw = _require_mapping(localization, "localization")
    missing = sorted(required_keys - set(raw))
    if missing:
        raise PackFactoryValidationError(
            f"localization is missing required keys: {', '.join(missing)}"
        )

    normalized: dict[str, dict[str, Any]] = {}
    for key in sorted(raw):
        if not isinstance(key, str) or not key.strip():
            raise PackFactoryValidationError("localization keys must be non-empty strings")
        entry = _require_mapping(raw[key], f"localization.{key}")
        _reject_unknown_keys(entry, {"text", "direction", "bidiOverride"}, f"localization.{key}")
        text = _require_string(entry.get("text"), f"localization.{key}.text")
        direction = _require_string(
            entry.get("direction"),
            f"localization.{key}.direction",
            max_length=3,
        ).lower()
        override = entry.get("bidiOverride", False)
        if not isinstance(override, bool):
            raise PackFactoryValidationError(
                f"localization.{key}.bidiOverride must be boolean"
            )
        if _contains_fallback(text) or (text == key and "." in key):
            raise PackFactoryValidationError(
                f"localization.{key} contains an untranslated fallback token"
            )
        if direction != pack_direction and not override:
            raise PackFactoryValidationError(
                f"localization.{key}.direction must match pack textDirection"
            )
        _validate_text_direction(
            text,
            direction,
            f"localization.{key}",
            override=override,
        )
        normalized[key] = {
            "text": text,
            "direction": direction,
            "bidiOverride": override,
        }
    return normalized



_CANONICAL_REGISTERS = {"neutral", "formal", "informal", "colloquial", "written", "academic", "unknown"}
_CEFR_LEVELS = {"unknown", "A1", "A2", "B1", "B2", "C1", "C2"}
_GERMAN_GENDERS = {"masculine", "feminine", "neuter", "none", "unknown"}
_NOUN_DECLENSIONS = {"strong", "weak", "mixed", "irregular", "invariant", "unknown"}
_GERMAN_CASES = {"nominative", "accusative", "dative", "genitive"}
_GERMAN_AUXILIARIES = {"haben", "sein", "haben_or_sein", "unknown"}
_GERMAN_REFLEXIVITY = {"none", "accusative", "dative", "context_dependent", "unknown"}


def _optional_string(value: Any, path: str, *, max_length: int = 2000) -> str | None:
    if value is None:
        return None
    return _require_string(value, path, max_length=max_length)


def _enum_string(value: Any, allowed: set[str], path: str, *, default: str) -> str:
    if value is None:
        return default
    clean = _require_string(value, path, max_length=64)
    if clean not in allowed:
        raise PackFactoryValidationError(f"{path} must be one of {sorted(allowed)}")
    return clean


def _normalize_canonical_fields(
    fields: Mapping[str, Any],
    path: str,
    part_of_speech: str,
) -> dict[str, Any]:
    normalized = dict(fields)
    raw = fields.get("canonical")
    if raw is None:
        return normalized

    canonical = _require_mapping(raw, f"{path}.canonical")
    _reject_unknown_keys(
        canonical,
        {"senseId", "register", "cefr", "semanticTags", "noun", "verb", "wordFamily"},
        f"{path}.canonical",
    )
    sense_id = _optional_string(
        canonical.get("senseId"),
        f"{path}.canonical.senseId",
        max_length=160,
    )
    register = _enum_string(
        canonical.get("register"),
        _CANONICAL_REGISTERS,
        f"{path}.canonical.register",
        default="neutral",
    )
    cefr = _enum_string(
        canonical.get("cefr"),
        _CEFR_LEVELS,
        f"{path}.canonical.cefr",
        default="unknown",
    )
    tags_raw = canonical.get("semanticTags", [])
    tags = _require_list(tags_raw, f"{path}.canonical.semanticTags")
    semantic_tags = [
        _require_string(item, f"{path}.canonical.semanticTags[{index}]", max_length=80)
        for index, item in enumerate(tags)
    ]
    if len(semantic_tags) != len(set(semantic_tags)):
        raise PackFactoryValidationError(
            f"{path}.canonical.semanticTags contains duplicates"
        )

    canonical_out: dict[str, Any] = {
        "register": register,
        "cefr": cefr,
        "semanticTags": semantic_tags,
    }
    if sense_id is not None:
        canonical_out["senseId"] = sense_id

    noun_raw = canonical.get("noun")
    if noun_raw is not None:
        if part_of_speech.lower() != "noun":
            raise PackFactoryValidationError(
                f"{path}.canonical.noun requires partOfSpeech noun"
            )
        noun = _require_mapping(noun_raw, f"{path}.canonical.noun")
        _reject_unknown_keys(
            noun,
            {"gender", "plural", "declensionClass", "caseForms"},
            f"{path}.canonical.noun",
        )
        forms = _require_mapping(
            noun.get("caseForms"),
            f"{path}.canonical.noun.caseForms",
        )
        allowed_forms = {
            "nominativeSingular",
            "accusativeSingular",
            "dativeSingular",
            "genitiveSingular",
            "nominativePlural",
            "accusativePlural",
            "dativePlural",
            "genitivePlural",
        }
        _reject_unknown_keys(
            forms,
            allowed_forms,
            f"{path}.canonical.noun.caseForms",
        )
        required_forms = (
            "nominativeSingular",
            "accusativeSingular",
            "dativeSingular",
            "genitiveSingular",
        )
        normalized_forms = {
            key: _require_string(
                forms.get(key),
                f"{path}.canonical.noun.caseForms.{key}",
            )
            for key in required_forms
        }
        for key in sorted(allowed_forms - set(required_forms)):
            value = _optional_string(
                forms.get(key),
                f"{path}.canonical.noun.caseForms.{key}",
            )
            if value is not None:
                normalized_forms[key] = value

        canonical_out["noun"] = {
            "gender": _enum_string(
                noun.get("gender"),
                _GERMAN_GENDERS,
                f"{path}.canonical.noun.gender",
                default="unknown",
            ),
            "plural": _optional_string(
                noun.get("plural"),
                f"{path}.canonical.noun.plural",
            ),
            "declensionClass": _enum_string(
                noun.get("declensionClass"),
                _NOUN_DECLENSIONS,
                f"{path}.canonical.noun.declensionClass",
                default="unknown",
            ),
            "caseForms": normalized_forms,
        }

    verb_raw = canonical.get("verb")
    if verb_raw is not None:
        if part_of_speech.lower() != "verb":
            raise PackFactoryValidationError(
                f"{path}.canonical.verb requires partOfSpeech verb"
            )
        verb = _require_mapping(verb_raw, f"{path}.canonical.verb")
        _reject_unknown_keys(
            verb,
            {
                "infinitive",
                "separablePrefix",
                "inseparablePrefix",
                "reflexivity",
                "auxiliary",
                "participleII",
                "preterite",
                "imperative",
                "valencyFrames",
                "forms",
            },
            f"{path}.canonical.verb",
        )
        frames_raw = _require_list(
            verb.get("valencyFrames", []),
            f"{path}.canonical.verb.valencyFrames",
        )
        frames: list[dict[str, Any]] = []
        frame_ids: set[str] = set()
        for index, frame_raw in enumerate(frames_raw):
            frame_path = f"{path}.canonical.verb.valencyFrames[{index}]"
            frame = _require_mapping(frame_raw, frame_path)
            _reject_unknown_keys(
                frame,
                {
                    "id",
                    "governedCase",
                    "preposition",
                    "prepositionCase",
                    "semanticRole",
                    "objectRequired",
                },
                frame_path,
            )
            frame_id = _require_string(frame.get("id"), f"{frame_path}.id", max_length=80)
            if frame_id in frame_ids:
                raise PackFactoryValidationError(f"{frame_path}.id is duplicated")
            frame_ids.add(frame_id)
            governed_case = frame.get("governedCase")
            preposition_case = frame.get("prepositionCase")
            preposition = _optional_string(
                frame.get("preposition"),
                f"{frame_path}.preposition",
                max_length=80,
            )
            governed = None if governed_case is None else _enum_string(
                governed_case,
                _GERMAN_CASES,
                f"{frame_path}.governedCase",
                default="nominative",
            )
            prep_case = None if preposition_case is None else _enum_string(
                preposition_case,
                _GERMAN_CASES,
                f"{frame_path}.prepositionCase",
                default="nominative",
            )
            if governed is None and not (preposition and prep_case):
                raise PackFactoryValidationError(
                    f"{frame_path} requires governedCase or preposition+prepositionCase"
                )
            object_required = frame.get("objectRequired", True)
            if not isinstance(object_required, bool):
                raise PackFactoryValidationError(
                    f"{frame_path}.objectRequired must be boolean"
                )
            frames.append(
                {
                    "id": frame_id,
                    "governedCase": governed,
                    "preposition": preposition,
                    "prepositionCase": prep_case,
                    "semanticRole": _require_string(
                        frame.get("semanticRole"),
                        f"{frame_path}.semanticRole",
                        max_length=80,
                    ),
                    "objectRequired": object_required,
                }
            )

        forms_raw = _require_list(
            verb.get("forms", []),
            f"{path}.canonical.verb.forms",
        )
        forms: list[dict[str, str]] = []
        form_keys: set[tuple[str, str]] = set()
        for index, form_raw in enumerate(forms_raw):
            form_path = f"{path}.canonical.verb.forms[{index}]"
            form = _require_mapping(form_raw, form_path)
            _reject_unknown_keys(form, {"tense", "personKey", "form"}, form_path)
            tense = _require_string(form.get("tense"), f"{form_path}.tense", max_length=40)
            person_key = _require_string(
                form.get("personKey"),
                f"{form_path}.personKey",
                max_length=40,
            )
            key = (tense, person_key)
            if key in form_keys:
                raise PackFactoryValidationError(f"{form_path} duplicates tense/personKey")
            form_keys.add(key)
            forms.append(
                {
                    "tense": tense,
                    "personKey": person_key,
                    "form": _require_string(form.get("form"), f"{form_path}.form"),
                }
            )

        canonical_out["verb"] = {
            "infinitive": _require_string(
                verb.get("infinitive"),
                f"{path}.canonical.verb.infinitive",
            ),
            "separablePrefix": _optional_string(
                verb.get("separablePrefix"),
                f"{path}.canonical.verb.separablePrefix",
                max_length=80,
            ),
            "inseparablePrefix": _optional_string(
                verb.get("inseparablePrefix"),
                f"{path}.canonical.verb.inseparablePrefix",
                max_length=80,
            ),
            "reflexivity": _enum_string(
                verb.get("reflexivity"),
                _GERMAN_REFLEXIVITY,
                f"{path}.canonical.verb.reflexivity",
                default="none",
            ),
            "auxiliary": _enum_string(
                verb.get("auxiliary"),
                _GERMAN_AUXILIARIES,
                f"{path}.canonical.verb.auxiliary",
                default="unknown",
            ),
            "participleII": _optional_string(
                verb.get("participleII"),
                f"{path}.canonical.verb.participleII",
            ),
            "preterite": _optional_string(
                verb.get("preterite"),
                f"{path}.canonical.verb.preterite",
            ),
            "imperative": _optional_string(
                verb.get("imperative"),
                f"{path}.canonical.verb.imperative",
            ),
            "valencyFrames": frames,
            "forms": forms,
        }

    word_family = canonical.get("wordFamily")
    if word_family is not None:
        canonical_out["wordFamily"] = dict(
            _require_mapping(word_family, f"{path}.canonical.wordFamily")
        )

    normalized["canonical"] = canonical_out
    return normalized


def _validate_lexicon(
    lexicon: Any,
    pack_direction: str,
) -> list[dict[str, Any]]:
    raw = _require_list(lexicon, "lexicon")
    if not raw:
        raise PackFactoryValidationError("lexicon must contain at least one entry")

    seen: set[str] = set()
    normalized: list[dict[str, Any]] = []
    for index, value in enumerate(raw):
        path = f"lexicon[{index}]"
        entry = _require_mapping(value, path)
        _reject_unknown_keys(
            entry,
            {"id", "surface", "partOfSpeech", "direction", "bidiOverride", "fields"},
            path,
        )
        entry_id = _require_string(entry.get("id"), f"{path}.id", max_length=128)
        if not _ENTRY_ID_RE.fullmatch(entry_id):
            raise PackFactoryValidationError(f"{path}.id is malformed")
        if entry_id in seen:
            raise PackFactoryValidationError(f"duplicate lexicon id: {entry_id}")
        seen.add(entry_id)

        surface = _require_string(entry.get("surface"), f"{path}.surface")
        part_of_speech = _require_string(
            entry.get("partOfSpeech"),
            f"{path}.partOfSpeech",
            max_length=64,
        )
        direction = _require_string(
            entry.get("direction"),
            f"{path}.direction",
            max_length=3,
        ).lower()
        override = entry.get("bidiOverride", False)
        if not isinstance(override, bool):
            raise PackFactoryValidationError(f"{path}.bidiOverride must be boolean")
        fields = entry.get("fields", {})
        if not isinstance(fields, Mapping):
            raise PackFactoryValidationError(f"{path}.fields must be an object")
        fields = _normalize_canonical_fields(fields, path, part_of_speech)

        if direction != pack_direction and not override:
            raise PackFactoryValidationError(
                f"{path}.direction must match pack textDirection"
            )
        if _contains_fallback(surface):
            raise PackFactoryValidationError(f"{path}.surface contains fallback content")
        _validate_text_direction(surface, direction, path, override=override)
        _reject_fallbacks_recursive(fields, f"{path}.fields")

        normalized.append(
            {
                "id": entry_id,
                "surface": surface,
                "partOfSpeech": part_of_speech,
                "direction": direction,
                "bidiOverride": override,
                "fields": dict(fields),
            }
        )
    return sorted(normalized, key=lambda item: item["id"])


def _reject_fallbacks_recursive(value: Any, path: str) -> None:
    if isinstance(value, str):
        if _contains_fallback(value):
            raise PackFactoryValidationError(f"{path} contains fallback content")
        return
    if isinstance(value, Mapping):
        for key, child in value.items():
            _reject_fallbacks_recursive(child, f"{path}.{key}")
        return
    if isinstance(value, list):
        for index, child in enumerate(value):
            _reject_fallbacks_recursive(child, f"{path}[{index}]")


def _validate_grammar_tree(node: Any, path: str, *, depth: int = 0) -> dict[str, Any]:
    if depth > 32:
        raise PackFactoryValidationError(f"{path} exceeds maximum grammar depth")
    value = _require_mapping(node, path)
    _reject_unknown_keys(value, {"type", "value", "children", "features"}, path)

    node_type = _require_string(value.get("type"), f"{path}.type", max_length=32)
    if node_type not in _GRAMMAR_NODE_TYPES:
        raise PackFactoryValidationError(
            f"{path}.type must be one of {sorted(_GRAMMAR_NODE_TYPES)}"
        )

    raw_children = value.get("children", [])
    children = _require_list(raw_children, f"{path}.children")
    raw_value = value.get("value")
    if node_type in {"token", "reference"}:
        text_value = _require_string(raw_value, f"{path}.value")
        if children:
            raise PackFactoryValidationError(
                f"{path} leaf nodes cannot contain children"
            )
        if _contains_fallback(text_value):
            raise PackFactoryValidationError(f"{path}.value contains fallback content")
    else:
        text_value = None
        if raw_value not in (None, ""):
            raise PackFactoryValidationError(
                f"{path}.value is only valid for token/reference nodes"
            )
        if not children:
            raise PackFactoryValidationError(
                f"{path} {node_type} nodes require at least one child"
            )

    features = value.get("features", {})
    if not isinstance(features, Mapping):
        raise PackFactoryValidationError(f"{path}.features must be an object")
    _reject_fallbacks_recursive(features, f"{path}.features")

    normalized: dict[str, Any] = {
        "type": node_type,
        "children": [
            _validate_grammar_tree(child, f"{path}.children[{index}]", depth=depth + 1)
            for index, child in enumerate(children)
        ],
        "features": dict(features),
    }
    if text_value is not None:
        normalized["value"] = text_value
    return normalized


def _validate_grammar(
    grammar: Any,
    localization: Mapping[str, Any],
) -> list[dict[str, Any]]:
    raw = _require_list(grammar, "grammar")
    seen: set[str] = set()
    normalized: list[dict[str, Any]] = []

    for index, value in enumerate(raw):
        path = f"grammar[{index}]"
        entry = _require_mapping(value, path)
        _reject_unknown_keys(entry, {"id", "titleKey", "tree"}, path)
        entry_id = _require_string(entry.get("id"), f"{path}.id", max_length=128)
        if not _ENTRY_ID_RE.fullmatch(entry_id):
            raise PackFactoryValidationError(f"{path}.id is malformed")
        if entry_id in seen:
            raise PackFactoryValidationError(f"duplicate grammar id: {entry_id}")
        seen.add(entry_id)

        title_key = _require_string(entry.get("titleKey"), f"{path}.titleKey")
        if title_key not in localization:
            raise PackFactoryValidationError(
                f"{path}.titleKey references missing localization key {title_key}"
            )
        tree = _validate_grammar_tree(entry.get("tree"), f"{path}.tree")
        normalized.append({"id": entry_id, "titleKey": title_key, "tree": tree})

    return sorted(normalized, key=lambda item: item["id"])


def validate_source_document(payload: Any) -> dict[str, Any]:
    root = _require_mapping(payload, "root")
    _reject_unknown_keys(
        root,
        {
            "schemaVersion",
            "pack",
            "requiredLocalizationKeys",
            "localization",
            "lexicon",
            "grammar",
        },
        "root",
    )
    if root.get("schemaVersion") != FACTORY_SCHEMA_VERSION:
        raise PackFactoryValidationError(
            f"schemaVersion must equal {FACTORY_SCHEMA_VERSION}"
        )

    pack = _require_mapping(root.get("pack"), "pack")
    _reject_unknown_keys(
        pack,
        {"id", "languageCode", "displayName", "version", "contractVersion", "textDirection"},
        "pack",
    )
    pack_id = _require_string(pack.get("id"), "pack.id", max_length=64)
    if not _PACK_ID_RE.fullmatch(pack_id):
        raise PackFactoryValidationError("pack.id is malformed")
    language_code = _require_string(
        pack.get("languageCode"),
        "pack.languageCode",
        max_length=64,
    )
    if not _LANGUAGE_RE.fullmatch(language_code):
        raise PackFactoryValidationError("pack.languageCode is malformed")
    display_name = _require_string(pack.get("displayName"), "pack.displayName")
    version = _require_string(pack.get("version"), "pack.version", max_length=64)
    contract_version = _require_string(
        pack.get("contractVersion"),
        "pack.contractVersion",
        max_length=64,
    )
    if contract_version != PACK_CONTRACT_VERSION:
        raise PackFactoryValidationError(
            f"pack.contractVersion must equal {PACK_CONTRACT_VERSION}"
        )
    direction = _require_string(
        pack.get("textDirection"),
        "pack.textDirection",
        max_length=3,
    ).lower()
    if direction not in _ALLOWED_DIRECTION:
        raise PackFactoryValidationError("pack.textDirection must be ltr or rtl")

    required_raw = _require_list(
        root.get("requiredLocalizationKeys"),
        "requiredLocalizationKeys",
    )
    required_keys = {
        _require_string(item, f"requiredLocalizationKeys[{index}]")
        for index, item in enumerate(required_raw)
    }
    if not required_keys:
        raise PackFactoryValidationError(
            "requiredLocalizationKeys must contain at least one key"
        )

    localization = _validate_localization(
        root.get("localization"),
        required_keys,
        direction,
    )
    lexicon = _validate_lexicon(root.get("lexicon"), direction)
    grammar = _validate_grammar(root.get("grammar"), localization)

    return {
        "schemaVersion": FACTORY_SCHEMA_VERSION,
        "pack": {
            "id": pack_id,
            "languageCode": language_code,
            "displayName": display_name,
            "version": version,
            "contractVersion": contract_version,
            "textDirection": direction,
        },
        "requiredLocalizationKeys": sorted(required_keys),
        "localization": localization,
        "lexicon": lexicon,
        "grammar": grammar,
    }


def load_and_validate_source(path: str | Path) -> dict[str, Any]:
    source = Path(path)
    try:
        payload = json.loads(source.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise PackFactoryValidationError(f"cannot load {source}: {exc}") from exc
    document = validate_source_document(payload)
    try:
        assert_german_source(document)
    except GermanLinguisticQaError as exc:
        raise PackFactoryValidationError(str(exc)) from exc
    return document


def _validate_https_base_url(base_url: str) -> str:
    clean = base_url.rstrip("/")
    parsed = urlparse(clean)
    if parsed.scheme != "https" or not parsed.netloc:
        raise PackFactoryValidationError("base URL must be absolute HTTPS")
    return clean


def compile_pack(
    source_path: str | Path,
    output_dir: str | Path,
    *,
    base_url: str,
) -> CompiledPack:
    document = load_and_validate_source(source_path)
    output = Path(output_dir)
    output.mkdir(parents=True, exist_ok=True)
    canonical_dir = output / "canonical"
    sqlite_dir = output / "sqlite"
    bundle_dir = output / "bundles"
    canonical_dir.mkdir(parents=True, exist_ok=True)
    sqlite_dir.mkdir(parents=True, exist_ok=True)
    bundle_dir.mkdir(parents=True, exist_ok=True)

    pack = document["pack"]
    stem = f'{pack["id"]}-{pack["version"]}'
    canonical_json = _canonical_json_bytes(document)
    try:
        sqlite_bytes = build_sqlite_bytes(
            document,
            sqlite_schema_version=SQLITE_SCHEMA_VERSION,
            canonical_schema_version=CANONICAL_SCHEMA_VERSION,
        )
    except GermanLinguisticQaError as exc:
        raise PackFactoryValidationError(str(exc)) from exc
    bundle_bytes, installed_size = _runtime_envelope(
        document,
        canonical_json,
        sqlite_bytes,
    )

    canonical_path = canonical_dir / f"{stem}.json"
    sqlite_path = sqlite_dir / f"{stem}.sqlite"
    archive_path = bundle_dir / f"{stem}.pack.gz"
    canonical_path.write_bytes(canonical_json)
    sqlite_path.write_bytes(sqlite_bytes)
    archive_path.write_bytes(bundle_bytes)

    clean_base = _validate_https_base_url(base_url)
    descriptor = {
        "id": pack["id"],
        "languageCode": pack["languageCode"],
        "displayName": pack["displayName"],
        "version": pack["version"],
        "contractVersion": pack["contractVersion"],
        "bundleFormat": BUNDLE_FORMAT,
        "archiveUrl": f"{clean_base}/{archive_path.name}",
        "sha256": hashlib.sha256(bundle_bytes).hexdigest(),
        "contentSha256": hashlib.sha256(sqlite_bytes).hexdigest(),
        "archiveSizeBytes": len(bundle_bytes),
        "installedSizeBytes": installed_size,
    }
    return CompiledPack(
        descriptor=descriptor,
        archive_path=archive_path,
        sqlite_path=sqlite_path,
        canonical_json_path=canonical_path,
    )


def write_catalog(
    descriptors: Iterable[Mapping[str, Any]],
    path: str | Path,
    *,
    manifest_revision: int,
    signing_key_path: str | Path | None = None,
    key_id: str | None = None,
    allow_unsigned: bool = False,
) -> Path:
    if manifest_revision <= 0:
        raise PackFactoryValidationError("manifest revision must be positive")
    ordered = sorted((dict(item) for item in descriptors), key=lambda item: item["id"])
    ids = [item["id"] for item in ordered]
    if len(ids) != len(set(ids)):
        raise PackFactoryValidationError("catalog contains duplicate pack ids")
    if signing_key_path is None or key_id is None:
        if not allow_unsigned:
            raise PackFactoryValidationError("catalog signing key and key id are required")
        catalog: dict[str, Any] = {
            "schemaVersion": 1,
            "manifestRevision": manifest_revision,
            "packs": ordered,
        }
    else:
        try:
            catalog = sign_catalog(
                packs=ordered,
                manifest_revision=manifest_revision,
                private_key_path=signing_key_path,
                key_id=key_id,
            )
        except PackManifestSigningError as exc:
            raise PackFactoryValidationError(str(exc)) from exc
    destination = Path(path)
    destination.parent.mkdir(parents=True, exist_ok=True)
    destination.write_bytes(_canonical_json_bytes(catalog))
    return destination

def build_catalog(
    source_paths: Sequence[str | Path],
    output_dir: str | Path,
    *,
    base_url: str,
    manifest_revision: int,
    catalog_path: str | Path | None = None,
    signing_key_path: str | Path | None = None,
    key_id: str | None = None,
    allow_unsigned: bool = False,
) -> tuple[list[CompiledPack], Path]:
    if not source_paths:
        raise PackFactoryValidationError("at least one source pack is required")
    compiled = [
        compile_pack(path, output_dir, base_url=base_url)
        for path in source_paths
    ]
    catalog = Path(catalog_path) if catalog_path else Path(output_dir) / "catalog.json"
    write_catalog(
        [pack.descriptor for pack in compiled],
        catalog,
        manifest_revision=manifest_revision,
        signing_key_path=signing_key_path,
        key_id=key_id,
        allow_unsigned=allow_unsigned,
    )
    return compiled, catalog


def main(argv: Sequence[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description="Compile validated language sources into offline JSON/SQLite packs"
    )
    parser.add_argument(
        "--input",
        action="append",
        required=True,
        help="source language JSON; repeat for multiple packs",
    )
    parser.add_argument("--output-dir", required=True)
    parser.add_argument("--base-url", required=True)
    parser.add_argument("--manifest-revision", required=True, type=int)
    parser.add_argument("--catalog")
    parser.add_argument("--signing-key")
    parser.add_argument("--key-id")
    parser.add_argument(
        "--validate-only",
        action="store_true",
        help="validate every input without emitting bundles",
    )
    args = parser.parse_args(argv)

    try:
        if args.validate_only:
            validated = [load_and_validate_source(path) for path in args.input]
            print(
                json.dumps(
                    {
                        "status": "valid",
                        "packs": [item["pack"]["id"] for item in validated],
                    },
                    sort_keys=True,
                )
            )
            return 0

        compiled, catalog = build_catalog(
            args.input,
            args.output_dir,
            base_url=args.base_url,
            manifest_revision=args.manifest_revision,
            catalog_path=args.catalog,
            signing_key_path=args.signing_key,
            key_id=args.key_id,
        )
        print(
            json.dumps(
                {
                    "status": "built",
                    "catalog": str(catalog),
                    "packs": [
                        {
                            "id": pack.descriptor["id"],
                            "sha256": pack.descriptor["sha256"],
                            "archive": str(pack.archive_path),
                        }
                        for pack in compiled
                    ],
                },
                sort_keys=True,
            )
        )
        return 0
    except (PackFactoryValidationError, PackManifestSigningError, OSError, sqlite3.Error) as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
