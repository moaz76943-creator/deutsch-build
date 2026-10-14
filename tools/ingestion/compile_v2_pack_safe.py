#!/usr/bin/env python3
"""Compile an editor-reviewed, single-language V2 source into a deterministic SQLite gzip pack.
No network, translation, artificial data generation, signing or user-state modification.
Development compiler only: production admission is specified separately.
"""
import argparse
import gzip
import hashlib
import json
from pathlib import Path
import re
import sqlite3
import sys
import tempfile

from build_fts5_virtual_tables import build_fts5_tables

BASE = Path(__file__).resolve().parent
SCHEMA = BASE / 'schema_v2.sql'
TAG = re.compile(r'^[a-z]{2,3}(?:-[a-z0-9]{2,8})*$')
LEVELS = {'A1', 'A2', 'B1', 'B2', 'C1', 'C2'}
ID_RE = re.compile(r"^[A-Za-z0-9][A-Za-z0-9._:-]{0,127}$")

def tag(value):
    if not isinstance(value, str):
        raise ValueError('language_code_not_text')
    value = value.replace('_', '-').lower().strip()
    if not TAG.fullmatch(value):
        raise ValueError('invalid_language_code')
    if value.split('-')[0] in {'he', 'iw'}:
        raise ValueError('language_excluded_by_project_policy')
    return value

def req(item, field):
    value = item.get(field)
    if not isinstance(value, str) or not value.strip():
        raise ValueError('invalid_or_empty_' + field)
    return value.strip()

def req_id(item, field):
    value = req(item, field)
    if not ID_RE.match(value):
        raise ValueError('invalid_id_format_' + field)
    return value

def obj(value):
    if not isinstance(value, dict):
        raise ValueError('expected_object')
    return value

def arr(document, field):
    value = document.get(field)
    if not isinstance(value, list) or len(value) == 0:
        if not isinstance(value, list):
            raise ValueError('expected_list_' + field)
        raise ValueError('empty_list_' + field)
    return value

def load_source(source):
    try:
        raw_bytes = Path(source).read_bytes()
        document_text = raw_bytes.decode('utf-8', errors='strict')
    except UnicodeDecodeError:
        raise ValueError('invalid_utf8_encoding')

    document = obj(json.loads(document_text))
    if document.get('schema_version') != 2:
        raise ValueError('schema_version_must_be_2')
    language = obj(document.get('language'))
    code = tag(req(language, 'language_code'))
    direction = req(language, 'direction')
    if direction not in {'ltr', 'rtl'}:
        raise ValueError('invalid_direction')
    for field in ('name_native', 'name_ar'):
        req(language, field)
    for field in ('concepts', 'lexemes', 'example_groups', 'examples'):
        arr(document, field)
    return document, code

def build(source, output):
    document, language_code = load_source(source)
    output = Path(output)
    output.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix='polyglot_v2_') as directory:
        database_path = Path(directory) / 'content.sqlite'
        db = sqlite3.connect(database_path)
        try:
            db.executescript(SCHEMA.read_text(encoding='utf-8'))
            db.execute('PRAGMA foreign_keys=ON')

            with db: # wrap all in one transaction
                language = document['language']
                db.execute('INSERT INTO language_profiles VALUES (?,?,?,?,1)', (
                    language_code, req(language,'name_native'), req(language,'name_ar'),
                    req(language,'direction')))
                for item in sorted(arr(document,'concepts'), key=lambda x:x['concept_id']):
                    obj(item)
                    level = req(item, 'cefr_level')
                    if level not in LEVELS:
                        raise ValueError('invalid_concept_cefr_level')
                    db.execute('INSERT INTO concepts VALUES (?,?,?,?)', (
                        req_id(item,'concept_id'), req(item,'category'), level,
                        int(item.get('priority',1))))
                for item in sorted(arr(document,'lexemes'), key=lambda x:x['lexeme_id']):
                    obj(item)
                    code = tag(req(item,'language_code'))
                    if code != language_code:
                        raise ValueError('cross_language_entry_not_allowed')
                    grammar = item.get('grammar',{})
                    if not isinstance(grammar,dict):
                        raise ValueError('grammar_must_be_object')
                    level = item.get('cefr_level')
                    if level is not None and level not in LEVELS:
                        raise ValueError('invalid_lexeme_cefr_level')

                    # Store everything inside fields_json (generic grammar forms)
                    if 'gender' in item: grammar['gender'] = item['gender']
                    if 'article' in item: grammar['article'] = item['article']
                    if 'plural' in item: grammar['plural'] = item['plural']

                    fields_json = json.dumps(grammar,ensure_ascii=False,sort_keys=True,separators=(',',':'))

                    db.execute('INSERT INTO lexemes VALUES (?,?,?,?,?,?,?,?,?,?)',(
                        req_id(item,'lexeme_id'),req_id(item,'concept_id'),code,
                        req_id(item,'sense_id'),
                        req(item,'display_text'), # mapping display_text to surface
                        req(item,'lemma'), # mapping lemma to sort_key
                        req(item,'part_of_speech'),
                        item.get('ipa'),
                        level,
                        fields_json))
                for item in sorted(arr(document,'example_groups'),key=lambda x:x['group_id']):
                    obj(item)
                    db.execute('INSERT INTO example_groups VALUES (?,?,?)',(
                        req_id(item,'group_id'),req_id(item,'concept_id'),item.get('context_type','daily')))
                for item in sorted(arr(document,'examples'),key=lambda x:x['example_id']):
                    obj(item)
                    trans_ar = item.get('translation_ar')
                    if not isinstance(trans_ar, str) or not trans_ar.strip():
                        raise ValueError('invalid_or_empty_translation_ar')
                    db.execute('INSERT INTO examples VALUES (?,?,?,?,?)',(
                        req_id(item,'example_id'),req_id(item,'group_id'),language_code,
                        req(item,'sentence'),trans_ar.strip()))

                build_fts5_tables(db)

            if db.execute('PRAGMA integrity_check').fetchone()[0] != 'ok':
                raise ValueError('sqlite_integrity_failed')
            if db.execute('PRAGMA foreign_key_check').fetchall():
                raise ValueError('sqlite_foreign_keys_failed')
            if db.execute('SELECT count(*) FROM lexemes').fetchone()[0] < 1:
                raise ValueError('empty_lexicon')

            # Additional FTS5 check
            fts_count = db.execute("SELECT count(*) FROM lexemes_fts").fetchone()[0]
            lex_count = db.execute("SELECT count(*) FROM lexemes").fetchone()[0]
            if fts_count != lex_count:
                raise ValueError("fts5_count_mismatch")

        finally:
            db.close()
        raw = database_path.read_bytes()
    path = output / (language_code + '.db.gz')
    with path.open('wb') as file:
        with gzip.GzipFile(filename='',mode='wb',fileobj=file,compresslevel=9,mtime=0) as compressed:
            compressed.write(raw)
    digest = hashlib.sha256(path.read_bytes()).hexdigest()
    (output / (language_code + '.db.gz.sha256')).write_text(
        digest + '  ' + language_code + '.db.gz\n', encoding='ascii')
    print('BUILT',path,'raw_bytes',len(raw),'sha256',digest,'total_rows',lex_count)
    return path

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--source',required=True)
    parser.add_argument('--output',required=True)
    options = parser.parse_args()
    try:
        build(options.source,options.output)
    except (ValueError,sqlite3.Error,KeyError,TypeError) as error:
        print('REJECTED',error,file=sys.stderr)
        raise SystemExit(2)
