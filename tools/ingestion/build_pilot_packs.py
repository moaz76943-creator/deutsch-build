#!/usr/bin/env python3
"""Deterministic offline pilot pack compiler (Python 3.10+, stdlib only).

CLI:
  --input-dir    Directory containing <lang>.jsonl[.gz] or <lang>.json[.gz].
  --rankings-dir Optional directory of <lang>.csv (word,rank[,cefr]).
  --out-dir      New/deterministically identical .pack.gz and manifest.json outputs.
  --limit        Maximum selected lexical items per language (default 3000).
  --curated-tsv  Optional curated de→ar TSV (surface, pos, translation_ar).

Supported languages: en, de, es, fr, tr. No network calls, synthetic CEFR
labels, machine translation, signing, or release/store publication. Input
must be reviewed and redistribution-licensed before any production use.
FTS5 with the trigram tokenizer must be enabled in local Python SQLite.
"""
from __future__ import annotations

import argparse
import base64
import csv
import gzip
import hashlib
import io
import json
import os
import sqlite3
import tempfile
import unicodedata
from pathlib import Path

try:
    from tools.ingestion.inject_schema_v2 import SCHEMA_VERSION, inject_schema
    from tools.ingestion.sort_key_generator import generate_sort_key
except ModuleNotFoundError:
    from inject_schema_v2 import SCHEMA_VERSION, inject_schema
    from sort_key_generator import generate_sort_key

LANGS = ("de", "en", "es", "fr", "tr")
LEVELS = {"A1", "A2", "B1", "B2", "C1", "C2", "unknown"}
MAX_LINES = 1_000_000
MAX_BYTES = 8_000_000
VERSION = "2.0.0"


def canonical(data: object) -> bytes:
    return (json.dumps(data, ensure_ascii=False, sort_keys=True,
                       separators=(",", ":")) + "\n").encode("utf-8")


def digest(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def read_input(source: Path):
    opener = gzip.open if source.suffix == ".gz" else open
    kind = source.suffixes[-2] if source.suffix == ".gz" else source.suffix
    with opener(source, "rt", encoding="utf-8", errors="strict") as handle:
        if kind == ".json":
            data = json.load(handle)
            if isinstance(data, dict):
                data = data.get("lexicon", data.get("entries"))
            if not isinstance(data, list):
                raise ValueError(f"{source.name}: expected JSON entries array")
            if len(data) > MAX_LINES:
                raise ValueError(f"{source.name}: too many entries")
            yield from data
        else:
            for count, line in enumerate(handle, 1):
                if count > MAX_LINES or len(line) > MAX_BYTES:
                    raise ValueError(f"{source.name}: record/line limit exceeded")
                if line.strip():
                    yield json.loads(line)


def source_path(root: Path, lang: str) -> Path | None:
    for ending in (".jsonl.gz", ".jsonl", ".json.gz", ".json"):
        path = root / (lang + ending)
        if path.is_file():
            return path
    return None


def text(value: object, limit: int = 1000) -> str | None:
    if not isinstance(value, str):
        return None
    value = unicodedata.normalize("NFC", value.strip())
    if not value or len(value) > limit or any(ord(c) < 32 for c in value):
        return None
    return value


def ranks(source: Path | None) -> dict[str, tuple[int, str | None]]:
    if source is None or not source.exists():
        return {}
    result: dict[str, tuple[int, str | None]] = {}
    with source.open(encoding="utf-8-sig", newline="") as stream:
        reader = csv.DictReader(stream)
        if not reader.fieldnames or not {"word", "rank"} <= set(reader.fieldnames):
            raise ValueError(f"{source}: CSV must contain word,rank")
        for row in reader:
            word = text(row.get("word"), 160)
            if not word:
                continue
            try:
                rank = int(row["rank"])
            except (ValueError, TypeError) as exc:
                raise ValueError(f"{source}: noninteger frequency rank") from exc
            if rank <= 0:
                raise ValueError(f"{source}: rank must be positive")
            level = row.get("cefr") or None
            if level and level not in LEVELS:
                raise ValueError(f"{source}: invalid CEFR {level}")
            key = unicodedata.normalize("NFKC", word).casefold()
            current = result.get(key)
            if current is None or (rank, level or "") < (current[0], current[1] or ""):
                result[key] = (rank, level)
    return result


def read_curated_tsv(source: Path) -> dict[tuple[str, str], list[str]]:
    """Read editorial German→Arabic overrides; require unambiguous lemma/POS.

    TSV columns: surface, pos, translation_ar. Repeated key rows add senses
    in editorial order. No automatic translation or language guessing.
    """
    result: dict[tuple[str, str], list[str]] = {}
    with source.open(encoding="utf-8-sig", newline="") as stream:
        reader = csv.DictReader(stream, delimiter="\t")
        required = {"surface", "pos", "translation_ar"}
        if not reader.fieldnames or not required <= set(reader.fieldnames):
            raise ValueError(
                f"{source}: TSV must have surface, pos, translation_ar columns")
        for line_number, row in enumerate(reader, 2):
            if line_number > MAX_LINES:
                raise ValueError(f"{source}: too many curated rows")
            if None in row:
                raise ValueError(f"{source}:{line_number}: excess TSV columns")
            surface = text(row.get("surface"), 160)
            pos = text(row.get("pos"), 64)
            arabic = text(row.get("translation_ar"), 1000)
            if not surface or not pos or not arabic:
                raise ValueError(
                    f"{source}:{line_number}: incomplete curated translation")
            key = (unicodedata.normalize("NFKC", surface).casefold(),
                   pos.casefold())
            meanings = result.setdefault(key, [])
            if arabic not in meanings:
                meanings.append(arabic)
    return result


def apply_curated_ar(entries: list[dict],
                     curated: dict[tuple[str, str], list[str]]) -> None:
    """Replace unreviewed Arabic with curated senses; retain English glosses."""
    for item in entries:
        key = (unicodedata.normalize("NFKC", item["surface"]).casefold(),
               item["pos"].casefold())
        meanings = curated.get(key)
        if meanings:
            item["translations"] = [
                {"languageCode": "ar", "text": meaning} for meaning in meanings
            ] + [
                translation for translation in item["translations"]
                if translation["languageCode"] != "ar"
            ]


def to_entry(raw: object, lang: str,
             ranking: dict[str, tuple[int, str | None]]) -> dict | None:
    if not isinstance(raw, dict):
        return None
    if raw.get("languageCode", raw.get("language_code", lang)) != lang:
        return None
    surface = text(raw.get("surface") or raw.get("word"), 160)
    pos = text(raw.get("partOfSpeech") or raw.get("pos") or
               raw.get("part_of_speech"), 64)
    if not surface or not pos:
        return None
    senses = raw.get("senses")
    gloss = ""
    if isinstance(senses, list):
        for sense in senses:
            if isinstance(sense, dict):
                glosses = sense.get("glosses", [])
                if isinstance(glosses, list):
                    gloss = next((v for v in glosses if text(v)), "")
                if gloss:
                    break
    definitions = raw.get("definitions")
    if not gloss and isinstance(definitions, list):
        for definition in definitions:
            if isinstance(definition, dict):
                gloss = text(definition.get("text")) or ""
                if gloss:
                    break
    gloss = text(gloss, 1000) or ""
    translations: list[dict] = []
    candidates = raw.get("translations", [])
    if isinstance(candidates, dict):
        candidates = [{"languageCode": k, "text": v}
                      for k, v in candidates.items()]
    if isinstance(candidates, list):
        for item in candidates:
            if not isinstance(item, dict):
                continue
            code = item.get("languageCode", item.get("language_code",
                   item.get("lang_code")))
            if code is None and item.get("lang") == "Arabic":
                code = "ar"
            if code is None and item.get("lang") == "English":
                code = "en"
            value = text(item.get("text") or item.get("word"), 1000)
            if code in ("ar", "en") and value:
                translations.append({"languageCode": code, "text": value})
    direct_ar = text(raw.get("translation_ar"))
    if direct_ar:
        translations.append({"languageCode": "ar", "text": direct_ar})
    translations = [dict(x) for x in sorted(
        {canonical(item).decode("utf-8"): item for item in translations}.values(),
        key=lambda x: (x["languageCode"], x["text"]))]
    metadata = raw.get("canonical", {})
    if not isinstance(metadata, dict):
        metadata = {}
    normalized = unicodedata.normalize("NFKC", surface).casefold()
    rankEvidence = ranking.get(normalized)
    rank = rankEvidence[0] if rankEvidence else metadata.get(
        "frequencyRank", raw.get("frequency_rank"))
    if rank is not None and (type(rank) is not int or rank < 1):
        raise ValueError(f"{lang}/{surface}: invalid frequency rank")
    level = (rankEvidence[1] if rankEvidence and rankEvidence[1]
             else metadata.get("cefr", raw.get("cefr", raw.get("cefr_level"))))
    if level is not None and level not in LEVELS:
        raise ValueError(f"{lang}/{surface}: unsupported CEFR level")
    stable = digest(canonical([lang, surface, pos, gloss]))[:24]
    return {
        "id": f"{lang}-{stable}", "surface": surface, "pos": pos.lower(),
        "gloss": gloss, "translations": translations, "rank": rank,
        "cefr": level, "sort_key": generate_sort_key(surface, lang),
    }


def select_entries(source: Path, lang: str, ranking: dict, limit: int) -> list[dict]:
    entries = {}
    for raw in read_input(source):
        item = to_entry(raw, lang, ranking)
        if item is None:
            continue
        key = (item["surface"].casefold(), item["pos"])
        prior = entries.get(key)
        if prior is None or (
            item["rank"] or 10**12, item["id"]
        ) < (prior["rank"] or 10**12, prior["id"]):
            entries[key] = item
    selected = sorted(entries.values(), key=lambda e: (
        e["rank"] if e["rank"] is not None else 10**12,
        e["sort_key"], e["id"]))[:limit]
    if not selected:
        raise ValueError(f"{source}: no valid lexical entries")
    return selected


def materialize(database: Path, language: str, entries: list[dict]) -> bytes:
    with sqlite3.connect(database) as db:
        db.execute("PRAGMA page_size=4096")
        db.execute("PRAGMA journal_mode=DELETE")
        db.execute("PRAGMA foreign_keys=ON")
        db.executescript("""
          CREATE TABLE metadata(key TEXT PRIMARY KEY, value TEXT NOT NULL);
          CREATE TABLE localization(key TEXT PRIMARY KEY, text TEXT NOT NULL,
                                    direction TEXT NOT NULL);
          CREATE TABLE lexicon(id TEXT PRIMARY KEY, surface TEXT NOT NULL,
              part_of_speech TEXT NOT NULL, direction TEXT NOT NULL,
              fields_json TEXT NOT NULL, cefr_level TEXT,
              frequency_rank INTEGER, sort_key TEXT);
          CREATE TABLE grammar(id TEXT PRIMARY KEY, title_key TEXT NOT NULL,
              tree_json TEXT NOT NULL);
          CREATE TABLE concepts(concept_id TEXT PRIMARY KEY, sense_id TEXT NOT NULL,
              lemma TEXT NOT NULL, part_of_speech TEXT NOT NULL,
              register TEXT NOT NULL, cefr TEXT NOT NULL,
              surface TEXT NOT NULL, direction TEXT NOT NULL,
              semantic_tags_json TEXT NOT NULL DEFAULT '[]',
              legacy_fields_json TEXT NOT NULL DEFAULT '{}');
          CREATE TABLE lexemes(lexeme_id TEXT PRIMARY KEY,
              concept_id TEXT NOT NULL REFERENCES concepts(concept_id),
              language_code TEXT NOT NULL, sense_id TEXT NOT NULL,
              part_of_speech TEXT NOT NULL, lemma TEXT NOT NULL,
              display_text TEXT NOT NULL, ipa TEXT, gender TEXT, article TEXT,
              plural TEXT, cefr_level TEXT, grammar_json TEXT NOT NULL);
          CREATE TABLE examples(example_id TEXT PRIMARY KEY, group_id TEXT NOT NULL,
              language_code TEXT NOT NULL, sentence TEXT NOT NULL,
              translation_ar TEXT);
          CREATE TABLE IF NOT EXISTS inflections_lookup (
              surface_form TEXT NOT NULL,
              lemma TEXT NOT NULL,
              lexicon_id INTEGER,
              language_code TEXT NOT NULL
          );
          CREATE INDEX IF NOT EXISTS idx_inflections_lookup_surface
              ON inflections_lookup(surface_form COLLATE NOCASE,
                                    language_code COLLATE NOCASE);
        """)
        fields = {
            "schemaVersion": SCHEMA_VERSION,
            "languageCode": language,
            "packId": language,
            "contentRows": str(len(entries)),
            "verbRows": "0",
            "version": VERSION,
            "contractVersion": "1.0.0",
            "textDirection": "ltr",
        }
        db.executemany("INSERT INTO metadata VALUES (?,?)", sorted(fields.items()))
        for item in entries:
            # Keep the flat legacy contract and the structured v2 contract
            # synchronized without fabricating Arabic for English-only glosses.
            arabic_translation = next(
                (entry["text"] for entry in item["translations"]
                 if entry["languageCode"] == "ar"), None)
            first_translation = (item["translations"][0]
                                 if item["translations"] else None)
            preferred_translation = (
                arabic_translation or
                (first_translation["text"] if first_translation else None) or
                (item["gloss"] or None))
            translation_language_code = (
                "ar" if arabic_translation is not None else
                (first_translation["languageCode"] if first_translation else
                 ("en" if item["gloss"] else None)))
            canonicalFields = {
                "lemma": item["surface"],
                "canonical": {"cefr": item["cefr"] or "unknown",
                              **({"frequencyRank": item["rank"]}
                                 if item["rank"] is not None else {})},
                # Kaikki/Wiktionary senses are English glosses, irrespective
                # of which source language owns this lexicon entry.
                "definitions": ([{"languageCode": "en",
                                 "text": item["gloss"]}] if item["gloss"] else []),
                "translation_ar": arabic_translation,
                "translation": preferred_translation,
                "translationLanguageCode": translation_language_code,
                "translations": item["translations"],
            }
            serialized = canonical(canonicalFields).decode("utf-8").strip()
            db.execute("INSERT INTO lexicon VALUES (?,?,?,?,?,?,?,?)", (
                item["id"], item["surface"], item["pos"], "ltr",
                serialized, item["cefr"], item["rank"], item["sort_key"]))
            db.execute("INSERT INTO concepts VALUES (?,?,?,?,?,?,?,?,?,?)", (
                item["id"], item["id"], item["surface"], item["pos"],
                "neutral", item["cefr"] or "unknown", item["surface"],
                "ltr", "[]", serialized))
            db.execute("INSERT INTO lexemes VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)", (
                item["id"], item["id"], language, item["id"], item["pos"],
                item["surface"], item["surface"], None, None, None, None,
                item["cefr"], "{}"))
        indexed = inject_schema(db)
        if indexed != len(entries):
            raise ValueError("Schema v2 indexed an unexpected number of rows")
        if db.execute("PRAGMA integrity_check").fetchone()[0] != "ok":
            raise ValueError("SQLite integrity check failed")
        if db.execute("PRAGMA foreign_key_check").fetchall():
            raise ValueError("SQLite foreign-key check failed")
        db.commit()
        db.execute("VACUUM")
    return database.read_bytes()


def pack(language: str, selected: list[dict], sqlite_bytes: bytes) -> tuple[bytes, int]:
    source = {
        "schemaVersion": 2, "pack": {
            "id": language, "languageCode": language,
            "version": VERSION, "contractVersion": "1.0.0",
            "textDirection": "ltr", "displayName": language},
        "lexicon": selected,
        "grammar": [],
    }
    metadata = {
        "schemaVersion": SCHEMA_VERSION,
        "packId": language, "languageCode": language,
        "contentRows": len(selected), "verbRows": 0,
        "version": VERSION, "contractVersion": "1.0.0",
        "textDirection": "ltr",
    }
    files = {
        "content/content.json": canonical(source),
        "content/content.sqlite": sqlite_bytes,
        "metadata/pack.json": canonical(metadata),
    }
    envelope = {
        "packId": language, "version": VERSION,
        "contractVersion": "1.0.0",
        "files": [{"path": name,
                   "contentBase64": base64.b64encode(data).decode("ascii")}
                  for name, data in sorted(files.items())],
    }
    payload = canonical(envelope)
    if len(payload) > 64 * 1024 * 1024:
        raise ValueError("Pack exceeds runtime's 64 MiB JSON envelope limit")
    compressed = gzip.compress(payload, compresslevel=9, mtime=0)
    return compressed, sum(map(len, files.values()))


def compile_pilots(input_dir: Path, rankings_dir: Path | None,
                   out_dir: Path, limit: int,
                   curated_tsv: Path | None = None) -> dict:
    if not input_dir.is_dir() or (rankings_dir and not rankings_dir.is_dir()):
        raise ValueError("Input/rankings directory is missing")
    if limit < 1 or limit > 250000:
        raise ValueError("--limit must be between 1 and 250000")
    curated = read_curated_tsv(curated_tsv) if curated_tsv else {}
    artifacts: dict[str, bytes] = {}
    descriptors: list[dict] = []
    with tempfile.TemporaryDirectory(prefix="pilot-packs-") as directory:
        for lang in LANGS:
            source = source_path(input_dir, lang)
            if source is None:
                continue
            rankingFile = rankings_dir / (lang + ".csv") if rankings_dir else None
            selected = select_entries(source, lang, ranks(rankingFile), limit)
            if lang == "de":
                apply_curated_ar(selected, curated)
            sqlite_bytes = materialize(Path(directory) / (lang + ".sqlite"),
                                       lang, selected)
            bundle, installed_size = pack(lang, selected, sqlite_bytes)
            filename = lang + ".pack.gz"
            artifacts[filename] = bundle
            descriptors.append({
                "id": lang, "languageCode": lang, "pack_file": filename,
                "bundleFormat": "json-gzip-v1",
                "schemaVersion": SCHEMA_VERSION, "version": VERSION,
                "contractVersion": "1.0.0", "contentRows": len(selected),
                "size_bytes": len(bundle), "installedSizeBytes": installed_size,
                "sha256": digest(bundle), "contentSha256": digest(sqlite_bytes),
            })
    if not descriptors:
        raise ValueError("No en/de/es/fr/tr source files found")
    manifest = {
        "schemaVersion": SCHEMA_VERSION, "format": "json-gzip-v1",
        "packs": descriptors,
    }
    artifacts["manifest.json"] = canonical(manifest)
    out_dir.mkdir(parents=True, exist_ok=True)
    # Never overwrite differing files or a golden asset. Repeat invocations
    # with identical inputs are idempotent.
    for name, data in artifacts.items():
        target = out_dir / name
        if target.exists() and target.read_bytes() != data:
            raise FileExistsError(f"Refusing to replace different artifact: {target}")
    for name, data in artifacts.items():
        target = out_dir / name
        if target.exists():
            continue
        with tempfile.NamedTemporaryFile(dir=out_dir, prefix=".pilot-",
                                         delete=False) as staging:
            temporary = Path(staging.name)
            try:
                staging.write(data)
                staging.flush()
                os.fsync(staging.fileno())
            finally:
                pass
        try:
            if target.exists():
                if target.read_bytes() != data:
                    raise FileExistsError(f"Concurrent non-identical artifact: {target}")
            else:
                os.link(temporary, target)  # fails if output appeared concurrently
        finally:
            temporary.unlink(missing_ok=True)
    return manifest


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("command", nargs="?", choices=("build",), default="build")
    parser.add_argument("--input-dir", type=Path, required=True)
    parser.add_argument("--rankings-dir", type=Path)
    parser.add_argument("--out-dir", type=Path, required=True)
    parser.add_argument("--limit", type=int, default=3000)
    parser.add_argument("--curated-tsv", type=Path,
                        help="German→Arabic TSV with surface, pos, translation_ar")
    args = parser.parse_args()
    try:
        result = compile_pilots(args.input_dir, args.rankings_dir,
                                args.out_dir, args.limit, args.curated_tsv)
    except (OSError, ValueError, sqlite3.Error) as exc:
        parser.exit(1, f"Pilot compilation failed: {exc}\n")
    for entry in result["packs"]:
        print(f"{entry['languageCode']}: {entry['contentRows']} entries "
              f"SHA-256 {entry['sha256']} ({entry['size_bytes']} bytes)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
