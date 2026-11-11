#!/usr/bin/env python3
import json
import os
import shutil
import sys
import tempfile
import hashlib
import gzip
import sqlite3
import multiprocessing
from concurrent.futures import ProcessPoolExecutor
from pathlib import Path
from create_pack_v2 import build

MANIFEST_PATH = 'assets/content/packs/manifest.json'
SPEC_PATH = 'assets/database/master_100_languages_spec.json'
PACKS_DIR = Path('assets/content/packs')
MAX_SIZE = 25 * 1024 * 1024

def validate_pack(pack_path, expected_language):
    with gzip.open(pack_path, 'rb') as f:
        raw_db = f.read()

    with tempfile.NamedTemporaryFile(suffix='.sqlite', delete=False) as tmpdb:
        tmpdb.write(raw_db)
        tmpdb.flush()
        db_path = tmpdb.name

    try:
        conn = sqlite3.connect(db_path)

        # Integrity
        cursor = conn.execute("PRAGMA integrity_check;")
        if cursor.fetchone()[0] != 'ok':
            raise ValueError("SQLite integrity check failed")

        cursor = conn.execute("PRAGMA foreign_key_check;")
        if cursor.fetchall():
            raise ValueError("SQLite foreign key check failed")

        # Language Identity
        cursor = conn.execute("SELECT language_code FROM language_profiles LIMIT 1;")
        res = cursor.fetchone()
        if not res or res[0] != expected_language:
            raise ValueError("Language identity mismatch")

        # Row counts
        cursor = conn.execute("SELECT COUNT(*) FROM lexemes;")
        if cursor.fetchone()[0] == 0:
            raise ValueError("Empty pack (0 lexemes)")

    finally:
        conn.close()
        os.unlink(db_path)


def process_pack(args):
    code, pack_info = args

    if "CC BY-SA 4.0" not in pack_info.get("license", ""):
        return code, f"[{code}] LICENSE_BLOCKED", None

    canonical_path = PACKS_DIR / code / "canonical" / f"{code}-1.0.0.json"

    if not canonical_path.exists():
        return code, f"[{code}] SOURCE_MISSING: {canonical_path}", None

    # Load source to check schema version without converting and fabricating data
    try:
        with open(canonical_path, 'r', encoding='utf-8') as f:
            source_data = json.load(f)
            if source_data.get('schema_version') != 2:
                # Instead of throwing exception and losing the pack info, we just skip it
                # returning None to preserve the existing manifest entry, while reporting INVALID
                return code, f"[{code}] INVALID: schema_version_must_be_2", None
    except Exception as e:
        return code, f"[{code}] INVALID: {e}", None

    with tempfile.TemporaryDirectory(prefix='polyglot_factory_') as tmpdir:
        out_dir = Path(tmpdir) / "out"
        try:
            db_gz_path = build(str(canonical_path), str(out_dir))
        except Exception as e:
            return code, f"[{code}] INVALID build: {e}", None

        size = db_gz_path.stat().st_size
        if size > MAX_SIZE:
            return code, f"[{code}] INVALID: output size {size} exceeds {MAX_SIZE}", None

        # Validate
        try:
            validate_pack(db_gz_path, code)
        except Exception as e:
            return code, f"[{code}] INVALID validation: {e}", None

        dest_db = PACKS_DIR / code / f"{code}-1.0.0.pack.gz"
        dest_sha = PACKS_DIR / code / f"{code}-1.0.0.pack.gz.sha256"

        shutil.copy2(db_gz_path, dest_db)

        # Fix sha256 content
        actual_sha256 = hashlib.sha256(dest_db.read_bytes()).hexdigest()
        sha_content = f"{actual_sha256}  {code}-1.0.0.pack.gz\n"
        dest_sha.write_text(sha_content, encoding='ascii')

        # Remove legacy sqlite schema files created by previous bad runs
        legacy_sqlite = PACKS_DIR / code / "sqlite" / f"{code}-1.0.0.sqlite"
        if legacy_sqlite.exists():
            legacy_sqlite.unlink()

        new_pack_info = pack_info.copy()
        new_pack_info['size_bytes'] = size
        new_pack_info['sha256'] = actual_sha256

        return code, f"[{code}] READY: {dest_db} ({size} bytes)", new_pack_info


def process():
    if not os.path.exists(SPEC_PATH):
        print(f"Error: {SPEC_PATH} not found.")
        sys.exit(1)

    if not os.path.exists(MANIFEST_PATH):
        print(f"Error: {MANIFEST_PATH} not found.")
        sys.exit(1)

    with open(SPEC_PATH, 'r', encoding='utf-8') as f:
        spec = json.load(f)

    with open(MANIFEST_PATH, 'r', encoding='utf-8') as f:
        manifest = json.load(f)

    packs = manifest.get('packs', {})

    tasks = []
    # Loop over all languages from the catalog spec
    for lang in spec.get('languages', []):
        code = lang['code']
        pack_info = packs.get(code, {})
        tasks.append((code, pack_info))

    workers = min(multiprocessing.cpu_count(), 4)
    with ProcessPoolExecutor(max_workers=workers) as executor:
        results = executor.map(process_pack, tasks)

    for code, message, updated_pack_info in results:
        print(message)
        if updated_pack_info:
            packs[code] = updated_pack_info

    manifest['packs'] = packs

    with open(MANIFEST_PATH, 'w', encoding='utf-8') as f:
        json.dump(manifest, f, indent=2, ensure_ascii=False)
        f.write('\n')

if __name__ == '__main__':
    process()
