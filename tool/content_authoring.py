#!/usr/bin/env python3
"""Convert a human-friendly language content authoring file into a reviewable batch.

Authoring files intentionally use shorter vocabulary keys and group verb
conjugations by infinitive. The converter never mutates canonical content.
It produces the existing V359 batch contract for review/publishing.
"""
from __future__ import annotations

import argparse
import json
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_CONTENT = ROOT / "content" / "content_items.json"
DEFAULT_VERBS = ROOT / "content" / "verb_conjugations.json"

ENTRY_FIELDS = {
    "id", "word", "translation", "sentence", "sentenceTranslation",
    "topic", "skill", "article", "plural", "accepted", "audio",
}
AUDIO_FIELDS = {"word", "sentence", "pronunciation"}
VERB_FIELDS = {
    "person", "personAr", "form", "past", "pastArabic", "example",
    "exampleAr", "pastExample", "pastExampleAr",
}
VERB_HEADER_FIELDS = {"infinitive", "arabic", "group", "forms"}


def _read_json(path: Path) -> object:
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise ValueError(f"invalid JSON source {path}: {exc}") from exc


def _string(value: object, field: str, *, allow_empty: bool = True) -> str:
    if not isinstance(value, str) or (not allow_empty and not value):
        raise ValueError(f"authoring field {field} must be a string" + ("" if allow_empty else " and non-empty"))
    return value


def _entry(row: object) -> tuple[dict[str, object], list[dict[str, str]]]:
    if not isinstance(row, dict):
        raise ValueError("authoring entry must be an object")
    unknown = set(row) - ENTRY_FIELDS
    if unknown:
        raise ValueError("unsupported authoring entry field: " + sorted(unknown)[0])
    content_id = _string(row.get("id"), "id", allow_empty=False)
    word = _string(row.get("word"), "word", allow_empty=False)
    translation = _string(row.get("translation"), "translation", allow_empty=False)
    sentence = _string(row.get("sentence", ""), "sentence")
    sentence_ar = _string(row.get("sentenceTranslation", ""), "sentenceTranslation")
    topic = _string(row.get("topic", ""), "topic")
    skill = _string(row.get("skill", "recall"), "skill", allow_empty=False)
    article = _string(row.get("article", ""), "article")
    plural = _string(row.get("plural", ""), "plural")
    accepted = row.get("accepted", [word])
    if not isinstance(accepted, list) or not all(isinstance(v, str) and v for v in accepted):
        raise ValueError("authoring field accepted must be a list of non-empty strings")

    audio_rows: list[dict[str, str]] = []
    audio = row.get("audio")
    if audio is not None:
        if not isinstance(audio, dict):
            raise ValueError("authoring field audio must be an object")
        unknown_audio = set(audio) - AUDIO_FIELDS
        if unknown_audio:
            raise ValueError("unsupported authoring audio field: " + sorted(unknown_audio)[0])
        audio_row = {"contentId": content_id}
        for key, value in audio.items():
            value = _string(value, f"audio.{key}", allow_empty=False)
            path = Path(value)
            if path.is_absolute() or ".." in path.parts:
                raise ValueError(f"authoring audio path must be safe and relative: {value}")
            audio_row[key] = value
        audio_rows.append(audio_row)

    return ({
        "id": content_id,
        "german": word,
        "arabic": translation,
        "sentence": sentence,
        "sentenceAr": sentence_ar,
        "topic": topic,
        "skill": skill,
        "article": article,
        "plural": plural,
        "accepted": accepted,
    }, audio_rows)


def _verbs(rows: object) -> list[dict[str, str]]:
    if not isinstance(rows, list):
        raise ValueError("authoring verbs must be an array")
    result: list[dict[str, str]] = []
    seen: set[tuple[str, str, str]] = set()
    for row in rows:
        if not isinstance(row, dict):
            raise ValueError("authoring verb must be an object")
        unknown = set(row) - VERB_HEADER_FIELDS
        if unknown:
            raise ValueError("unsupported authoring verb field: " + sorted(unknown)[0])
        infinitive = _string(row.get("infinitive"), "infinitive", allow_empty=False)
        arabic = _string(row.get("arabic"), "arabic", allow_empty=False)
        group = _string(row.get("group", ""), "group")
        forms = row.get("forms")
        if not isinstance(forms, list) or not forms:
            raise ValueError(f"authoring verb forms must be a non-empty list: {infinitive}")
        for form in forms:
            if not isinstance(form, dict):
                raise ValueError(f"authoring verb form must be an object: {infinitive}")
            unknown_form = set(form) - VERB_FIELDS
            if unknown_form:
                raise ValueError("unsupported authoring verb form field: " + sorted(unknown_form)[0])
            out = {
                "infinitive": infinitive,
                "arabic": arabic,
                "group": group,
            }
            for field in VERB_FIELDS:
                out[field] = _string(form.get(field, ""), field, allow_empty=field not in {"person", "form"})
            key = (infinitive, out["person"], out["form"])
            if key in seen:
                raise ValueError(f"duplicate authoring verb row: {key[0]} / {key[1]} / {key[2]}")
            seen.add(key)
            result.append(out)
    return result


def prepare_authoring(
    source: Path,
    output: Path,
    *,
    existing_content_path: Path = DEFAULT_CONTENT,
    existing_verb_path: Path = DEFAULT_VERBS,
) -> tuple[int, int, int]:
    """Convert authoring JSON to the V359 reviewable batch contract."""
    data = _read_json(source)
    if not isinstance(data, dict) or set(data) != {"version", "languageCode", "entries", "verbs"}:
        raise ValueError("authoring schema mismatch")
    if data["version"] != 1 or not isinstance(data["languageCode"], str) or not data["languageCode"]:
        raise ValueError("authoring version/languageCode mismatch")
    if not isinstance(data["entries"], list):
        raise ValueError("authoring entries must be an array")

    existing_content = _read_json(existing_content_path)
    existing_verbs = _read_json(existing_verb_path)
    if not isinstance(existing_content, list) or not isinstance(existing_verbs, list):
        raise ValueError("existing content and verb sources must be arrays")
    existing_ids = {row.get("id") for row in existing_content if isinstance(row, dict)}
    ids: set[str] = set()
    content_rows: list[dict[str, object]] = []
    audio_rows: list[dict[str, str]] = []
    audio_ids: set[str] = set()
    for row in data["entries"]:
        content_row, entry_audio = _entry(row)
        content_id = content_row["id"]
        if content_id in existing_ids:
            raise ValueError(f"duplicate existing content id: {content_id}")
        if content_id in ids:
            raise ValueError(f"duplicate authoring content id: {content_id}")
        ids.add(content_id)
        content_rows.append(content_row)
        for audio in entry_audio:
            if content_id in audio_ids:
                raise ValueError(f"duplicate authoring audio contentId: {content_id}")
            audio_ids.add(content_id)
            audio_rows.append(audio)

    verb_rows = _verbs(data["verbs"])
    existing_verb_keys = {(row.get("infinitive"), row.get("person"), row.get("form")) for row in existing_verbs if isinstance(row, dict)}
    for row in verb_rows:
        key = (row["infinitive"], row["person"], row["form"])
        if key in existing_verb_keys:
            raise ValueError(f"duplicate existing verb row: {key[0]} / {key[1]} / {key[2]}")

    batch = {
        "version": 1,
        "languageCode": data["languageCode"],
        "contentItems": content_rows,
        "verbConjugations": verb_rows,
        "audio": audio_rows,
    }
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(batch, ensure_ascii=False, indent=2) + "\n", encoding="utf-8", newline="\n")
    return len(content_rows), len(verb_rows), len(audio_rows)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("command", choices=("prepare",))
    parser.add_argument("--source", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--content", type=Path, default=DEFAULT_CONTENT)
    parser.add_argument("--verbs", type=Path, default=DEFAULT_VERBS)
    args = parser.parse_args()
    try:
        content, verbs, audio = prepare_authoring(
            args.source, args.output,
            existing_content_path=args.content,
            existing_verb_path=args.verbs,
        )
        print(f"batch_content_items={content} batch_verb_conjugations={verbs} batch_audio_entries={audio} authoring=PASS")
        return 0
    except (OSError, ValueError, json.JSONDecodeError) as exc:
        print(str(exc), file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
