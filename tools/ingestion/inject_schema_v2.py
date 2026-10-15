#!/usr/bin/env python3
"""Lossless, fully offline v2 schema injection for already-built SQLite packs.

Run before envelope packaging/signing/hashing. Source remains read-only and
the output path must be new. Requires SQLite with the FTS5 trigram tokenizer.
"""
from __future__ import annotations

import argparse
from contextlib import closing
import json
import os
import sqlite3
import tempfile
import unicodedata
from pathlib import Path
from urllib.parse import quote

SCHEMA_VERSION = "2.0.0"
MORPHOLOGY_DDL = (
    "CREATE TABLE IF NOT EXISTS verbs (verb_id TEXT PRIMARY KEY, infinitive TEXT NOT NULL, translation_ar TEXT, frequency_rank INTEGER)",
    "CREATE TABLE IF NOT EXISTS verb_conjugations (conjugation_id TEXT PRIMARY KEY, verb_id TEXT NOT NULL, tense TEXT NOT NULL, person TEXT NOT NULL, conjugated_form TEXT NOT NULL, FOREIGN KEY(verb_id) REFERENCES verbs(verb_id))",
    "CREATE INDEX IF NOT EXISTS idx_verb_conjugations_verb_tense ON verb_conjugations(verb_id, tense)",
    "CREATE TABLE IF NOT EXISTS idioms (idiom_id TEXT PRIMARY KEY, expression TEXT NOT NULL, translation_ar TEXT, explanation TEXT, language_code TEXT)",
    "CREATE TABLE IF NOT EXISTS nominals (id TEXT PRIMARY KEY NOT NULL CHECK(length(trim(id))>0), lemma TEXT NOT NULL CHECK(length(trim(lemma))>0), part_of_speech TEXT NOT NULL CHECK(part_of_speech IN ('noun','adjective','pronoun')), gender TEXT NOT NULL CHECK(length(trim(gender))>0), number TEXT NOT NULL CHECK(length(trim(number))>0))",
    "CREATE TABLE IF NOT EXISTS nominal_declensions (id TEXT PRIMARY KEY NOT NULL CHECK(length(trim(id))>0), nominal_id TEXT NOT NULL CHECK(length(trim(nominal_id))>0), grammatical_case TEXT NOT NULL CHECK(length(trim(grammatical_case))>0), number TEXT NOT NULL CHECK(length(trim(number))>0), definiteness TEXT NOT NULL CHECK(length(trim(definiteness))>0), inflected_form TEXT NOT NULL CHECK(length(trim(inflected_form))>0), FOREIGN KEY(nominal_id) REFERENCES nominals(id) ON DELETE RESTRICT)",
    "CREATE INDEX IF NOT EXISTS idx_nominal_declensions_nominal_case_number ON nominal_declensions(nominal_id, grammatical_case, number)",
)


def _arabic_translations(fields: dict) -> str:
    values = []

    def add(value):
        if isinstance(value, str) and value.strip():
            values.append(value.strip())
        elif isinstance(value, list):
            for item in value:
                add(item)

    add(fields.get("translation_ar"))
    translations = fields.get("translations")
    if isinstance(translations, dict):
        add(translations.get("ar"))
    elif isinstance(translations, list):
        for item in translations:
            if isinstance(item, dict) and item.get("languageCode", item.get("language_code")) == "ar":
                add(item.get("text"))
    if fields.get("translationLanguageCode", fields.get("translation_language_code")) == "ar":
        add(fields.get("translation"))
    return "\n".join(dict.fromkeys(values))


def _metadata(fields: dict, surface: str):
    canonical = fields.get("canonical")
    if not isinstance(canonical, dict):
        canonical = {}
    cefr = next((v for v in (canonical.get("cefr"), fields.get("cefr_level"), fields.get("cefr")) if v is not None), None)
    if cefr is not None and cefr not in ("A1", "A2", "B1", "B2", "C1", "C2", "unknown"):
        raise ValueError(f"unsupported CEFR label: {cefr!r}")
    rank = next((v for v in (canonical.get("frequencyRank"), canonical.get("frequency_rank"), fields.get("frequency_rank"), fields.get("frequencyRank")) if v is not None), None)
    if rank is not None and (type(rank) is not int or rank < 1):
        raise ValueError(f"invalid frequency rank: {rank!r}")
    key = unicodedata.normalize("NFKC", surface).casefold()
    return cefr, rank, key


def inject_schema(connection: sqlite3.Connection) -> int:
    """Upgrade flat lexicon schema and rebuild index using stable lexicon rowids."""
    columns = {row[1]: str(row[2]).upper() for row in connection.execute("PRAGMA table_info(lexicon)")}
    required = {"id", "surface", "part_of_speech", "fields_json"}
    if not required <= columns.keys():
        raise ValueError(f"lexicon missing columns: {sorted(required - columns.keys())}")
    for name, datatype in (("cefr_level", "TEXT"), ("frequency_rank", "INTEGER"), ("sort_key", "TEXT")):
        if name not in columns:
            connection.execute(f"ALTER TABLE lexicon ADD COLUMN {name} {datatype}")
        elif columns[name] != datatype:
            raise ValueError(f"lexicon.{name} has incompatible type {columns[name]}")
    connection.execute("CREATE INDEX IF NOT EXISTS idx_lexicon_cefr_freq ON lexicon(cefr_level, frequency_rank)")
    connection.execute("CREATE INDEX IF NOT EXISTS idx_lexicon_surface_nocase ON lexicon(surface COLLATE NOCASE)")
    for statement in MORPHOLOGY_DDL:
        connection.execute(statement)
    existing = connection.execute("SELECT sql FROM sqlite_master WHERE name='lexicon_fts'").fetchone()
    if existing:
        sql = (existing[0] or "").lower().replace('"', "'")
        if "using fts5(" not in sql or "trigram" not in sql or "translation_ar" not in sql or "surface" not in sql:
            raise ValueError("incompatible existing lexicon_fts schema")
    connection.execute("CREATE VIRTUAL TABLE IF NOT EXISTS lexicon_fts USING fts5(surface, translation_ar, tokenize='trigram')")
    connection.execute("DELETE FROM lexicon_fts")
    cursor = connection.execute("SELECT rowid, surface, fields_json, cefr_level, frequency_rank, sort_key FROM lexicon ORDER BY rowid")
    count = 0
    while True:
        batch = cursor.fetchmany(512)
        if not batch:
            break
        updates = []
        fts = []
        for rowid, surface, raw, prior_cefr, prior_rank, prior_sort in batch:
            fields = json.loads(raw)
            if not isinstance(fields, dict):
                raise ValueError(f"invalid fields_json at rowid={rowid}")
            cefr, rank, key = _metadata(fields, surface)
            cefr = cefr if cefr is not None else prior_cefr
            rank = rank if rank is not None else prior_rank
            key = prior_sort or key
            updates.append((cefr, rank, key, rowid))
            fts.append((rowid, surface, _arabic_translations(fields)))
        connection.executemany("UPDATE lexicon SET cefr_level=?, frequency_rank=?, sort_key=? WHERE rowid=?", updates)
        connection.executemany("INSERT INTO lexicon_fts(rowid, surface, translation_ar) VALUES (?,?,?)", fts)
        count += len(batch)
    actual = connection.execute("SELECT count(*) FROM lexicon_fts").fetchone()[0]
    if actual != count:
        raise ValueError("FTS row count mismatch")
    connection.execute("INSERT INTO lexicon_fts(lexicon_fts) VALUES ('integrity-check')")
    connection.execute("PRAGMA user_version=2")
    return count


def build_copy(source: Path, output: Path) -> int:
    source = source.resolve(strict=True)
    output = output.resolve()
    if not source.is_file() or source == output or output.exists():
        raise ValueError("source must exist and output must be a new distinct file")
    if not output.parent.is_dir():
        raise FileNotFoundError(output.parent)
    fd, filename = tempfile.mkstemp(prefix=".schema-v2-", suffix=".sqlite", dir=output.parent)
    os.close(fd)
    temp = Path(filename)
    try:
        with closing(sqlite3.connect("file:" + quote(str(source), safe="/") + "?mode=ro", uri=True)) as src:
            with closing(sqlite3.connect(temp)) as dst:
                src.backup(dst)
                with dst:
                    count = inject_schema(dst)
                if dst.execute("PRAGMA integrity_check").fetchone()[0] != "ok":
                    raise ValueError("SQLite integrity_check failed")
                dst.execute("VACUUM")
        os.link(temp, output)
        return count
    finally:
        temp.unlink(missing_ok=True)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    try:
        count = build_copy(args.source, args.output)
    except (OSError, ValueError, sqlite3.Error) as exc:
        parser.exit(1, f"schema injection failed: {exc}\n")
    print(f"Injected SQLite schema {SCHEMA_VERSION} for {count} lexicon rows: {args.output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
