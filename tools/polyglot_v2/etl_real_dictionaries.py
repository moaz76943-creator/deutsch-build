#!/usr/bin/env python3
import json
import os
import shutil
import sys
import tempfile
import concurrent.futures
from pathlib import Path
from create_pack_v2 import build

SPEC_PATH = 'assets/database/master_100_languages_spec.json'
MANIFEST_PATH = 'assets/content/packs/manifest.json'
PACKS_DIR = Path('assets/content/packs')
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

        part_of_speech = entry.get('partOfSpeech', 'noun')
        if not part_of_speech: part_of_speech = 'noun'
        surface = entry.get('surface', fields.get('german'))

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

def process_language(lang, manifest_data):
    code = lang.get('code')
    if not code:
        return f"[{code}] INVALID: No language code provided"

    canonical_path = PACKS_DIR / code / "canonical" / f"{code}-1.0.0.json"

    if not canonical_path.exists():
        return f"[{code}] SOURCE_MISSING: {canonical_path}"

    pack_info = manifest_data.get('packs', {}).get(code, {})
    license_info = pack_info.get('license', '')

    if 'CC BY-SA' not in license_info:
        return f"[{code}] LICENSE_BLOCKED: Valid license not found in manifest"

    try:
        with open(canonical_path, 'r', encoding='utf-8') as f:
            v1_data = json.load(f)
    except Exception as e:
        return f"[{code}] INVALID: {canonical_path} - {e}"

    lexicon = v1_data.get('lexicon', [])
    if not lexicon:
        return f"[{code}] INVALID: No lexicon entries found"

    v2_data = convert_v1_to_v2(code, lang.get('native', code), lang.get('ar', code), v1_data)

    with tempfile.TemporaryDirectory(prefix='polyglot_factory_') as tmpdir:
        tmp_json = Path(tmpdir) / f"{code}_v2.json"
        tmp_json.write_text(json.dumps(v2_data, ensure_ascii=False), encoding='utf-8')

        out_dir = Path(tmpdir) / "out"
        try:
            db_gz_path = build(str(tmp_json), str(out_dir))
        except Exception as e:
            return f"[{code}] INVALID build: {e}"

        lang_dir = PACKS_DIR / code
        lang_dir.mkdir(parents=True, exist_ok=True)

        dest_db = lang_dir / f"{code}-1.0.0.pack.gz"
        dest_sha = lang_dir / f"{code}-1.0.0.pack.gz.sha256"

        shutil.copy2(db_gz_path, dest_db)

        sha_content = Path(str(db_gz_path) + ".sha256").read_text(encoding='ascii')
        sha_content = sha_content.replace(f"{code}.db.gz", f"{code}-1.0.0.pack.gz")
        dest_sha.write_text(sha_content, encoding='ascii')

        legacy_sqlite = PACKS_DIR / code / "sqlite" / f"{code}-1.0.0.sqlite"
        if legacy_sqlite.exists():
            legacy_sqlite.unlink()

        size = dest_db.stat().st_size
        if size > MAX_SIZE:
            return f"[{code}] INVALID: output size {size} exceeds {MAX_SIZE}"

        return f"[{code}] READY: {dest_db} ({size} bytes)"

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

    languages = spec.get('languages', [])

    max_workers = os.cpu_count() or 4
    with concurrent.futures.ProcessPoolExecutor(max_workers=max_workers) as executor:
        futures = {executor.submit(process_language, lang, manifest): lang for lang in languages}
        for future in concurrent.futures.as_completed(futures):
            try:
                result = future.result()
                print(result)
            except Exception as exc:
                print(f"[{futures[future].get('code')}] INVALID execution generated an exception: {exc}")

if __name__ == '__main__':
    process()
