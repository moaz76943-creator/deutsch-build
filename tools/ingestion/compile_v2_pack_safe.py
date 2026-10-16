#!/usr/bin/env python3
"""Rebuild the German 1,000-row SQLite asset using the repository's v2 compiler.

Run from the root of moaz76943-creator/deutsch-build:
    python3 /path/to/compile_v2_pack_safe.py

Modifies ONLY the golden SQLite asset and DatabaseService.germanGoldenSha256.
Licensing approval is intentionally NOT fabricated from an empty evidence ledger.
No GitHub Actions, APK/CI, network calls, external dependencies, or commits.
"""
from __future__ import annotations

import csv
import hashlib
import json
import os
import re
import sqlite3
import sys
import tempfile
from collections import Counter
from pathlib import Path

PROJECT_ROOT = Path.cwd()
TSV = PROJECT_ROOT / "tools/ingestion/data/de_ar_curated_master.tsv"
DB = PROJECT_ROOT / "assets/content/packs/de/sqlite/de-1.0.0.sqlite"
DART = PROJECT_ROOT / "lib/services/database_service.dart"
LEDGER = PROJECT_ROOT / "assets/data/licensing_ledger.json"
BUILDER_DIR = PROJECT_ROOT / "tools/ingestion"
EXPECTED_LEVELS = Counter({"A1": 218, "A2": 269, "B1": 298, "B2": 215})


def verify(db_path: Path) -> tuple[int, Counter]:
    with sqlite3.connect(f"file:{db_path}?mode=ro", uri=True) as conn:
        metadata = dict(conn.execute("SELECT key, value FROM metadata"))
        required_meta = {"entry_count": "1000", "contentRows": "1000"}
        for key, expected in required_meta.items():
            if metadata.get(key) != expected:
                raise RuntimeError(f"metadata[{key}]={metadata.get(key)!r}, expected {expected!r}")
        required_tables = {
            "lexicon", "metadata", "concepts", "grammar", "lexemes", "examples",
            "inflections_lookup", "lexicon_fts", "verbs", "verb_conjugations",
            "idioms", "nominals", "nominal_declensions",
        }
        tables = {row[0] for row in conn.execute("SELECT name FROM sqlite_master WHERE type='table'")}
        if missing := required_tables - tables:
            raise RuntimeError(f"Missing compatibility tables: {sorted(missing)}")
        columns = {row[1] for row in conn.execute("PRAGMA table_info(lexicon)")}
        required_columns = {"id", "surface", "pos", "part_of_speech", "sort_key", "fields_json", "cefr_level", "ipa"}
        if missing := required_columns - columns:
            raise RuntimeError(f"Missing lexicon columns: {sorted(missing)}")
        n = conn.execute("SELECT COUNT(*) FROM lexicon").fetchone()[0]
        levels = Counter(dict(conn.execute("SELECT cefr_level, COUNT(*) FROM lexicon GROUP BY cefr_level")))
        if n != 1000 or levels != EXPECTED_LEVELS:
            raise RuntimeError(f"Lexicon count/distribution mismatch: {n}, {dict(levels)}")
        for table in ("concepts", "lexemes", "inflections_lookup", "lexicon_fts"):
            found = conn.execute(f"SELECT COUNT(*) FROM {table}").fetchone()[0]
            if found != 1000:
                raise RuntimeError(f"{table} row count mismatch: {found}")
        if conn.execute("SELECT COUNT(*) FROM lexicon WHERE pos != part_of_speech OR sort_key = '' OR sort_key IS NULL").fetchone()[0]:
            raise RuntimeError("POS or sort key mismatch")
        for rowid, surface, fields in conn.execute("SELECT rowid, surface, fields_json FROM lexicon"):
            record = json.loads(fields)
            translations = record.get("translations")
            if not isinstance(translations, list) or not translations or not all(
                isinstance(x, dict) and x.get("languageCode") == "ar" and isinstance(x.get("text"), str)
                for x in translations
            ):
                raise RuntimeError(f"Malformed translations for {surface!r}")
            if record.get("translation") != record.get("translation_ar"):
                raise RuntimeError(f"Translation contract mismatch: {surface!r}")
            fts_row = conn.execute("SELECT surface, translation_ar FROM lexicon_fts WHERE rowid = ?", (rowid,)).fetchone()
            if fts_row != (surface, record["translation_ar"]):
                raise RuntimeError(f"FTS alignment mismatch at rowid={rowid}")
        # FTS5's own integrity check requires read-write access. Run it before this read-only check.
        if conn.execute("PRAGMA integrity_check").fetchone()[0] != "ok":
            raise RuntimeError("SQLite integrity_check failed")
        if conn.execute("PRAGMA foreign_key_check").fetchall():
            raise RuntimeError("SQLite foreign_key_check failed")
    return n, levels


def main() -> None:
    for path in (TSV, DART, LEDGER, BUILDER_DIR / "build_curated_sqlite.py"):
        if not path.is_file():
            raise RuntimeError(f"Missing repository file: {path}")
    with TSV.open("r", encoding="utf-8-sig", newline="") as stream:
        rows = list(csv.DictReader(stream, delimiter="\t"))
    levels = Counter(row["cefr"] for row in rows)
    if len(rows) != 1000 or levels != EXPECTED_LEVELS:
        raise RuntimeError(f"TSV validation failed: total={len(rows)}, CEFR={dict(levels)}")
    dart_before = DART.read_text(encoding="utf-8")
    pattern = re.compile(r"(static\s+const\s+String\s+germanGoldenSha256\s*=\s*['\"])[a-fA-F0-9]{64}(['\"]\s*;)")
    if len(pattern.findall(dart_before)) != 1:
        raise RuntimeError("Could not unambiguously find the existing Dart SHA constant")

    sys.path.insert(0, str(BUILDER_DIR))
    from build_curated_sqlite import build_curated_sqlite

    DB.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix="curated-rebuild-", dir=DB.parent) as scratch:
        staged_db = Path(scratch) / DB.name
        build_curated_sqlite(TSV, staged_db, expected_count=1000, replace=False)
        with sqlite3.connect(staged_db) as conn:
            conn.execute("INSERT OR REPLACE INTO metadata (key,value) VALUES ('entry_count','1000')")
            conn.execute("INSERT INTO lexicon_fts(lexicon_fts) VALUES ('integrity-check')")
            conn.commit()
            conn.execute("VACUUM")
            conn.commit()
        n, compiled_levels = verify(staged_db)
        sha = hashlib.sha256(staged_db.read_bytes()).hexdigest()
        new_dart = pattern.sub(lambda m: m.group(1) + sha + m.group(2), dart_before)
        if new_dart == dart_before and (not DB.exists() or hashlib.sha256(DB.read_bytes()).hexdigest() != sha):
            raise RuntimeError("Dart SHA unchanged despite different database")
        # Only swap into the real repository after ALL content checks pass.
        os.replace(staged_db, DB)
        if new_dart != dart_before:
            fd, staged_dart_path = tempfile.mkstemp(prefix=".dart-sha-", dir=DART.parent)
            try:
                with os.fdopen(fd, "w", encoding="utf-8") as handle:
                    handle.write(new_dart)
                os.replace(staged_dart_path, DART)
            finally:
                if os.path.exists(staged_dart_path):
                    os.unlink(staged_dart_path)

    # Existing ledger has no per-dataset provenance evidence; do not falsely claim approved rights.
    ledger = json.loads(LEDGER.read_text(encoding="utf-8"))
    print(f"lexicon={n}, inflections_lookup=1000, lexicon_fts=1000")
    print(f"CEFR={dict(sorted(compiled_levels.items()))}")
    print(f"SHA-256={sha}")
    print(f"releaseStatus={ledger.get('releaseStatus')} distributionGate={ledger.get('distributionGate')}")
    if not ledger.get("datasets"):
        print("LICENSING BLOCKED: dataset evidence missing. No approval status was fabricated.")


if __name__ == "__main__":
    main()
