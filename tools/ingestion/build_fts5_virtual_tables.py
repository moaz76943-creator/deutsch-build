#!/usr/bin/env python3
"""Build an offline lexicon FTS5 trigram index in a NEW SQLite pack.

Usage:
  python tools/ingestion/build_fts5_virtual_tables.py \
    --source path/to/source.sqlite --output path/to/searchable.sqlite

The source is opened read-only and is never modified. Build the index before
pack signing and before computing the package hash. In particular, do not
replace the checked-in German Golden database without updating its separate
integrity contract in an explicitly authorized task.

lexicon_fts is a standalone FTS5 virtual table, not an external-content table:
lexicon has no translation_ar column (it is stored in fields_json). The FTS5
rowid is identical to the original lexicon rowid for cheap lookup joins.
"""

from __future__ import annotations

import argparse
from contextlib import closing
import json
import os
import sqlite3
import tempfile
from pathlib import Path
from typing import Any, Iterator

_BATCH_SIZE = 512


def _direct_arabic_translations(raw: Any) -> str:
    """Return only explicitly Arabic-labelled translations, never pivot text."""
    if not isinstance(raw, str) or not raw:
        return ""
    try:
        fields = json.loads(raw)
    except (json.JSONDecodeError, TypeError):
        return ""
    if not isinstance(fields, dict):
        return ""

    values: list[str] = []

    def add(value: Any) -> None:
        if isinstance(value, str):
            if value.strip():
                values.append(value.strip())
        elif isinstance(value, list):
            for entry in value:
                add(entry)

    # Legacy lexicon format.
    add(fields.get("translation_ar"))
    # Canonical language-labelled pairs (do not index translations to other languages).
    translations = fields.get("translations")
    if isinstance(translations, list):
        for item in translations:
            if isinstance(item, dict) and (
                item.get("languageCode") == "ar"
                or item.get("language_code") == "ar"
            ):
                add(item.get("text"))
    elif isinstance(translations, dict):
        add(translations.get("ar"))

    if (fields.get("translationLanguageCode") == "ar"
            or fields.get("translation_language_code") == "ar"):
        add(fields.get("translation"))

    return "\n".join(dict.fromkeys(values))


def _validate_lexicon(connection: sqlite3.Connection) -> None:
    columns = {
        row[1] for row in connection.execute("PRAGMA table_info(lexicon)")
    }
    required = {"id", "surface", "part_of_speech", "fields_json"}
    missing = required - columns
    if missing:
        raise ValueError(f"lexicon is missing required columns: {sorted(missing)}")
    try:
        connection.execute("SELECT rowid FROM lexicon LIMIT 1").fetchone()
    except sqlite3.DatabaseError as exc:
        raise ValueError("lexicon must expose a stable SQLite rowid") from exc


def _ensure_fts_schema(connection: sqlite3.Connection) -> None:
    existing = connection.execute(
        "SELECT sql FROM sqlite_master WHERE name = 'lexicon_fts'"
    ).fetchone()
    if existing is not None:
        ddl = str(existing[0] or "").lower()
        if ("using fts5(" not in ddl or "tokenize='trigram'" not in ddl
                or "surface" not in ddl or "translation_ar" not in ddl):
            raise ValueError("lexicon_fts already exists with an incompatible schema")

    # Standalone table: translation_ar does not exist as a column of lexicon.
    connection.execute(
        "CREATE VIRTUAL TABLE IF NOT EXISTS lexicon_fts "
        "USING fts5(surface, translation_ar, tokenize='trigram')"
    )
    # Provides the legacy prefix fallback when FTS5 is absent on Android.
    connection.execute(
        "CREATE INDEX IF NOT EXISTS idx_lexicon_surface_nocase "
        "ON lexicon(surface COLLATE NOCASE)"
    )


def _read_batches(connection: sqlite3.Connection) -> Iterator[list[tuple[int, str, str]]]:
    cursor = connection.execute(
        "SELECT rowid, surface, fields_json FROM lexicon ORDER BY rowid"
    )
    while True:
        rows = cursor.fetchmany(_BATCH_SIZE)
        if not rows:
            return
        yield [
            (int(rowid), str(surface or ""), _direct_arabic_translations(fields))
            for rowid, surface, fields in rows
        ]


def build(connection: sqlite3.Connection) -> int:
    """Rebuild within a single transaction. Caller owns the connection."""
    _validate_lexicon(connection)
    with connection:
        _ensure_fts_schema(connection)
        connection.execute("DELETE FROM lexicon_fts")
        indexed = 0
        for batch in _read_batches(connection):
            connection.executemany(
                "INSERT INTO lexicon_fts(rowid, surface, translation_ar) "
                "VALUES (?, ?, ?)",
                batch,
            )
            indexed += len(batch)
        # Ensure all records are accounted for; rowids remain synchronized.
        source_count = connection.execute("SELECT COUNT(*) FROM lexicon").fetchone()[0]
        fts_count = connection.execute("SELECT COUNT(*) FROM lexicon_fts").fetchone()[0]
        if indexed != source_count or fts_count != source_count:
            raise RuntimeError("FTS5 row count differs from core lexicon")
        connection.execute(
            "INSERT INTO lexicon_fts(lexicon_fts) VALUES('integrity-check')"
        )
    return indexed


def build_copy(source: Path, output: Path) -> int:
    source = source.resolve(strict=True)
    output = output.resolve()
    if not source.is_file():
        raise ValueError("source must be a regular SQLite file")
    if source == output:
        raise ValueError("source and output must be different files")
    if output.exists():
        raise FileExistsError(f"Refusing to overwrite an existing file: {output}")
    if not output.parent.is_dir():
        raise FileNotFoundError(f"Output directory does not exist: {output.parent}")

    fd, temp_name = tempfile.mkstemp(
        prefix=".fts5-index-", suffix=".sqlite", dir=output.parent
    )
    os.close(fd)
    temp = Path(temp_name)
    try:
        with closing(sqlite3.connect(source.as_uri() + "?mode=ro", uri=True)) as src:
            with closing(sqlite3.connect(temp)) as dst:
                # SQLite backup provides a consistent snapshot, even with WAL.
                src.backup(dst)
                dst.execute("PRAGMA journal_mode=DELETE")
                count = build(dst)
        # Never replace pre-existing output; caller must select a fresh path.
        if output.exists():
            raise FileExistsError(f"Output appeared during build: {output}")
        os.link(temp, output)
        return count
    finally:
        temp.unlink(missing_ok=True)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", type=Path, required=True,
                        help="Read-only canonical SQLite pack")
    parser.add_argument("--output", type=Path, required=True,
                        help="New FTS5-indexed SQLite pack path (must not exist)")
    args = parser.parse_args()
    try:
        count = build_copy(args.source, args.output)
    except (ValueError, FileNotFoundError, FileExistsError,
            sqlite3.DatabaseError, OSError, RuntimeError) as exc:
        parser.exit(1, f"FTS5 build failed: {exc}\n")
    print(f"Indexed {count} lexicon rows into {args.output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
