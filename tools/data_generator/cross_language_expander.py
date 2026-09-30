#!/usr/bin/env python3
"""Expand canonical DE/AR concepts into explicit cross-language pair skeletons.

The expander deliberately does not translate missing languages.  It projects stable
concept identities and known endpoint data, and emits deterministic template markers
for language realizations that still need language-owned authoring/verification.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Any, Mapping, Sequence

REPO_ROOT = Path(__file__).resolve().parents[2]
if str(REPO_ROOT) not in sys.path:
    sys.path.insert(0, str(REPO_ROOT))


from tools.data_generator.matrix_builder import (
    make_entry,
    text_direction_for_language,
    validate_dataset,
)

SCHEMA_VERSION = "1.0.0"
HERE = Path(__file__).resolve().parent
DEFAULT_REFERENCE_DATASET = HERE / "fixtures" / "de_ar_a1_core.json"
DEFAULT_SCHEMA_PATH = HERE / "schema.json"
DEFAULT_OUTPUT_DIR = HERE / "output" / "matrix_skeletons"
DEFAULT_PAIRS = (("de", "en"), ("en", "ar"))
_LANGUAGE_RE = re.compile(r"^[a-z]{2,3}(?:-[a-z0-9]{2,8})*$")


class PairExpansionError(ValueError):
    """Raised when reference data cannot be projected without ambiguity."""


def _normalize_language(language: str) -> str:
    if not isinstance(language, str) or not language.strip():
        raise PairExpansionError("language code must be a non-empty string")
    normalized = language.strip().lower()
    if _LANGUAGE_RE.fullmatch(normalized) is None:
        raise PairExpansionError(f"invalid language code: {language!r}")
    return normalized


def _template_value(kind: str, language: str, concept_id: str) -> str:
    return f"__TEMPLATE_{kind.upper()}__:{language}:{concept_id}"


def _set_consistent(mapping: dict[str, str], language: str, value: str, *, label: str, concept_id: str) -> None:
    previous = mapping.get(language)
    if previous is not None and previous != value:
        raise PairExpansionError(
            f"inconsistent {label} for concept {concept_id!r} language {language!r}"
        )
    mapping[language] = value


def _concept_index(reference_dataset: Mapping[str, Any]) -> dict[str, dict[str, Any]]:
    if reference_dataset.get("schema_version") != SCHEMA_VERSION:
        raise PairExpansionError(
            f"reference schema_version must be {SCHEMA_VERSION!r}"
        )
    entries = reference_dataset.get("entries")
    if not isinstance(entries, list) or not entries:
        raise PairExpansionError("reference dataset must contain entries")

    concepts: dict[str, dict[str, Any]] = {}
    for entry in entries:
        concept_id = entry.get("concept_id")
        if not isinstance(concept_id, str) or not concept_id:
            raise PairExpansionError("every reference entry must carry a stable concept_id")

        record = concepts.setdefault(
            concept_id,
            {
                "cefr_level": entry["cefr_level"],
                "part_of_speech": entry["part_of_speech"],
                "domain": entry.get("domain"),
                "texts": {},
                "phonetics": {},
            },
        )
        for field in ("cefr_level", "part_of_speech"):
            if record[field] != entry[field]:
                raise PairExpansionError(
                    f"inconsistent {field} for concept {concept_id!r}"
                )
        if record["domain"] != entry.get("domain"):
            raise PairExpansionError(f"inconsistent domain for concept {concept_id!r}")

        pair = entry["pair_identity"]
        source = _normalize_language(pair["source_language"])
        target = _normalize_language(pair["target_language"])
        _set_consistent(
            record["texts"], source, entry["source_text"],
            label="text", concept_id=concept_id,
        )
        _set_consistent(
            record["texts"], target, entry["target_text"],
            label="text", concept_id=concept_id,
        )
        _set_consistent(
            record["phonetics"], source, entry["phonetics"]["source"],
            label="phonetics", concept_id=concept_id,
        )
        _set_consistent(
            record["phonetics"], target, entry["phonetics"]["target"],
            label="phonetics", concept_id=concept_id,
        )
    return concepts


def _record_id(source: str, target: str, concept_id: str) -> str:
    return f"{source}->{target}:{concept_id}"


def _build_entry(
    concept_id: str,
    concept: Mapping[str, Any],
    source: str,
    target: str,
) -> dict[str, Any]:
    texts = concept["texts"]
    phonetics = concept["phonetics"]
    source_text = texts.get(source, _template_value("text", source, concept_id))
    target_text = texts.get(target, _template_value("text", target, concept_id))
    source_phonetics = phonetics.get(
        source, _template_value("phonetics", source, concept_id)
    )
    target_phonetics = phonetics.get(
        target, _template_value("phonetics", target, concept_id)
    )

    entry = make_entry(
        canonical_key=f"{concept_id}.{source}_to_{target}.skeleton",
        cefr_level=concept["cefr_level"],
        source_text=source_text,
        target_text=target_text,
        source_language=source,
        target_language=target,
        source_phonetics=source_phonetics,
        target_phonetics=target_phonetics,
        part_of_speech=concept["part_of_speech"],
        bidirectional_flag=True,
    )
    reverse_id = _record_id(target, source, concept_id)
    pair = entry["pair_identity"]
    pair["record_id"] = _record_id(source, target, concept_id)
    pair["reverse_record_id"] = reverse_id
    entry["concept_id"] = concept_id
    if concept.get("domain") is not None:
        entry["domain"] = concept["domain"]

    source_direction = text_direction_for_language(source)
    target_direction = text_direction_for_language(target)
    entry["source_rtl"] = source_direction == "rtl"
    entry["target_rtl"] = target_direction == "rtl"
    entry["sourceLanguageDirection"] = source_direction
    entry["targetLanguageDirection"] = target_direction
    entry["partOfSpeech"] = concept["part_of_speech"]
    return entry


def build_pair_skeleton(
    reference_dataset: Mapping[str, Any],
    source_language: str,
    target_language: str,
) -> dict[str, Any]:
    """Project every stable concept into two explicit directed records."""
    source = _normalize_language(source_language)
    target = _normalize_language(target_language)
    if source == target:
        raise PairExpansionError("source and target language must differ")

    concepts = _concept_index(reference_dataset)
    entries: list[dict[str, Any]] = []
    for concept_id in sorted(concepts):
        concept = concepts[concept_id]
        entries.append(_build_entry(concept_id, concept, source, target))
        entries.append(_build_entry(concept_id, concept, target, source))
    return {"schema_version": SCHEMA_VERSION, "entries": entries}


def validate_pair_skeleton(
    dataset: Mapping[str, Any], *, schema_path: str | Path = DEFAULT_SCHEMA_PATH
) -> None:
    """Validate JSON-schema/semantic invariants plus exact reciprocal record links."""
    validate_dataset(dataset, schema_path=schema_path)
    by_record_id = {
        entry["pair_identity"]["record_id"]: entry for entry in dataset["entries"]
    }
    if len(by_record_id) != len(dataset["entries"]):
        raise PairExpansionError("duplicate record_id in generated skeleton")

    for entry in dataset["entries"]:
        pair = entry["pair_identity"]
        reverse_id = pair["reverse_record_id"]
        reverse = by_record_id.get(reverse_id)
        if reverse is None:
            raise PairExpansionError(f"missing reverse record {reverse_id!r}")
        if reverse["concept_id"] != entry["concept_id"]:
            raise PairExpansionError("reverse record concept_id mismatch")
        if reverse["pair_identity"]["reverse_record_id"] != pair["record_id"]:
            raise PairExpansionError("reverse record link is not symmetric")
        if reverse["source_text"] != entry["target_text"] or reverse["target_text"] != entry["source_text"]:
            raise PairExpansionError("reverse record text is not symmetric")
        if entry["sourceLanguageDirection"] != pair["source_direction"]:
            raise PairExpansionError("sourceLanguageDirection mismatch")
        if entry["targetLanguageDirection"] != pair["target_direction"]:
            raise PairExpansionError("targetLanguageDirection mismatch")


def load_reference_dataset(path: str | Path = DEFAULT_REFERENCE_DATASET) -> dict[str, Any]:
    payload = json.loads(Path(path).read_text(encoding="utf-8"))
    if not isinstance(payload, dict):
        raise PairExpansionError("reference dataset root must be an object")
    return payload


def write_matrix_skeletons(
    pairs: Sequence[tuple[str, str]],
    *,
    reference_path: str | Path = DEFAULT_REFERENCE_DATASET,
    output_dir: str | Path = DEFAULT_OUTPUT_DIR,
    schema_path: str | Path = DEFAULT_SCHEMA_PATH,
) -> tuple[Path, ...]:
    reference = load_reference_dataset(reference_path)
    output = Path(output_dir)
    output.mkdir(parents=True, exist_ok=True)
    written: list[Path] = []

    for source_language, target_language in pairs:
        source = _normalize_language(source_language)
        target = _normalize_language(target_language)
        skeleton = build_pair_skeleton(reference, source, target)
        validate_pair_skeleton(skeleton, schema_path=schema_path)
        path = output / f"{source}-{target}.skeleton.json"
        path.write_text(
            json.dumps(skeleton, ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8",
        )
        written.append(path)
    return tuple(written)


def _parse_pair(value: str) -> tuple[str, str]:
    if "->" in value:
        parts = value.split("->")
    else:
        parts = value.split("-")
    if len(parts) != 2:
        raise argparse.ArgumentTypeError("pair must look like de-en or de->en")
    try:
        source = _normalize_language(parts[0])
        target = _normalize_language(parts[1])
    except PairExpansionError as exc:
        raise argparse.ArgumentTypeError(str(exc)) from exc
    if source == target:
        raise argparse.ArgumentTypeError("pair languages must differ")
    return source, target


def main(argv: Sequence[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--reference", default=str(DEFAULT_REFERENCE_DATASET))
    parser.add_argument("--output-dir", default=str(DEFAULT_OUTPUT_DIR))
    parser.add_argument(
        "--pair",
        action="append",
        type=_parse_pair,
        help="pair to generate (repeatable), e.g. --pair de-en --pair en-ar",
    )
    args = parser.parse_args(argv)
    pairs = tuple(args.pair) if args.pair else DEFAULT_PAIRS
    paths = write_matrix_skeletons(
        pairs,
        reference_path=args.reference,
        output_dir=args.output_dir,
        schema_path=DEFAULT_SCHEMA_PATH,
    )
    for path in paths:
        print(path)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
