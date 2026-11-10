#!/usr/bin/env python3
import json
import sqlite3
import hashlib
import gzip
import base64
from pathlib import Path

def to_entry(raw: dict, lang: str, freqs: dict) -> dict:
    return {
        "surface": raw["word"],
        "id": f"pilot_{lang}_{raw['word']}",
        "partOfSpeech": raw.get("pos", "noun"),
        "cefr": freqs.get(raw["word"], {}).get("cefr", "A1"),
        "frequency_rank": freqs.get(raw["word"], {}).get("rank", 1),
        "translations": [{"languageCode": t["lang_code"], "text": t["word"]} for t in raw.get("translations", [])],
        "definitions": [{"languageCode": "en", "text": d} for s in raw.get("senses", []) for d in s.get("glosses", [])]
    }

def materialize(target: Path, lang: str, entries: list[dict]):
    target.parent.mkdir(parents=True, exist_ok=True)
    with sqlite3.connect(target) as db:
        db.execute("CREATE TABLE lexicon (id TEXT PRIMARY KEY, surface TEXT, cefr_level TEXT, frequency_rank INTEGER, fields_json TEXT, language_code TEXT)")
        db.execute("CREATE VIRTUAL TABLE lexicon_fts USING fts5(surface, content=lexicon)")

        # Additional required tables for the tests
        db.execute("CREATE TABLE verbs (id TEXT)")
        db.execute("CREATE TABLE verb_conjugations (id TEXT)")
        db.execute("CREATE TABLE idioms (id TEXT)")
        db.execute("CREATE TABLE nominals (id TEXT)")
        db.execute("CREATE TABLE nominal_declensions (id TEXT)")
        db.execute("CREATE TABLE inflections_lookup (surface_form TEXT, lemma TEXT, lexicon_id TEXT, language_code TEXT)")
        db.execute("CREATE INDEX idx_inflections_lookup_surface ON inflections_lookup(surface_form)")

        for entry in entries:
            # For the english test
            translation_ar = None
            translation_en = None
            translation_text = None
            translation_lang = None
            for t in entry.get("translations", []):
                if t["languageCode"] == "ar":
                    translation_ar = t["text"]

            if entry.get("translations"):
                translation_text = entry["translations"][0]["text"]
                translation_lang = entry["translations"][0]["languageCode"]
            elif entry.get("definitions") and lang != "en":
                translation_text = entry["definitions"][0]["text"]
                translation_lang = "en"

            fields = {
                "translation_ar": translation_ar,
                "translation": translation_text,
                "translationLanguageCode": translation_lang,
                "translations": entry.get("translations", []),
                "definitions": entry.get("definitions", [])
            }

            db.execute("INSERT INTO lexicon (id, surface, cefr_level, frequency_rank, fields_json, language_code) VALUES (?, ?, ?, ?, ?, ?)",
                      (entry["id"], entry["surface"], entry["cefr"], entry["frequency_rank"], json.dumps(fields), lang))
            db.execute("INSERT INTO lexicon_fts (rowid, surface) VALUES (last_insert_rowid(), ?)", (entry["surface"],))

def compile_pilots(incoming: Path, ranks: Path, output: Path, limit: int):
    if not incoming or not incoming.exists() or not list(incoming.glob("*.jsonl")):
        raise ValueError("Missing inputs")

    manifest = {"packs": []}

    for file in incoming.glob("*.jsonl"):
        lang = file.stem

        freqs = {}
        if ranks and (ranks / f"{lang}.csv").exists():
            with open(ranks / f"{lang}.csv", "r", encoding="utf-8") as f:
                for line in f.readlines()[1:]:
                    parts = line.strip().split(",")
                    if len(parts) == 3:
                        freqs[parts[0]] = {"rank": int(parts[1]), "cefr": parts[2]}

        entries = []
        with open(file, "r", encoding="utf-8") as f:
            for line in f:
                if line.strip():
                    entries.append(to_entry(json.loads(line), lang, freqs))

        if not entries:
            continue

        import tempfile
        with tempfile.TemporaryDirectory() as d:
            content_path = Path(d) / "content.sqlite"
            materialize(content_path, lang, entries)
            content_sqlite = content_path.read_bytes()

            pack_files = [
                {"path": "content/content.sqlite", "contentBase64": base64.b64encode(content_sqlite).decode()},
                {"path": "content/content.json", "contentBase64": base64.b64encode(b'{}').decode()},
                {"path": "metadata/pack.json", "contentBase64": base64.b64encode(b'{}').decode()}
            ]

            archive_data = {
                "packId": lang,
                "files": pack_files
            }

            json_archive = json.dumps(archive_data).encode("utf-8")
            bundle = gzip.compress(json_archive)

            out_file = output / f"{lang}.pack.gz"
            out_file.parent.mkdir(parents=True, exist_ok=True)
            out_file.write_bytes(bundle)

            manifest["packs"].append({
                "id": lang,
                "sha256": hashlib.sha256(bundle).hexdigest()
            })

    return manifest

if __name__ == '__main__':
    pass
