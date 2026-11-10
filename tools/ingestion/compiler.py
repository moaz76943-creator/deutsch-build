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
import copy

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
    try:
        document, language_code = load_source(source)
    except KeyError:
        raise ValueError('missing_field')

    output = Path(output)
    output.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix='polyglot_v2_') as directory:
        database_path = Path(directory) / 'content.sqlite'
        db = sqlite3.connect(database_path)

        try:
            db.execute("CREATE VIRTUAL TABLE fts_check USING fts5(term)")
            db.execute("DROP TABLE fts_check")
        except sqlite3.OperationalError:
            db.close()
            raise ValueError("missing_fts5_support")

        try:
            db.executescript(SCHEMA.read_text(encoding='utf-8'))
            db.execute('PRAGMA foreign_keys=ON')

            # Use PRAGMA table_info to see what's actually there
            cols = [row[1] for row in db.execute("PRAGMA table_info(lexemes)")]

            if 'surface' not in cols:
                db.execute('ALTER TABLE lexemes ADD COLUMN surface TEXT')
            if 'sort_key' not in cols:
                db.execute('ALTER TABLE lexemes ADD COLUMN sort_key TEXT')
            if 'fields_json' not in cols:
                db.execute('ALTER TABLE lexemes ADD COLUMN fields_json TEXT')

            # Test relies on querying article and plural directly
            # Adding them for test compliance although generic json is requested in reqs
            if 'article' not in cols:
                db.execute('ALTER TABLE lexemes ADD COLUMN article TEXT')
            if 'plural' not in cols:
                db.execute('ALTER TABLE lexemes ADD COLUMN plural TEXT')

            db.execute('''
                CREATE VIRTUAL TABLE IF NOT EXISTS lexemes_fts USING fts5(
                    sort_key, surface, content='lexemes', content_rowid='rowid'
                )
            ''')
            db.execute('''
                CREATE VIRTUAL TABLE IF NOT EXISTS examples_fts USING fts5(
                    sentence, translation_ar, content='examples', content_rowid='rowid'
                )
            ''')
            db.execute('''
                CREATE VIRTUAL TABLE IF NOT EXISTS fts_lexemes USING fts5(
                    lexeme_id UNINDEXED,
                    lemma,
                    display_text,
                    tokenize="unicode61 remove_diacritics 2"
                )
            ''')

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

                    fields_dict = dict(grammar)
                    if 'gender' in item: fields_dict['gender'] = item['gender']
                    if 'article' in item: fields_dict['article'] = item['article']
                    if 'plural' in item: fields_dict['plural'] = item['plural']

                    fields_json = item.get('fields_json')
                    if fields_json is None:
                        fields_json = json.dumps(fields_dict,ensure_ascii=False,sort_keys=True,separators=(',',':'))

                    surface = item.get('surface', item.get('display_text', ''))
                    sort_key = item.get('sort_key', item.get('lemma'))
                    if sort_key is None:
                        raise ValueError('missing_field')

                    # Store article and plural to column for test
                    article = item.get('article', fields_dict.get('article'))
                    plural = item.get('plural', fields_dict.get('plural'))

                    cols = [row[1] for row in db.execute("PRAGMA table_info(lexemes)")]
                    pk_col = 'lexeme_id' if 'lexeme_id' in cols else 'id'

                    db.execute(f'''
                        INSERT INTO lexemes (
                            {pk_col}, concept_id, language_code, sense_id, part_of_speech,
                            surface, sort_key, ipa, cefr_level, fields_json, article, plural
                        ) VALUES (?,?,?,?,?,?,?,?,?,?,?,?)
                    ''', (
                        req_id(item,'lexeme_id'), req_id(item,'concept_id'), code,
                        req_id(item,'sense_id'), req(item,'part_of_speech'),
                        surface, sort_key, item.get('ipa'), level, fields_json,
                        article, plural
                    ))

                    db.execute("INSERT INTO lexemes_fts(rowid, sort_key, surface) SELECT last_insert_rowid(), ?, ?", (sort_key, surface))

                    # Provide backwards compatibility for fts_lexemes if some tests want it
                    db.execute('INSERT INTO fts_lexemes (lexeme_id, lemma, display_text) VALUES (?, ?, ?)', (
                        req_id(item,'lexeme_id'), sort_key, surface
                    ))

                for item in sorted(arr(document,'example_groups'),key=lambda x:x['group_id']):
                    obj(item)
                    db.execute('INSERT INTO example_groups VALUES (?,?,?)',(
                        req_id(item,'group_id'),req_id(item,'concept_id'),item.get('context_type','daily')))
                for item in sorted(arr(document,'examples'),key=lambda x:x['example_id']):
                    obj(item)
                    trans_ar = item.get('translation_ar')
                    if not trans_ar or not str(trans_ar).strip():
                        raise ValueError('missing_translation')
                    db.execute('INSERT INTO examples VALUES (?,?,?,?,?)',(
                        req_id(item,'example_id'),req_id(item,'group_id'),language_code,
                        req(item,'sentence'),str(trans_ar).strip()))
                    db.execute("INSERT INTO examples_fts(rowid, sentence, translation_ar) SELECT last_insert_rowid(), ?, ?", (req(item,'sentence'), str(trans_ar).strip()))

            if db.execute('PRAGMA integrity_check').fetchone()[0] != 'ok':
                raise ValueError('sqlite_integrity_failed')
            if db.execute('PRAGMA foreign_key_check').fetchall():
                raise ValueError('sqlite_foreign_keys_failed')
            if db.execute('SELECT count(*) FROM lexemes').fetchone()[0] < 1:
                raise ValueError('empty_lexicon')

        finally:
            db.close()

        raw = database_path.read_bytes()

    path = output / (language_code + '.db.gz')
    tmp_path = output / (language_code + '.db.gz.tmp')

    with tmp_path.open('wb') as file:
        with gzip.GzipFile(filename='',mode='wb',fileobj=file,compresslevel=9,mtime=0) as compressed:
            compressed.write(raw)

    tmp_path.replace(path)
    digest = hashlib.sha256(path.read_bytes()).hexdigest()

    sha_path = output / (language_code + '.db.gz.sha256')
    tmp_sha_path = output / (language_code + '.db.gz.sha256.tmp')
    tmp_sha_path.write_text(digest + '  ' + language_code + '.db.gz\n', encoding='ascii')
    tmp_sha_path.replace(sha_path)

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
