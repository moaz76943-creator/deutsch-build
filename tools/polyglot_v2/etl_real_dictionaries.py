#!/usr/bin/env python3
import concurrent.futures
import json
import os
import shutil
import sys
import tempfile
from pathlib import Path
from create_pack_v2 import build

SPEC_PATH = 'assets/database/master_100_languages_spec.json'
PACKS_DIR = Path('assets/content/packs')
MAX_SIZE = 25 * 1024 * 1024
MANIFEST_PATH = PACKS_DIR / 'manifest.json'

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
    
    # We will just map topics to concepts
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
                "cefr_level": "A1",
                "priority": 1
            })
            concept_idx += 1
            
    topic_to_concept_id = {c['category']: c['concept_id'] for c in v2['concepts']}

    lexeme_idx = 1
    for entry in lexicon:
        fields = entry.get('fields', {})
        topic = fields.get('topic', 'General')
        concept_id = topic_to_concept_id[topic]

        # Ensure we have required fields without fabricating
        part_of_speech = entry.get('partOfSpeech')
        if not part_of_speech:
            raise ValueError(f"Missing partOfSpeech in entry {entry.get('id')}")

        surface = entry.get('surface')
        if not surface:
            raise ValueError(f"Missing surface in entry {entry.get('id')}")

        lemma = surface
        display_text = surface
        if fields.get('article'):
            display_text = f"{fields['article']} {lemma}"

        sense_id = entry.get('id', f"sense_{lexeme_idx}")
        lexeme_id = f"lex.{lang_code}.{lexeme_idx}"

        grammar = {}
        if fields.get('plural'):
            grammar['plural'] = fields['plural']
            
        v2['lexemes'].append({
            "lexeme_id": lexeme_id,
            "concept_id": concept_id,
            "language_code": lang_code,
            "sense_id": sense_id,
            "part_of_speech": part_of_speech,
            "lemma": lemma,
            "display_text": display_text,
            "ipa": "",
            "gender": "n",
            "article": fields.get('article', ''),
            "plural": fields.get('plural', ''),
            "cefr_level": "A1",
            "grammar": grammar
        })

        sentence = fields.get('sentence', '').strip()
        sentence_ar = fields.get('sentenceAr', '').strip()
        if sentence:
            group_id = f"exg.{lang_code}.{lexeme_idx}"
            v2['example_groups'].append({
                "group_id": group_id,
                "concept_id": concept_id,
                "context_type": "daily"
            })
            v2['examples'].append({
                "example_id": f"ex.{lang_code}.{lexeme_idx}",
                "group_id": group_id,
                "sentence": sentence,
                "translation_ar": sentence_ar
            })
            
        lexeme_idx += 1

    return v2

def process_language(lang, packs_manifest):
    code = lang.get('code')
    if not code:
        return

    canonical_path = PACKS_DIR / code / "canonical" / f"{code}-1.0.0.json"

    if not canonical_path.exists():
        print(f"[{code}] SOURCE_MISSING: {canonical_path}")
        return

    pack_info = packs_manifest.get(code)
    if not pack_info or pack_info.get('license') != 'CC BY-SA 4.0':
        print(f"[{code}] LICENSE_BLOCKED: {canonical_path}")
        return

    try:
        with open(canonical_path, 'r', encoding='utf-8') as f:
            v1_data = json.load(f)
    except Exception as e:
        print(f"[{code}] INVALID: {canonical_path} - {e}")
        return

    lexicon = v1_data.get('lexicon', [])
    if not lexicon:
        print(f"[{code}] INVALID: No lexicon entries found")
        return

    print(f"[{code}] Processing {len(lexicon)} entries...")
    try:
        v2_data = convert_v1_to_v2(code, lang.get('native', code), lang.get('ar', code), v1_data)
    except Exception as e:
        print(f"[{code}] INVALID data conversion: {e}")
        return

    with tempfile.TemporaryDirectory(prefix='polyglot_factory_') as tmpdir:
        tmp_json = Path(tmpdir) / f"{code}_v2.json"
        tmp_json.write_text(json.dumps(v2_data, ensure_ascii=False), encoding='utf-8')

        out_dir = Path(tmpdir) / "out"
        try:
            db_gz_path = build(str(tmp_json), str(out_dir))
        except Exception as e:
            print(f"[{code}] INVALID build: {e}")
            return

        size = db_gz_path.stat().st_size
        if size > MAX_SIZE:
            print(f"[{code}] INVALID: output size {size} exceeds {MAX_SIZE}")
            return

        bundle_dir = PACKS_DIR / code / "bundles"
        bundle_dir.mkdir(parents=True, exist_ok=True)

        dest_db = bundle_dir / f"{code}-1.0.0.pack.gz"
        dest_sha = bundle_dir / f"{code}-1.0.0.pack.gz.sha256"

        shutil.copy2(db_gz_path, dest_db)
        shutil.copy2(str(db_gz_path) + ".sha256", dest_sha)

        # Remove legacy sqlite schema files created by previous bad runs
        legacy_sqlite = PACKS_DIR / code / "sqlite" / f"{code}-1.0.0.sqlite"
        if legacy_sqlite.exists():
            legacy_sqlite.unlink()

        print(f"[{code}] READY: {dest_db} ({size} bytes)")

def process():
    if not os.path.exists(SPEC_PATH):
        print(f"Error: {SPEC_PATH} not found.")
        sys.exit(1)

    with open(SPEC_PATH, 'r', encoding='utf-8') as f:
        spec = json.load(f)

    packs_manifest = {}
    if MANIFEST_PATH.exists():
        try:
            with open(MANIFEST_PATH, 'r', encoding='utf-8') as f:
                manifest_data = json.load(f)
                packs_manifest = manifest_data.get('packs', {})
        except Exception as e:
            print(f"Error reading manifest: {e}")

    languages = spec.get('languages', [])
    max_workers = min(4, (os.cpu_count() or 1))
    with concurrent.futures.ProcessPoolExecutor(max_workers=max_workers) as executor:
        futures = [executor.submit(process_language, lang, packs_manifest) for lang in languages]
        for future in concurrent.futures.as_completed(futures):
            future.result() # re-raise exceptions if any

if __name__ == '__main__':
    process()
