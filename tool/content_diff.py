#!/usr/bin/env python3
"""Read-only preview of a reviewable content batch against canonical sources."""
from __future__ import annotations

import argparse
import json
from pathlib import Path
import sys

from content_ingestion import CONTENT_FIELDS, VERB_FIELDS, _read_json


def _issue(code: str, message: str, *, category: str, key: str | None = None) -> dict[str, object]:
    return {"code": code, "category": category, "key": key, "message": message}


def _normalize_german(value: str) -> str:
    import unicodedata
    return " ".join(unicodedata.normalize("NFC", value).casefold().split())


def _process_content(
    content_rows: list[object],
    existing_content: list[object],
    conflicts: list[dict[str, object]],
    content_added: list[dict[str, object]],
) -> None:
    existing_ids = {row.get("id") for row in existing_content if isinstance(row, dict)}
    existing_german = {
        _normalize_german(row["german"]): str(row.get("id", ""))
        for row in existing_content
        if isinstance(row, dict) and isinstance(row.get("german"), str) and row["german"].strip()
    }
    seen_batch_ids: set[str] = set()
    valid_content_rows: list[dict[str, object]] = []
    for row in content_rows:
        if not isinstance(row, dict) or set(row) != set(CONTENT_FIELDS):
            conflicts.append(_issue("schema", "content row schema mismatch", category="content"))
            continue
        elif not all(isinstance(row[field], str) for field in CONTENT_FIELDS if field != "accepted") or not isinstance(row["accepted"], list):
            conflicts.append(_issue("schema", "content row field types are invalid", category="content", key=str(row.get("id"))))
            continue
        valid_content_rows.append(row)
    for row in valid_content_rows:
        content_id = str(row["id"])
        german = str(row["german"])
        if content_id in existing_ids:
            conflicts.append(_issue("content_id_exists", f"contentId already exists: {content_id}", category="content", key=content_id))
            continue
        if content_id in seen_batch_ids:
            conflicts.append(_issue("content_id_duplicate", f"contentId is duplicated in batch: {content_id}", category="content", key=content_id))
            continue
        seen_batch_ids.add(content_id)
        canonical_id = existing_german.get(_normalize_german(german))
        if canonical_id is not None:
            conflicts.append(_issue("canonical_german_exists", f"German entry already exists as {canonical_id}: {german}", category="content", key=content_id))
            continue
        content_added.append(row)


def _process_verbs(
    verb_rows: list[object],
    existing_verbs: list[object],
    conflicts: list[dict[str, object]],
    verb_added: list[dict[str, object]],
) -> None:
    existing_verb_keys = {
        (row.get("infinitive"), row.get("person"), row.get("form"))
        for row in existing_verbs if isinstance(row, dict)
    }
    valid_verb_rows: list[dict[str, object]] = []
    for row in verb_rows:
        if not isinstance(row, dict) or set(row) != set(VERB_FIELDS):
            conflicts.append(_issue("schema", "verb row schema mismatch", category="verb"))
            continue
        elif not all(isinstance(row[field], str) for field in VERB_FIELDS):
            conflicts.append(_issue("schema", "verb row field types are invalid", category="verb"))
            continue
        valid_verb_rows.append(row)
    for row in valid_verb_rows:
        key = (row["infinitive"], row["person"], row["form"])
        label = " / ".join(str(x) for x in key)
        if key in existing_verb_keys:
            conflicts.append(_issue("verb_row_exists", f"verb row already exists: {label}", category="verb", key=label))
        else:
            verb_added.append(row)


def _process_audio(
    audio_rows: list[object],
    existing_audio: dict[str, object],
    conflicts: list[dict[str, object]],
    audio_added: list[dict[str, object]],
) -> None:
    # Handle dict typing safely by providing a default empty list
    entries = existing_audio.get("entries")
    if not isinstance(entries, list):
        entries = []
    existing_audio_ids = {
        row.get("contentId") for row in entries if isinstance(row, dict)
    }
    valid_audio_rows: list[dict[str, object]] = []
    for row in audio_rows:
        if not isinstance(row, dict) or not set(row).issubset({"contentId", "word", "sentence", "pronunciation"}) or "contentId" not in row:
            conflicts.append(_issue("schema", "audio row schema mismatch", category="audio"))
            continue
        valid_audio_rows.append(row)
    for row in valid_audio_rows:
        content_id = str(row["contentId"])
        if content_id in existing_audio_ids:
            conflicts.append(_issue("audio_content_id_exists", f"audio entry already exists: {content_id}", category="audio", key=content_id))
        else:
            audio_added.append(row)


def preview_batch(
    source: Path,
    *,
    content_path: Path,
    verb_path: Path,
    audio_manifest_path: Path,
) -> dict[str, object]:
    """Return a deterministic, read-only preview of additions and conflicts."""
    batch = _read_json(source)
    conflicts: list[dict[str, object]] = []
    content_added: list[dict[str, object]] = []
    verb_added: list[dict[str, object]] = []
    audio_added: list[dict[str, object]] = []

    if not isinstance(batch, dict) or set(batch) != {"version", "languageCode", "contentItems", "verbConjugations", "audio"}:
        conflicts.append(_issue("schema", "bulk batch schema mismatch", category="batch"))
        return {
            "status": "FAIL",
            "summary": {"content_added": 0, "verbs_added": 0, "audio_added": 0, "conflicts": len(conflicts)},
            "content": {"added": []},
            "verbs": {"added": []},
            "audio": {"added": []},
            "conflicts": conflicts,
        }
    if batch["version"] != 1 or not isinstance(batch["languageCode"], str) or not batch["languageCode"]:
        conflicts.append(_issue("schema", "bulk batch version/languageCode mismatch", category="batch"))
    content_rows = batch["contentItems"] if isinstance(batch["contentItems"], list) else []
    verb_rows = batch["verbConjugations"] if isinstance(batch["verbConjugations"], list) else []
    audio_rows = batch["audio"] if isinstance(batch["audio"], list) else []
    if not isinstance(batch["contentItems"], list):
        conflicts.append(_issue("schema", "contentItems must be an array", category="content"))
    if not isinstance(batch["verbConjugations"], list):
        conflicts.append(_issue("schema", "verbConjugations must be an array", category="verb"))
    if not isinstance(batch["audio"], list):
        conflicts.append(_issue("schema", "audio must be an array", category="audio"))

    existing_content = _read_json(content_path)
    existing_verbs = _read_json(verb_path)
    existing_audio = _read_json(audio_manifest_path) if audio_manifest_path.exists() else {"version": 1, "entries": []}
    if not isinstance(existing_content, list) or not isinstance(existing_verbs, list):
        conflicts.append(_issue("canonical_schema", "canonical content and verbs must be arrays", category="canonical"))
        existing_content = existing_content if isinstance(existing_content, list) else []
        existing_verbs = existing_verbs if isinstance(existing_verbs, list) else []
    if not isinstance(existing_audio, dict) or existing_audio.get("version") != 1 or not isinstance(existing_audio.get("entries"), list):
        conflicts.append(_issue("canonical_schema", "canonical audio manifest schema mismatch", category="audio"))
        existing_audio = {"version": 1, "entries": []}

    _process_content(content_rows, existing_content, conflicts, content_added)
    _process_verbs(verb_rows, existing_verbs, conflicts, verb_added)
    _process_audio(audio_rows, existing_audio, conflicts, audio_added)

    status = "PASS" if not conflicts else "FAIL"
    return {
        "status": status,
        "summary": {
            "content_added": len(content_added),
            "verbs_added": len(verb_added),
            "audio_added": len(audio_added),
            "conflicts": len(conflicts),
        },
        "content": {"added": content_added},
        "verbs": {"added": verb_added},
        "audio": {"added": audio_added},
        "conflicts": conflicts,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description="Preview a reviewable content batch without mutating canonical sources")
    parser.add_argument("--source", required=True, type=Path)
    parser.add_argument("--content", required=True, type=Path)
    parser.add_argument("--verbs", required=True, type=Path)
    parser.add_argument("--audio-manifest", required=True, type=Path)
    parser.add_argument("--report", type=Path)
    args = parser.parse_args()
    try:
        report = preview_batch(
            args.source,
            content_path=args.content,
            verb_path=args.verbs,
            audio_manifest_path=args.audio_manifest,
        )
        payload = json.dumps(report, ensure_ascii=False, indent=2) + "\n"
        if args.report:
            args.report.parent.mkdir(parents=True, exist_ok=True)
            args.report.write_text(payload, encoding="utf-8", newline="\n")
        else:
            print(payload, end="")
        return 0 if report["status"] == "PASS" else 1
    except (OSError, ValueError, json.JSONDecodeError) as exc:
        print(str(exc), file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
