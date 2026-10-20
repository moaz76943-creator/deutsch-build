#!/usr/bin/env python3
"""Build the embedded, review-sourced German↔Arabic SQLite v2 lexicon.

Source is the TSV itself; no Kaikki, synthetic examples, machine translation,
network requests, CI jobs, APK tools, or outside datasets are used.

Run from the repository root:
  python3 tools/ingestion/build_curated_sqlite.py \
    --source tools/ingestion/data/de_ar_curated_master.tsv \
    --output assets/content/packs/de/sqlite/de-1.0.0.sqlite --replace

The SHA-256 emitted here MUST be copied into DatabaseService.germanGoldenSha256.
"""
from __future__ import annotations

import argparse
import csv
import hashlib
import json
import os
import re
import sqlite3
import tempfile
import unicodedata
from pathlib import Path

LEVELS = frozenset(("A1", "A2", "B1", "B2", "C1", "C2"))
POS = frozenset(("noun", "verb", "adj", "adv", "prep", "pronoun", "conj", "interjection", "article", "num"))
ARTICLES = frozenset(("der", "die", "das"))


def german_sort_key(surface: str) -> str:
    """ASCII case-insensitive German key, not an ICU collation weight."""
    key = unicodedata.normalize("NFKC", surface).casefold()
    for char, replacement in (("ä", "ae"), ("ö", "oe"), ("ü", "ue"), ("ß", "ss")):
        key = key.replace(char, replacement)
    # Fold other diacritics, then remove punctuation, spaces, and symbols.
    key = "".join(c for c in unicodedata.normalize("NFKD", key)
                  if not unicodedata.combining(c))
    return re.sub(r"[^a-z0-9]", "", key)


def _load_rows(source: Path, expected_count: int) -> list[dict[str, str]]:
    with source.open("r", encoding="utf-8-sig", newline="") as stream:
        reader = csv.DictReader(stream, delimiter="\t", strict=True)
        required = {"lemma", "pos", "translation_ar", "ipa", "cefr", "gender_article"}
        if reader.fieldnames is None or set(reader.fieldnames) != required:
            raise ValueError(f"Expected TSV columns {sorted(required)}")
        rows = []
        seen = set()
        for line, original in enumerate(reader, 2):
            if None in original or any(v is None for v in original.values()):
                raise ValueError(f"TSV row {line}: invalid column count")
            row = {key: unicodedata.normalize("NFC", value.strip()) for key, value in original.items()}
            lemma, pos, arabic = (row[name] for name in ("lemma", "pos", "translation_ar"))
            if not lemma or not arabic or not row["ipa"]:
                raise ValueError(f"TSV row {line}: lemma, translation_ar, ipa are mandatory")
            if pos not in POS:
                raise ValueError(f"TSV row {line}: unsupported part of speech {pos}")
            if row["cefr"] not in LEVELS:
                raise ValueError(f"TSV row {line}: invalid CEFR level")
            if row["gender_article"] and (pos != "noun" or row["gender_article"] not in ARTICLES):
                raise ValueError(f"TSV row {line}: invalid noun article")
            key = (unicodedata.normalize("NFKC", lemma).casefold(), pos)
            if key in seen:
                raise ValueError(f"TSV row {line}: duplicate lemma/POS {lemma!r}/{pos}")
            seen.add(key)
            if not german_sort_key(lemma):
                raise ValueError(f"TSV row {line}: empty German sort key")
            rows.append(row)
        if len(rows) != expected_count:
            raise ValueError(f"Expected {expected_count} TSV words; found {len(rows)}")
        return rows



def _init_schema(db: sqlite3.Connection) -> None:
    db.execute("PRAGMA page_size=4096")
    db.execute("PRAGMA journal_mode=DELETE")
    db.execute("PRAGMA foreign_keys=ON")
    db.executescript("""
        CREATE TABLE metadata(key TEXT PRIMARY KEY, value TEXT NOT NULL);
        CREATE TABLE localization(key TEXT PRIMARY KEY, text TEXT NOT NULL, direction TEXT NOT NULL);
        CREATE TABLE lexicon(
            id TEXT PRIMARY KEY, surface TEXT NOT NULL, sort_key TEXT NOT NULL,
            pos TEXT NOT NULL, part_of_speech TEXT NOT NULL,
            cefr_level TEXT NOT NULL, ipa TEXT,
            language_code TEXT NOT NULL DEFAULT 'de',
            fields_json TEXT NOT NULL, direction TEXT NOT NULL DEFAULT 'ltr',
            frequency_rank INTEGER);
        CREATE INDEX idx_lexicon_cefr_freq ON lexicon(cefr_level,frequency_rank);
        CREATE INDEX idx_lexicon_surface_nocase ON lexicon(surface COLLATE NOCASE);
        CREATE INDEX idx_lexicon_sort ON lexicon(sort_key,id);
        CREATE TABLE grammar(id TEXT PRIMARY KEY, title_key TEXT NOT NULL, tree_json TEXT NOT NULL);
        CREATE TABLE concepts(
            concept_id TEXT PRIMARY KEY, sense_id TEXT NOT NULL,
            lemma TEXT NOT NULL, part_of_speech TEXT NOT NULL,
            register TEXT NOT NULL, cefr TEXT NOT NULL,
            surface TEXT NOT NULL, direction TEXT NOT NULL,
            semantic_tags_json TEXT NOT NULL DEFAULT '[]',
            legacy_fields_json TEXT NOT NULL DEFAULT '{}');
        CREATE TABLE lexemes(
            id TEXT PRIMARY KEY, lexicon_id TEXT NOT NULL REFERENCES lexicon(id),
            lemma TEXT NOT NULL, pos TEXT NOT NULL,
            language_code TEXT NOT NULL DEFAULT 'de',
            lexeme_id TEXT UNIQUE NOT NULL, concept_id TEXT NOT NULL REFERENCES concepts(concept_id),
            sense_id TEXT NOT NULL, part_of_speech TEXT NOT NULL,
            display_text TEXT NOT NULL, ipa TEXT,
            gender TEXT, article TEXT, plural TEXT,
            cefr_level TEXT NOT NULL, grammar_json TEXT NOT NULL DEFAULT '{}');
        CREATE INDEX idx_lexemes_lexicon_id ON lexemes(lexicon_id);
        CREATE TABLE examples(
            id TEXT PRIMARY KEY, lexicon_id TEXT REFERENCES lexicon(id),
            source_text TEXT NOT NULL, target_text TEXT NOT NULL,
            language_code TEXT NOT NULL DEFAULT 'de',
            example_id TEXT UNIQUE, group_id TEXT,
            sentence TEXT, translation_ar TEXT);
        CREATE INDEX idx_examples_lexicon_id ON examples(lexicon_id);
        CREATE TABLE inflections_lookup(
            inflected_form TEXT NOT NULL, surface_form TEXT NOT NULL,
            lemma TEXT NOT NULL, lexicon_id TEXT NOT NULL REFERENCES lexicon(id),
            language_code TEXT NOT NULL DEFAULT 'de',
            PRIMARY KEY(inflected_form,lexicon_id,language_code));
        CREATE INDEX idx_inflections_lookup_surface
            ON inflections_lookup(inflected_form COLLATE NOCASE,language_code COLLATE NOCASE);
        CREATE INDEX idx_inflections_lookup_surface_form
            ON inflections_lookup(surface_form COLLATE NOCASE,language_code COLLATE NOCASE);
        CREATE TABLE verbs(verb_id TEXT PRIMARY KEY, infinitive TEXT NOT NULL,
            translation_ar TEXT, frequency_rank INTEGER);
        CREATE TABLE verb_conjugations(conjugation_id TEXT PRIMARY KEY,
            verb_id TEXT NOT NULL REFERENCES verbs(verb_id),
            tense TEXT NOT NULL, person TEXT NOT NULL,
            conjugated_form TEXT NOT NULL);
        CREATE INDEX idx_verb_conjugations_verb_tense ON verb_conjugations(verb_id,tense);
        CREATE TABLE idioms(idiom_id TEXT PRIMARY KEY, expression TEXT NOT NULL,
            translation_ar TEXT, explanation TEXT, language_code TEXT);
        CREATE TABLE nominals(id TEXT PRIMARY KEY NOT NULL,
            lemma TEXT NOT NULL, part_of_speech TEXT NOT NULL,
            gender TEXT NOT NULL, number TEXT NOT NULL);
        CREATE TABLE nominal_declensions(id TEXT PRIMARY KEY NOT NULL,
            nominal_id TEXT NOT NULL REFERENCES nominals(id),
            grammatical_case TEXT NOT NULL, number TEXT NOT NULL,
            definiteness TEXT NOT NULL, inflected_form TEXT NOT NULL);
        CREATE INDEX idx_nominal_declensions_nominal_case_number
            ON nominal_declensions(nominal_id,grammatical_case,number);
        CREATE VIRTUAL TABLE lexicon_fts
            USING fts5(surface,translation_ar,tokenize='trigram');
    """)


def _insert_metadata(db: sqlite3.Connection, num_rows: int) -> None:
    metadata = {
        "schemaVersion": "2.0.0", "languageCode": "de", "packId": "de",
        "contentRows": str(num_rows), "verbRows": "0", "version": "1.0.0",
        "contractVersion": "1.0.0", "textDirection": "ltr",
        "source": "tools/ingestion/data/de_ar_curated_master.tsv",
    }
    db.executemany("INSERT INTO metadata VALUES (?,?)", sorted(metadata.items()))


def _insert_lexicon_data(db: sqlite3.Connection, rows: list[dict[str, str]]) -> None:
    for row in rows:
        lemma, pos, arabic, ipa, cefr, article = (
            row[name] for name in ("lemma", "pos", "translation_ar", "ipa", "cefr", "gender_article")
        )
        identity = f"de\x00{lemma}\x00{pos}".encode("utf-8")
        lexicon_id = "de-" + hashlib.sha256(identity).hexdigest()[:24]
        fields = {
            "lemma": lemma, "ipa": ipa, "canonical": {"cefr": cefr},
            "translation_ar": arabic, "translation": arabic,
            "translationLanguageCode": "ar",
            "translations": [{"languageCode": "ar", "text": arabic}],
            "definitions": [],
        }
        if article:
            fields["article"] = article
            fields["gender_article"] = article
        fields_json = json.dumps(fields, ensure_ascii=False, sort_keys=True, separators=(",", ":"))
        db.execute("""INSERT INTO lexicon
            (id,surface,sort_key,pos,part_of_speech,cefr_level,ipa,fields_json)
            VALUES (?,?,?,?,?,?,?,?)""", (lexicon_id, lemma, german_sort_key(lemma), pos, pos, cefr, ipa, fields_json))
        db.execute("INSERT INTO concepts VALUES (?,?,?,?,?,?,?,?,?,?)", (
            lexicon_id, lexicon_id, lemma, pos, "neutral", cefr, lemma, "ltr", "[]", fields_json))
        db.execute("""INSERT INTO lexemes
            (id,lexicon_id,lemma,pos,lexeme_id,concept_id,sense_id,
            part_of_speech,display_text,ipa,gender,article,cefr_level)
            VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)""", (
            lexicon_id, lexicon_id, lemma, pos, lexicon_id, lexicon_id,
            lexicon_id, pos, lemma, ipa, article or None, article or None, cefr))
        # Lemma lookup only: do not invent inflected forms not present in TSV.
        db.execute("""INSERT INTO inflections_lookup
            (inflected_form,surface_form,lemma,lexicon_id) VALUES (?,?,?,?)""",
            (lemma, lemma, lemma, lexicon_id))


def _populate_fts(db: sqlite3.Connection) -> None:
    db.execute("""INSERT INTO lexicon_fts(rowid,surface,translation_ar)
        SELECT l.rowid, l.surface, json_extract(l.fields_json,'$.translation_ar')
        FROM lexicon AS l ORDER BY l.rowid""")
    db.execute("INSERT INTO lexicon_fts(lexicon_fts) VALUES ('integrity-check')")


def _verify_database(db: sqlite3.Connection, num_rows: int) -> None:
    if db.execute("PRAGMA integrity_check").fetchone()[0] != "ok":
        raise ValueError("SQLite integrity check failed")
    if db.execute("PRAGMA foreign_key_check").fetchall():
        raise ValueError("SQLite foreign key check failed")
    count = db.execute("SELECT COUNT(*) FROM lexicon_fts").fetchone()[0]
    if count != num_rows:
        raise ValueError(f"FTS mismatch {count} != {num_rows}")


def _make_sqlite(destination: Path, rows: list[dict[str, str]]) -> None:
    with sqlite3.connect(destination) as db:
        _init_schema(db)
        _insert_metadata(db, len(rows))
        _insert_lexicon_data(db, rows)
        _populate_fts(db)
        db.execute("PRAGMA user_version=2")
        db.commit()
        _verify_database(db, len(rows))
        db.execute("VACUUM")


def build_curated_sqlite(source: Path, output: Path, *, expected_count: int = 1000,
                         replace: bool = False) -> str:
    rows = _load_rows(source, expected_count)
    output.parent.mkdir(parents=True, exist_ok=True)
    fd, name = tempfile.mkstemp(prefix=".curated-de-", suffix=".sqlite", dir=output.parent)
    os.close(fd)
    staging = Path(name)
    try:
        _make_sqlite(staging, rows)
        raw = staging.read_bytes()
        sha = hashlib.sha256(raw).hexdigest()
        if output.exists():
            if output.read_bytes() == raw:
                return sha
            if not replace:
                raise FileExistsError(f"Refusing to replace differing golden asset: {output}")
        os.replace(staging, output)
        return sha
    finally:
        staging.unlink(missing_ok=True)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--expected-count", type=int, default=1000)
    parser.add_argument("--replace", action="store_true", help="Explicitly replace a differing SQLite asset")
    args = parser.parse_args()
    if args.expected_count < 1:
        parser.error("--expected-count must be positive")
    try:
        sha = build_curated_sqlite(args.source, args.output,
                                   expected_count=args.expected_count,
                                   replace=args.replace)
    except (OSError, ValueError, sqlite3.Error) as error:
        parser.exit(1, f"Curated SQLite build failed: {error}\n")
    print(f"SHA-256 {sha}  {args.output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
