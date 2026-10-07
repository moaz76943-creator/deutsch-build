#!/usr/bin/env python3
from __future__ import annotations

import argparse
from collections import defaultdict
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
CONTENT_JSON = ROOT / "content" / "content_items.json"
OUT = ROOT / "tool" / "content_review_queue.json"


def _normalize(value: str) -> str:
    return re.sub(r"\s+", " ", value.lower()).strip()


def _distance(left: str, right: str) -> int:
    if abs(len(left) - len(right)) > 2:
        return 99
    previous = list(range(len(right) + 1))
    for row_index, left_char in enumerate(left, 1):
        current = [row_index]
        for column_index, right_char in enumerate(right, 1):
            current.append(
                min(
                    current[-1] + 1,
                    previous[column_index] + 1,
                    previous[column_index - 1] + (left_char != right_char),
                )
            )
        previous = current
    return previous[-1]


def _load_content() -> list[dict[str, object]]:
    payload = json.loads(CONTENT_JSON.read_text(encoding="utf-8"))
    if not isinstance(payload, list):
        raise ValueError("canonical content root must be an array")
    rows: list[dict[str, object]] = []
    for index, row in enumerate(payload):
        if not isinstance(row, dict):
            raise ValueError(f"canonical content row {index} must be an object")
        for field in ("id", "german", "arabic", "sentence", "sentenceAr"):
            if not isinstance(row.get(field), str):
                raise ValueError(
                    f"canonical content row {index} field {field} must be a string"
                )
        rows.append(row)
    return rows


def build_queue(rows: list[dict[str, object]]) -> dict[str, object]:
    buckets: dict[str, list[dict[str, object]]] = defaultdict(list)
    for row in rows:
        german = _normalize(str(row["german"]))
        if len(german) >= 5:
            buckets[german[:5]].append(row)

    queue: list[dict[str, str]] = []
    seen: set[tuple[str, str]] = set()
    for bucket in buckets.values():
        for index, left in enumerate(bucket):
            for right in bucket[index + 1 :]:
                left_german = _normalize(str(left["german"]))
                right_german = _normalize(str(right["german"]))
                pair = tuple(sorted((str(left["id"]), str(right["id"]))))
                if pair in seen:
                    continue
                threshold = 1 if max(len(left_german), len(right_german)) <= 9 else 2
                if _distance(left_german, right_german) > threshold:
                    continue
                seen.add(pair)
                queue.append(
                    {
                        "id_a": str(left["id"]),
                        "german_a": str(left["german"]),
                        "arabic_a": str(left["arabic"]),
                        "sentence_a": str(left["sentence"]),
                        "sentence_ar_a": str(left["sentenceAr"]),
                        "id_b": str(right["id"]),
                        "german_b": str(right["german"]),
                        "arabic_b": str(right["arabic"]),
                        "sentence_b": str(right["sentence"]),
                        "sentence_ar_b": str(right["sentenceAr"]),
                        "status": "needs_human_review",
                    }
                )
    return {"review_only": True, "count": len(queue), "items": queue}


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--check",
        action="store_true",
        help="verify the tracked review queue without mutating it",
    )
    args = parser.parse_args()

    try:
        payload = build_queue(_load_content())
        if args.check:
            tracked = json.loads(OUT.read_text(encoding="utf-8"))
            if tracked != payload:
                raise ValueError(
                    "tracked content review queue is stale against canonical JSON"
                )
            mutation = "NONE (check-only)"
        else:
            OUT.write_text(
                json.dumps(payload, ensure_ascii=False, indent=2),
                encoding="utf-8",
            )
            mutation = "REVIEW ARTIFACT ONLY"
    except (OSError, ValueError, json.JSONDecodeError) as exc:
        print(f"CONTENT REVIEW QUEUE: FAIL — {exc}")
        return 1

    print("CONTENT REVIEW QUEUE: PASS")
    print(f"Candidates: {payload['count']}")
    print(f"Output: {OUT.relative_to(ROOT)}")
    print(f"Mutation: {mutation}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
