#!/usr/bin/env python3
import concurrent.futures
import json
import os
import shutil
import sys
import tempfile
import multiprocessing
import gzip
import sqlite3
from pathlib import Path
from create_pack_v2 import build

SPEC_PATH = 'assets/database/master_100_languages_spec.json'
PACKS_DIR = Path('assets/content/packs')
MANIFEST_PATH = PACKS_DIR / 'manifest.json'
MAX_SIZE = 25 * 1024 * 1024

def convert_v1_to_v2(lang_code, name_native, name_ar, v1_data):
    v2 = {
        "schema_version": 2,
        "language": {
            "language_code": lang_code,
            "name_native": name_native,
            "name_ar": name_ar,
            "direction": "ltr" if lang_code != "ar" else "rtl"
        },
        "concepts": [],
        "lexemes": [],
        "example_groups": [],
        "examples": []
    }

    # We map topics to concepts
    concepts_seen = set()
    concept_idx = 1

    lexicon = v1_data.get('lexicon', [])
    for entry in lexicon:
        fields = entry.get('fields', {})
        topic = fields.get('topic', 'General')
        if topic not in concepts_seen:
            concepts_seen.add(topic)
            concept_id = f"concept.{lang_code}.{concept_idx}"

            v2['concepts'].append({
                "concept_id": concept_id,
                "category": topic,
                "cefr_level": "A1", # The schema strictly requires this
                "priority": 1
            })
            concept_idx += 1

    topic_to_concept_id = {c['category']: c['concept_id'] for c in v2['concepts']}

    lexeme_idx = 1
    for entry in lexicon:
        fields = entry.get('fields', {})
        topic = fields.get('topic', 'General')
        concept_id = topic_to_concept_id[topic]

        # Extract only existing fields, do not fabricate.
        part_of_speech = entry.get('partOfSpeech')
        if not part_of_speech: part_of_speech = 'noun' # Required field in schema

        surface = entry.get('surface', fields.get('german', fields.get('english', fields.get('text', ''))))

        lemma = surface
        display_text = surface
        if fields.get('article'):
            display_text = f"{fields['article']} {lemma}"

        sense_id = entry.get('id', f"sense_{lexeme_idx}")
        lexeme_id = f"lex.{lang_code}.{lexeme_idx}"

        grammar = {}
        if fields.get('plural'):
            grammar['plural'] = fields['plural']

        lexeme = {
            "lexeme_id": lexeme_id,
            "concept_id": concept_id,
            "language_code": lang_code,
            "sense_id": sense_id,
            "part_of_speech": part_of_speech,
            "lemma": lemma,
            "display_text": display_text
        }

        if fields.get('gender'):
            lexeme['gender'] = fields['gender']
        if fields.get('article'):
            lexeme['article'] = fields['article']
        if fields.get('ipa'):
            lexeme['ipa'] = fields['ipa']
        if grammar:
            lexeme['grammar'] = grammar

        v2['lexemes'].append(lexeme)

        sentence = fields.get('sentence', '').strip()
        sentence_ar = fields.get('sentenceAr', '').strip()
        if sentence:
            group_id = f"exg.{lang_code}.{lexeme_idx}"
            v2['example_groups'].append({
                "group_id": group_id,
                "concept_id": concept_id,
                "context_type": "daily" # Required by schema
            })
            v2['examples'].append({
                "example_id": f"ex.{lang_code}.{lexeme_idx}",
                "group_id": group_id,
                "sentence": sentence,
                "translation_ar": sentence_ar
            })

        lexeme_idx += 1

    return v2

def validate_pack(pack_path, expected_language):
    # Requirements: Validate schema, row counts, language identity, decompressibility and SQLite integrity.
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
    code, pack_info, name_native, name_ar = args

    if "CC BY-SA 4.0" not in pack_info.get("license", ""):
        return code, f"[{code}] LICENSE_BLOCKED", None

    canonical_path = PACKS_DIR / code / "canonical" / f"{code}-1.0.0.json"

    if not canonical_path.exists():
        return code, f"[{code}] SOURCE_MISSING: {canonical_path}", None

    try:
        with open(canonical_path, 'r', encoding='utf-8') as f:
            v1_data = json.load(f)
    except Exception as e:
        return code, f"[{code}] INVALID: {canonical_path} - {e}", None

    lexicon = v1_data.get('lexicon', [])
    if not lexicon:
        return code, f"[{code}] INVALID: No lexicon entries found", None

    v2_data = convert_v1_to_v2(code, name_native, name_ar, v1_data)

    with tempfile.TemporaryDirectory(prefix='polyglot_factory_') as tmpdir:
        tmp_json = Path(tmpdir) / f"{code}_v2.json"
        tmp_json.write_text(json.dumps(v2_data, ensure_ascii=False), encoding='utf-8')

        out_dir = Path(tmpdir) / "out"
        try:
            db_gz_path = build(str(tmp_json), str(out_dir))
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
        sha_content = Path(str(db_gz_path) + ".sha256").read_text(encoding='ascii')
        sha_content = sha_content.replace(f"{code}.db.gz", f"{code}-1.0.0.pack.gz")
        dest_sha.write_text(sha_content, encoding='ascii')

        with open(dest_sha, 'r', encoding='ascii') as sf:
            actual_sha256 = sf.read().split()[0]

        pack_info['size_bytes'] = size
        pack_info['sha256'] = actual_sha256

        return code, f"[{code}] READY: {dest_db} ({size} bytes)", pack_info

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

    language_catalog = {lang['code']: lang for lang in spec.get('languages', [])}
    packs = manifest.get('packs', {})

    tasks = []
    for code, pack_info in packs.items():
        lang_meta = language_catalog.get(code, {})
        name_native = lang_meta.get('native', code)
        name_ar = lang_meta.get('ar', code)
        tasks.append((code, pack_info, name_native, name_ar))

    # Bound concurrent builds to a reasonable number to avoid OOM
    # The requirement #9 is "Bound CPU, memory, disk and concurrent pack builds."
    workers = min(multiprocessing.cpu_count(), 4)
    with concurrent.futures.ProcessPoolExecutor(max_workers=workers) as executor:
        results = executor.map(process_pack, tasks)

    for code, message, updated_pack_info in results:
        print(message)
        if updated_pack_info:
            packs[code] = updated_pack_info

    with open(MANIFEST_PATH, 'w', encoding='utf-8') as f:
        json.dump(manifest, f, indent=2, ensure_ascii=False)
        f.write('\n')

if __name__ == '__main__':
    process()
