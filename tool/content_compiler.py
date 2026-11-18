#!/usr/bin/env python3
"""Deterministic JSON -> Dart compiler for editable Deutsch بالعربي content.

This stage does not replace the existing runtime source. It produces generated
Dart files into a caller-provided directory and can parse them back to prove
row-for-row parity with the editable JSON packs.
"""
from __future__ import annotations

import argparse
import ast
import hashlib
import json
import os
from pathlib import Path
import re
import sys
TOOL_DIR = Path(__file__).resolve().parent
if str(TOOL_DIR) not in sys.path: sys.path.insert(0, str(TOOL_DIR))
from verification_cache import fingerprint, load as load_cache, is_valid as cache_valid, store as store_cache

ROOT = Path(__file__).resolve().parents[1]
CONTENT_JSON = ROOT / "content" / "content_items.json"
VERB_JSON = ROOT / "content" / "verb_conjugations.json"
EDITORIAL_CORRECTIONS = ROOT / "content" / "german" / "editorial_corrections.jsonl"
PARSER = ROOT / "tool" / "content_pack.py"

CONTENT_FIELDS = ("id", "german", "arabic", "sentence", "sentenceAr", "topic", "skill", "article", "plural", "accepted")
CHUNK_SIZE = 400
VERB_FIELDS = ("infinitive", "arabic", "group", "person", "personAr", "form", "past", "pastArabic", "example", "exampleAr", "pastExample", "pastExampleAr")


def dart_string(value: str) -> str:
    return "'" + value.replace('\\', '\\\\').replace("'", "\\'").replace('\n', '\\n').replace('\r', '\\r') + "'"


def content_row(row: dict[str, object]) -> str:
    parts = []
    for field in CONTENT_FIELDS:
        value = row[field]
        if field == "accepted":
            assert isinstance(value, list)
            encoded = "[" + ",".join(dart_string(str(x)) for x in value) + "]"
        else:
            assert isinstance(value, str)
            encoded = dart_string(value)
        parts.append(f"{field}:{encoded}")
    return "ContentItem(" + ",".join(parts) + "),"


def verb_row(row: dict[str, object]) -> str:
    parts = []
    for field in VERB_FIELDS:
        value = row[field]
        if not isinstance(value, str):
            raise ValueError(f"verb field {field} must be string")
        parts.append(f"{field}:{dart_string(value)}")
    return "VerbConjugation(" + ",".join(parts) + "),"


def _load_editorial_corrections(path: Path = EDITORIAL_CORRECTIONS) -> list[dict[str, str]]:
    if not path.exists():
        return []
    corrections: list[dict[str, str]] = []
    for line_number, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
        if not line.strip():
            continue
        try:
            row = json.loads(line)
        except json.JSONDecodeError as exc:
            raise ValueError(f"invalid editorial correction at line {line_number}") from exc
        if not isinstance(row, dict) or set(row) != {"id", "field", "from", "to", "rule"}:
            raise ValueError(f"editorial correction schema mismatch at line {line_number}")
        if row["field"] != "sentence" or row["rule"] != "REMOVE_DUPLICATED_GERMAN_ARTICLE":
            raise ValueError(f"unsupported editorial correction at line {line_number}")
        corrections.append({key: str(value) for key, value in row.items()})
    return corrections


def _apply_editorial_corrections(rows: list[dict[str, object]], editorial_corrections_path: Path = EDITORIAL_CORRECTIONS) -> list[dict[str, object]]:
    corrections = _load_editorial_corrections(editorial_corrections_path)
    if not corrections:
        return rows
    by_id = {str(row.get("id")): index for index, row in enumerate(rows)}
    updated = [dict(row) for row in rows]
    seen: set[tuple[str, str]] = set()
    for correction in corrections:
        key = (correction["id"], correction["field"])
        if key in seen:
            raise ValueError(f"duplicate editorial correction: {key}")
        seen.add(key)
        if correction["id"] not in by_id:
            raise ValueError(f"editorial correction references unknown id: {correction['id']}")
        row = updated[by_id[correction["id"]]]
        field = correction["field"]
        if row.get(field) != correction["from"]:
            raise ValueError(f"editorial correction precondition mismatch: {correction['id']}/{field}")
        row[field] = correction["to"]
    return updated


def _fingerprint_sources(content_path: Path, verb_path: Path, editorial_corrections_path: Path = EDITORIAL_CORRECTIONS) -> list[Path]:
    sources = [content_path, verb_path]
    if editorial_corrections_path.exists():
        sources.append(editorial_corrections_path)
    return sources


def load(content_path: Path = CONTENT_JSON, verb_path: Path = VERB_JSON, editorial_corrections_path: Path = EDITORIAL_CORRECTIONS) -> tuple[list[dict[str, object]], list[dict[str, object]]]:
    content = json.loads(content_path.read_text(encoding="utf-8"))
    verbs = json.loads(verb_path.read_text(encoding="utf-8"))
    if not isinstance(content, list) or not isinstance(verbs, list):
        raise ValueError("content pack roots must be arrays")
    return _apply_editorial_corrections(content, editorial_corrections_path), verbs


def _write_if_changed(path: Path, text: str) -> bool:
    """Write a generated artifact only when its bytes would actually change."""
    encoded = text.encode("utf-8")
    if path.exists() and path.read_bytes() == encoded:
        return False
    path.write_bytes(encoded)
    return True


def _write_chunks(output_dir: Path, rows: list[dict[str, object]], row_builder, prefix: str, symbol_prefix: str, import_path: str) -> tuple[list[Path], list[str]]:
    paths: list[Path] = []
    hashes: list[str] = []
    for index in range(0, len(rows), CHUNK_SIZE):
        chunk_no = index // CHUNK_SIZE
        chunk_rows = rows[index:index + CHUNK_SIZE]
        path = output_dir / f"{prefix}_chunk_{chunk_no:03d}.dart"
        symbol = f"{symbol_prefix}{chunk_no:03d}"
        text = (
            f"import '{import_path}';\n\n"
            f"const {symbol} = <{('ContentItem' if prefix == 'content_items' else 'VerbConjugation')}>[\n"
            + "\n".join(row_builder(r) for r in chunk_rows)
            + "\n];\n"
        )
        _write_if_changed(path, text)
        paths.append(path)
        hashes.append(hashlib.sha256(text.encode("utf-8")).hexdigest())
    return paths, hashes


def _remove_stale_chunks(output_dir: Path, prefix: str, expected: set[Path]) -> None:
    for path in output_dir.glob(f"{prefix}_chunk_*.dart"):
        if path not in expected:
            path.unlink()


def _rel_uri(base: Path, target: Path) -> str:
    return os.path.relpath(str(target), str(base)).replace(os.sep, "/")


def _write_aggregate(path: Path, model_import: str, imports: list[str], declaration: str, spreads: list[str]) -> bool:
    text = "\n".join([model_import, *imports]) + "\n\nconst " + declaration + "[\n" + ",\n".join(spreads) + "\n];\n"
    return _write_if_changed(path, text)


def compile_to(output_dir: Path, content_path: Path = CONTENT_JSON, verb_path: Path = VERB_JSON, cache_path: Path | None = None, editorial_corrections_path: Path = EDITORIAL_CORRECTIONS) -> tuple[Path, Path]:
    content, verbs = load(content_path, verb_path, editorial_corrections_path)
    output_dir.mkdir(parents=True, exist_ok=True)
    cache_key = "content_compilation"
    if cache_path is not None:
        fp = fingerprint(_fingerprint_sources(content_path, verb_path, editorial_corrections_path), config={"chunk_size": CHUNK_SIZE, "fields": CONTENT_FIELDS + VERB_FIELDS}, tool_version="V379")
        cached = load_cache(cache_path)
        if cache_valid(cached.get(cache_key, {}), fp) and (output_dir / "content_items_generated.dart").exists() and (output_dir / "verb_conjugations_generated.dart").exists():
            return output_dir / "content_items_generated.dart", output_dir / "verb_conjugations_generated.dart"
    content_model = ROOT / "lib" / "models" / "content.dart"
    verb_model = ROOT / "lib" / "models" / "verb_conjugation.dart"
    content_model_uri = _rel_uri(output_dir, content_model)
    verb_model_uri = _rel_uri(output_dir, verb_model)
    content_chunks, content_hashes = _write_chunks(output_dir, content, content_row, "content_items", "generatedContentItemsChunk", content_model_uri)
    verb_chunks, verb_hashes = _write_chunks(output_dir, verbs, verb_row, "verb_conjugations", "generatedVerbConjugationsChunk", verb_model_uri)
    _remove_stale_chunks(output_dir, "content_items", set(content_chunks))
    _remove_stale_chunks(output_dir, "verb_conjugations", set(verb_chunks))
    content_out = output_dir / "content_items_generated.dart"
    verbs_out = output_dir / "verb_conjugations_generated.dart"
    content_imports = [f"import 'content_items_chunk_{i:03d}.dart';" for i in range(len(content_chunks))]
    verb_imports = [f"import 'verb_conjugations_chunk_{i:03d}.dart';" for i in range(len(verb_chunks))]
    content_spread = [f"  ...generatedContentItemsChunk{i:03d}" for i in range(len(content_chunks))]
    verb_spread = [f"  ...generatedVerbConjugationsChunk{i:03d}" for i in range(len(verb_chunks))]
    _write_aggregate(content_out, f"import '{content_model_uri}';", content_imports, "generatedContentItems = <ContentItem>", content_spread)
    _write_aggregate(verbs_out, f"import '{verb_model_uri}';", verb_imports, "generatedVerbConjugations = <VerbConjugation>", verb_spread)
    if cache_path is not None:
        fp = fingerprint(_fingerprint_sources(content_path, verb_path, editorial_corrections_path), config={"chunk_size": CHUNK_SIZE, "fields": CONTENT_FIELDS + VERB_FIELDS}, tool_version="V379")
        store_cache(cache_path, "content_compilation", fp, {"status": "PASS", "content_chunk_hashes": content_hashes, "verb_chunk_hashes": verb_hashes})
    return content_out, verbs_out


def _split_constructor_args(blob: str) -> list[str]:
    parts: list[str] = []
    start = 0
    quote = False
    escaped = False
    depth = 0
    for i, ch in enumerate(blob):
        if quote:
            if escaped:
                escaped = False
            elif ch == "\\":
                escaped = True
            elif ch == "'":
                quote = False
        else:
            if ch == "'":
                quote = True
            elif ch == "[":
                depth += 1
            elif ch == "]":
                depth -= 1
            elif ch == "," and depth == 0:
                parts.append(blob[start:i])
                start = i + 1
    parts.append(blob[start:])
    return parts


def parse_generated(path: Path, constructor: str, fields: tuple[str, ...]) -> list[dict[str, object]]:
    rows: list[dict[str, object]] = []
    needle = constructor + "("
    for line in path.read_text(encoding="utf-8").splitlines():
        if not line.startswith(needle) or not line.endswith("),"):
            continue
        blob = line[len(needle):-2]
        row: dict[str, object] = {}
        for part in _split_constructor_args(blob):
            name, sep, raw = part.partition(":")
            name = name.strip()
            raw = raw.strip()
            if not sep or name not in fields or not raw:
                raise ValueError(f"invalid generated {constructor} field")
            row[name] = ast.literal_eval(raw)
        if set(row) != set(fields):
            raise ValueError(f"generated {constructor} row schema mismatch")
        rows.append(row)
    return rows


def parity(output_dir: Path, content_path: Path = CONTENT_JSON, verb_path: Path = VERB_JSON) -> tuple[int, int]:
    content, verbs = load(content_path, verb_path)
    content_out = output_dir / "content_items_generated.dart"
    verbs_out = output_dir / "verb_conjugations_generated.dart"
    if not content_out.exists() or not verbs_out.exists():
        raise ValueError("generated Dart files are missing; run compile first")
    parsed_content = []
    for chunk in sorted(output_dir.glob("content_items_chunk_*.dart")):
        parsed_content.extend(parse_generated(chunk, "ContentItem", CONTENT_FIELDS))
    parsed_verbs = []
    for chunk in sorted(output_dir.glob("verb_conjugations_chunk_*.dart")):
        parsed_verbs.extend(parse_generated(chunk, "VerbConjugation", VERB_FIELDS))
    if parsed_content != content:
        for index, (expected, actual) in enumerate(zip(content, parsed_content)):
            if expected != actual:
                raise ValueError(f"content parity mismatch at row {index}: {expected!r} != {actual!r}")
        raise ValueError(f"content parity length mismatch: {len(content)} != {len(parsed_content)}")
    if parsed_verbs != verbs:
        for index, (expected, actual) in enumerate(zip(verbs, parsed_verbs)):
            if expected != actual:
                raise ValueError(f"verb parity mismatch at row {index}: {expected!r} != {actual!r}")
        raise ValueError(f"verb parity length mismatch: {len(verbs)} != {len(parsed_verbs)}")
    return len(content), len(verbs)


def main() -> int:
    ap = argparse.ArgumentParser()
    sub = ap.add_subparsers(dest="command", required=True)
    c = sub.add_parser("compile")
    c.add_argument("--output-dir", required=True, type=Path)
    c.add_argument("--cache", type=Path)
    c.add_argument("--editorial-corrections", type=Path)
    p = sub.add_parser("parity")
    p.add_argument("--output-dir", required=True, type=Path)
    args = ap.parse_args()
    try:
        if args.command == "compile":
            content_out, verbs_out = compile_to(args.output_dir, cache_path=args.cache, editorial_corrections_path=args.editorial_corrections or EDITORIAL_CORRECTIONS)
            print(f"generated_content={content_out} generated_verbs={verbs_out}")
        else:
            content_rows, verb_rows = parity(args.output_dir)
            print(f"content_rows={content_rows} verb_rows={verb_rows} parity=PASS")
        return 0
    except (OSError, ValueError, json.JSONDecodeError) as exc:
        print(str(exc), file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
