#!/usr/bin/env python3
"""Review-only quality gate for V360 reviewable content batches.

This gate reports quality defects without mutating the batch or canonical content.
It intentionally checks editorial completeness, consistency and batch-local references,
while leaving linguistic correctness to human review.
"""
from __future__ import annotations

import argparse
import json
from pathlib import Path
import sys
import unicodedata

CONTENT_FIELDS = {"id", "german", "arabic", "sentence", "sentenceAr", "topic", "skill", "article", "plural", "accepted"}
VERB_FIELDS = {"infinitive", "arabic", "group", "person", "personAr", "form", "past", "pastArabic", "example", "exampleAr", "pastExample", "pastExampleAr"}
AUDIO_FIELDS = {"contentId", "word", "sentence", "pronunciation"}


def _read(path: Path) -> object:
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise ValueError(f"invalid JSON source {path}: {exc}") from exc


def _normalize_german(value: str) -> str:
    return " ".join(unicodedata.normalize("NFC", value).casefold().split())



def _issue_from_error(message: str) -> dict[str, object]:
    category = "batch"
    field = "batch"
    code = "invalid"
    content_id = None
    if message.startswith("contentItems["):
        category = "content"
        head, _, detail = message.partition(": ")
        field = detail.split(":", 1)[0].strip() if "." not in detail[:1] else "content"
        if "." in head:
            field = head.split(".", 1)[1]
        code = detail.strip() if detail else "invalid"
    elif message.startswith("verbConjugations["):
        category = "verb"
        head, _, detail = message.partition(": ")
        field = head.split(".", 1)[1] if "." in head else "verb"
        code = detail.strip() if detail else "invalid"
    elif message.startswith("audio["):
        category = "audio"
        head, _, detail = message.partition(": ")
        field = head.split(".", 1)[1] if "." in head else "audio"
        code = detail.strip() if detail else "invalid"
    elif message.startswith("duplicate contentId"):
        category, field, code = "content", "id", "duplicate"
        content_id = message.rsplit(": ", 1)[-1]
    elif message.startswith("duplicate normalized german"):
        category, field, code = "content", "german", "duplicate_normalized"
    elif message.startswith("existing canonical german"):
        category, field, code = "content", "german", "canonical_duplicate"
    elif message.startswith("duplicate verb row"):
        category, field, code = "verb", "row", "duplicate"
    elif message.startswith("duplicate audio contentId"):
        category, field, code = "audio", "contentId", "duplicate"
    elif message.startswith("audio contentId is not in batch"):
        category, field, code = "audio", "contentId", "unknown_content"
        content_id = message.rsplit(": ", 1)[-1]
    return {"severity": "error", "category": category, "code": code, "field": field, "contentId": content_id, "message": message}

def filter_queue(queue: dict[str, object], *, severity: str | None = None, category: str | None = None, content_id: str | None = None) -> list[dict[str, object]]:
    items = queue.get("items", [])
    if not isinstance(items, list):
        return []
    return [item for item in items if isinstance(item, dict)
            and (severity is None or item.get("severity") == severity)
            and (category is None or item.get("category") == category)
            and (content_id is None or item.get("contentId") == content_id)]

def _build_review_queue(errors: list[str], warnings: list[str], content_ids: set[str]) -> dict[str, object]:
    items = [_issue_from_error(error) for error in errors]
    for warning in warnings:
        if warning.startswith("content items without audio:"):
            for content_id in sorted(content_ids):
                items.append({"severity":"warning", "category":"audio", "code":"missing_audio", "field":"audio", "contentId":content_id, "message":"content item has no audio entry"})
        else:
            items.append({"severity":"warning", "category":"batch", "code":"warning", "field":"batch", "contentId":None, "message":warning})
    rank = {"error": 0, "warning": 1}
    items.sort(key=lambda item: (rank[item["severity"]], item["category"], str(item["contentId"] or ""), item["code"]))
    return {"summary": {"error": sum(i["severity"] == "error" for i in items), "warning": sum(i["severity"] == "warning" for i in items)}, "items": items}

def review_batch(source: Path, *, existing_content_path: Path | None = None) -> dict[str, object]:
    data = _read(source)
    errors: list[str] = []
    warnings: list[str] = []
    content_ids: set[str] = set()
    german_keys: dict[str, str] = {}

    if not isinstance(data, dict) or set(data) != {"version", "languageCode", "contentItems", "verbConjugations", "audio"}:
        return {"status": "FAIL", "errors": ["review batch schema mismatch"], "warnings": [], "contentItems": 0, "verbConjugations": 0, "audioEntries": 0, "queue": {"summary": {"error": len(errors), "warning": len(warnings)}, "items": []}}
    if data["version"] != 1 or not isinstance(data["languageCode"], str) or not data["languageCode"]:
        errors.append("version/languageCode is invalid")
    if not isinstance(data["contentItems"], list):
        errors.append("contentItems must be an array")
    if not isinstance(data["verbConjugations"], list):
        errors.append("verbConjugations must be an array")
    if not isinstance(data["audio"], list):
        errors.append("audio must be an array")
    if errors:
        return {"status": "FAIL", "errors": errors, "warnings": warnings, "contentItems": 0, "verbConjugations": 0, "audioEntries": 0, "queue": {"summary": {"error": len(errors), "warning": len(warnings)}, "items": []}}

    for index, row in enumerate(data["contentItems"]):
        prefix = f"contentItems[{index}]"
        if not isinstance(row, dict) or set(row) != CONTENT_FIELDS:
            errors.append(f"{prefix}: schema mismatch")
            continue
        content_id = row["id"]
        if not isinstance(content_id, str) or not content_id.strip():
            errors.append(f"{prefix}.id: required")
        elif content_id in content_ids:
            errors.append(f"duplicate contentId: {content_id}")
        else:
            content_ids.add(content_id)
        for field in ("german", "arabic", "skill"):
            if not isinstance(row[field], str) or not row[field].strip():
                errors.append(f"{prefix}.{field}: required")
        if isinstance(row["german"], str) and row["german"].strip():
            german_key = _normalize_german(row["german"])
            previous_id = german_keys.get(german_key)
            if previous_id is not None:
                errors.append(f"duplicate normalized german: {row['german']} (contentId {previous_id})")
            else:
                german_keys[german_key] = content_id
        if not isinstance(row["accepted"], list) or not row["accepted"] or not all(isinstance(v, str) and v.strip() for v in row["accepted"]):
            errors.append(f"{prefix}.accepted: must contain at least one non-empty string")
        elif isinstance(row["german"], str) and row["german"] not in row["accepted"]:
            errors.append(f"{prefix}.accepted: must include german headword")
        if bool(row["sentence"]) != bool(row["sentenceAr"]):
            errors.append(f"{prefix}.sentence/sentenceAr: both must be provided together")

    verb_keys: set[tuple[str, str, str]] = set()
    for index, row in enumerate(data["verbConjugations"]):
        prefix = f"verbConjugations[{index}]"
        if not isinstance(row, dict) or set(row) != VERB_FIELDS:
            errors.append(f"{prefix}: schema mismatch")
            continue
        for field in ("infinitive", "arabic", "person", "form"):
            if not isinstance(row[field], str) or not row[field].strip():
                errors.append(f"{prefix}.{field}: required")
        key = (row["infinitive"], row["person"], row["form"])
        if key in verb_keys:
            errors.append(f"duplicate verb row: {key[0]} / {key[1]} / {key[2]}")
        else:
            verb_keys.add(key)
        if bool(row["example"]) != bool(row["exampleAr"]):
            errors.append(f"{prefix}.example/exampleAr: both must be provided together")
        if bool(row["pastExample"]) != bool(row["pastExampleAr"]):
            errors.append(f"{prefix}.pastExample/pastExampleAr: both must be provided together")

    audio_ids: set[str] = set()
    for index, row in enumerate(data["audio"]):
        prefix = f"audio[{index}]"
        if not isinstance(row, dict) or not set(row).issubset(AUDIO_FIELDS) or "contentId" not in row:
            errors.append(f"{prefix}: schema mismatch")
            continue
        content_id = row["contentId"]
        if content_id not in content_ids:
            errors.append(f"audio contentId is not in batch: {content_id}")
        if content_id in audio_ids:
            errors.append(f"duplicate audio contentId: {content_id}")
        else:
            audio_ids.add(content_id)
        for field, value in row.items():
            if field != "contentId" and (not isinstance(value, str) or not value.strip()):
                errors.append(f"{prefix}.{field}: must be non-empty")

    if existing_content_path is not None:
        existing = _read(existing_content_path)
        if not isinstance(existing, list):
            errors.append("existing canonical content must be an array")
        else:
            canonical_german: dict[str, str] = {}
            for row in existing:
                if isinstance(row, dict) and isinstance(row.get("german"), str) and row["german"].strip():
                    canonical_german[_normalize_german(row["german"])] = str(row.get("id", ""))
            for german_key, content_id in german_keys.items():
                canonical_id = canonical_german.get(german_key)
                if canonical_id is not None:
                    errors.append(f"existing canonical german: contentId {content_id} matches canonical contentId {canonical_id}")

    # Audio is optional; an entry may have no audio yet. This is a warning rather than
    # an error because content can be reviewed before recording assets are available.
    missing_audio = sorted(content_ids - audio_ids)
    if missing_audio:
        warnings.append(f"content items without audio: {len(missing_audio)}")

    return {
        "status": "PASS" if not errors else "FAIL",
        "errors": errors,
        "warnings": warnings,
        "contentItems": len(data["contentItems"]),
        "verbConjugations": len(data["verbConjugations"]),
        "audioEntries": len(data["audio"]),
        "queue": _build_review_queue(errors, warnings, content_ids),
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("command", choices=("review",))
    parser.add_argument("--source", required=True, type=Path)
    parser.add_argument("--report", type=Path)
    parser.add_argument("--content", type=Path)
    parser.add_argument("--severity", choices=("error", "warning"))
    parser.add_argument("--category")
    parser.add_argument("--content-id")
    args = parser.parse_args()
    try:
        report = review_batch(args.source, existing_content_path=args.content)
        filtered = filter_queue(report["queue"], severity=args.severity, category=args.category, content_id=args.content_id)
        if args.report:
            args.report.parent.mkdir(parents=True, exist_ok=True)
            output = dict(report)
            output["queue"] = {"summary": {
                "error": sum(i["severity"] == "error" for i in filtered),
                "warning": sum(i["severity"] == "warning" for i in filtered),
            }, "items": filtered}
            args.report.write_text(json.dumps(output, ensure_ascii=False, indent=2) + "\n", encoding="utf-8", newline="\n")
        print(f"CONTENT QUALITY GATE: {report['status']}")
        print(f"Content items: {report['contentItems']}")
        print(f"Verb rows: {report['verbConjugations']}")
        print(f"Audio entries: {report['audioEntries']}")
        print(f"Review queue: {len(filtered)} items")
        for warning in report["warnings"]:
            print(f"WARNING: {warning}")
        for error in report["errors"]:
            print(f"ERROR: {error}")
        return 0 if report["status"] == "PASS" else 1
    except ValueError as exc:
        print(str(exc), file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
