"""Deterministic canonical JSON and runtime envelope helpers."""

from __future__ import annotations

import base64
import gzip
import json
from typing import Any, Mapping


def canonical_json_bytes(payload: Mapping[str, Any]) -> bytes:
    return (
        json.dumps(
            payload,
            ensure_ascii=False,
            sort_keys=True,
            separators=(",", ":"),
        )
        + "\n"
    ).encode("utf-8")


def runtime_envelope(
    document: Mapping[str, Any],
    canonical_json: bytes,
    sqlite_bytes: bytes,
) -> tuple[bytes, int]:
    pack = document["pack"]
    content_rows = len(document["lexicon"])
    verb_rows = sum(
        len(entry["fields"].get("verbRows", []))
        for entry in document["lexicon"]
    )
    metadata = canonical_json_bytes(
        {
            "schemaVersion": document["schemaVersion"],
            "contentRows": content_rows,
            "verbRows": verb_rows,
            "packId": pack["id"],
            "languageCode": pack["languageCode"],
            "displayName": pack["displayName"],
            "version": pack["version"],
            "contractVersion": pack["contractVersion"],
            "textDirection": pack["textDirection"],
        }
    )
    files = {
        "content/content.json": canonical_json,
        "content/content.sqlite": sqlite_bytes,
        "metadata/pack.json": metadata,
    }
    installed_size = sum(len(content) for content in files.values())
    envelope = {
        "packId": pack["id"],
        "version": pack["version"],
        "contractVersion": pack["contractVersion"],
        "files": [
            {
                "path": path,
                "contentBase64": base64.b64encode(content).decode("ascii"),
            }
            for path, content in sorted(files.items())
        ],
    }
    encoded = canonical_json_bytes(envelope)
    return gzip.compress(encoded, compresslevel=9, mtime=0), installed_size
