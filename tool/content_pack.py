#!/usr/bin/env python3
"""Build-time content pack exporter/compiler for Deutsch بالعربي.

Safe migration strategy: JSON is introduced as an editable source format while
runtime Dart tables remain the generated/legacy representation. No runtime
network or external service is used.
"""
from __future__ import annotations

import argparse
import json
import re
from pathlib import Path
from typing import Iterable

ROOT = Path(__file__).resolve().parents[1]
DATA_DIR = ROOT / "content" / "german"
CONTENT_OUT = ROOT / "content" / "content_items.json"
VERB_OUT = ROOT / "content" / "verb_conjugations.json"
SCHEMA_OUT = ROOT / "content" / "content_pack.schema.json"

CONTENT_FIELDS = ("id", "german", "arabic", "sentence", "sentenceAr", "topic", "skill", "article", "plural", "accepted")
VERB_FIELDS = ("infinitive", "arabic", "group", "person", "personAr", "form", "past", "pastArabic", "example", "exampleAr", "pastExample", "pastExampleAr")


def _decode_escape(text: str, quote: str) -> str:
    out: list[str] = []
    i = 0
    while i < len(text):
        ch = text[i]
        if ch != "\\" or i + 1 >= len(text):
            out.append(ch)
            i += 1
            continue
        nxt = text[i + 1]
        escapes = {"n": "\n", "r": "\r", "t": "\t", "b": "\b", "f": "\f", "\\": "\\", "\"": "\"", "'": "'"}
        if nxt in escapes:
            out.append(escapes[nxt])
            i += 2
        elif nxt == "u" and i + 5 < len(text):
            raw = text[i + 2:i + 6]
            try:
                out.append(chr(int(raw, 16)))
                i += 6
            except ValueError:
                out.append("\\u")
                i += 2
        else:
            out.append(nxt)
            i += 2
    return "".join(out)


def _parse_string(s: str, i: int) -> tuple[str, int]:
    quote = s[i]
    assert quote in "\"'"
    i += 1
    buf: list[str] = []
    while i < len(s):
        ch = s[i]
        if ch == quote:
            return _decode_escape("".join(buf), quote), i + 1
        if ch == "\\" and i + 1 < len(s):
            buf.append(s[i:i + 2])
            i += 2
            continue
        buf.append(ch)
        i += 1
    raise ValueError("unterminated Dart string")


def _skip_ws(s: str, i: int) -> int:
    while i < len(s) and s[i].isspace():
        i += 1
    return i


def _parse_string_list(s: str, i: int) -> tuple[list[str], int]:
    if s[i] != "[":
        raise ValueError("expected list")
    i += 1
    items: list[str] = []
    while True:
        i = _skip_ws(s, i)
        if i >= len(s):
            raise ValueError("unterminated list")
        if s[i] == "]":
            return items, i + 1
        value, i = _parse_string(s, i)
        items.append(value)
        i = _skip_ws(s, i)
        if i < len(s) and s[i] == ",":
            i += 1
            continue
        if i < len(s) and s[i] == "]":
            return items, i + 1
        raise ValueError("expected comma or closing list bracket")


def _parse_named_constructor(blob: str, constructor: str, fields: tuple[str, ...]) -> list[dict[str, object]]:
    rows: list[dict[str, object]] = []
    needle = constructor + "("
    pos = 0
    while True:
        start = blob.find(needle, pos)
        if start < 0:
            break
        i = start + len(needle)
        values: dict[str, object] = {}
        while True:
            i = _skip_ws(blob, i)
            if i >= len(blob):
                raise ValueError(f"unterminated {constructor}")
            if blob[i] == ")":
                i += 1
                break
            m = re.match(r"([A-Za-z_][A-Za-z0-9_]*)\s*:\s*", blob[i:])
            if not m:
                raise ValueError(f"cannot parse named argument near: {blob[i:i+80]!r}")
            name = m.group(1)
            if name not in fields:
                raise ValueError(f"unexpected field {name!r} in {constructor}")
            i += m.end()
            i = _skip_ws(blob, i)
            if name == "accepted":
                value, i = _parse_string_list(blob, i)
            else:
                value, i = _parse_string(blob, i)
            values[name] = value
            i = _skip_ws(blob, i)
            if i < len(blob) and blob[i] == ",":
                i += 1
                continue
            if i < len(blob) and blob[i] == ")":
                i += 1
                break
            raise ValueError(f"expected comma or closing parenthesis near: {blob[i:i+80]!r}")
        missing = [f for f in fields if f not in values and not (constructor == "ContentItem" and f in ("article", "plural", "accepted"))]
        for optional in ("article", "plural", "accepted"):
            if constructor == "ContentItem" and optional not in values:
                values[optional] = [] if optional == "accepted" else ""
        if missing:
            raise ValueError(f"missing fields {missing} in {constructor}")
        rows.append(values)
        pos = i
    return rows


def iter_source_files(pattern: str) -> Iterable[Path]:
    for p in sorted(DATA_DIR.glob(pattern)):
        if p.is_file():
            yield p


def export() -> tuple[int, int]:
    # Parse one source file at a time. Avoid repeated slicing of a multi-megabyte
    # concatenated blob, which makes regex matching unnecessarily quadratic.
    content: list[dict[str, object]] = []
    for source in iter_source_files("content_*.dart"):
        content.extend(_parse_named_constructor(source.read_text(encoding="utf-8"), "ContentItem", CONTENT_FIELDS))
    verbs: list[dict[str, object]] = []
    for source in iter_source_files("verb_conjugations*.dart"):
        verbs.extend(_parse_named_constructor(source.read_text(encoding="utf-8"), "VerbConjugation", VERB_FIELDS))
    CONTENT_OUT.parent.mkdir(parents=True, exist_ok=True)
    CONTENT_OUT.write_text(json.dumps(content, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    VERB_OUT.write_text(json.dumps(verbs, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    SCHEMA_OUT.write_text(json.dumps(schema(), ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    return len(content), len(verbs)


def schema() -> dict[str, object]:
    string_props = {f: {"type": "string"} for f in CONTENT_FIELDS if f != "accepted"}
    string_props["accepted"] = {"type": "array", "items": {"type": "string"}}
    return {
        "$schema": "https://json-schema.org/draft/2020-12/schema",
        "title": "Deutsch بالعربي content pack",
        "type": "object",
        "required": ["contentItems", "verbConjugations"],
        "properties": {
            "contentItems": {"type": "array", "items": {"type": "object", "required": list(CONTENT_FIELDS), "properties": string_props, "additionalProperties": False}},
            "verbConjugations": {"type": "array", "items": {"type": "object", "required": list(VERB_FIELDS), "properties": {f: {"type": "string"} for f in VERB_FIELDS}, "additionalProperties": False}},
        },
        "additionalProperties": False,
    }


def validate() -> tuple[int, int]:
    if not CONTENT_OUT.exists() or not VERB_OUT.exists():
        raise SystemExit("content pack files are missing; run export first")
    content = json.loads(CONTENT_OUT.read_text(encoding="utf-8"))
    verbs = json.loads(VERB_OUT.read_text(encoding="utf-8"))
    if not isinstance(content, list) or not isinstance(verbs, list):
        raise SystemExit("content pack roots must be arrays")
    if not content:
        raise SystemExit("content pack must contain at least one content item")

    ids: set[str] = set()
    for index, row in enumerate(content):
        if not isinstance(row, dict) or set(row) != set(CONTENT_FIELDS):
            raise SystemExit(f"content row schema mismatch at index {index}")
        content_id = row.get("id")
        if not isinstance(content_id, str) or not content_id.strip():
            raise SystemExit(f"content id must be non-empty at index {index}")
        if content_id in ids:
            raise SystemExit(f"duplicate content id: {content_id}")
        ids.add(content_id)
        if not all(
            isinstance(row[k], str)
            for k in CONTENT_FIELDS
            if k != "accepted"
        ):
            raise SystemExit(f"content string field type mismatch at {content_id}")
        if not isinstance(row["accepted"], list) or not all(
            isinstance(value, str) for value in row["accepted"]
        ):
            raise SystemExit(f"accepted field type mismatch at {content_id}")

    for index, row in enumerate(verbs):
        if not isinstance(row, dict) or set(row) != set(VERB_FIELDS):
            raise SystemExit(f"verb row schema mismatch at index {index}")
        if not all(isinstance(row[k], str) for k in VERB_FIELDS):
            raise SystemExit(f"verb field type mismatch at index {index}")
    return len(content), len(verbs)


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("command", choices=("export", "validate"))
    args = ap.parse_args()
    counts = export() if args.command == "export" else validate()
    print(f"content_items={counts[0]} verb_conjugations={counts[1]}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
