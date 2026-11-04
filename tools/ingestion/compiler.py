#!/usr/bin/env python3
"""Compile an editor-reviewed, single-language V2 source into a deterministic SQLite gzip pack.
No network, translation, artificial data generation, signing or user-state modification.
Development compiler only: production admission is specified separately.
"""
import argparse
import gzip
import hashlib
import json
import os
from pathlib import Path
import re
import sqlite3
import sys
import tempfile

BASE = Path(__file__).resolve().parent
SCHEMA = BASE.parents[1] / 'assets' / 'polyglot_v2' / 'pack_v2.sql'
TAG = re.compile(r'^[a-z]{2,3}(?:-[a-z0-9]{2,8})*$')
LEVELS = {'A1', 'A2', 'B1', 'B2', 'C1', 'C2'}

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

def obj(value):
    if not isinstance(value, dict):
        raise ValueError('expected_object')
    return value

def arr(document, field):
    value = document.get(field)
    if not isinstance(value, list):
        raise ValueError('expected_list_' + field)
    return value

def _setup_database(db):
    try:
        db.execute("CREATE VIRTUAL TABLE fts_check USING fts5(term)")
        db.execute("DROP TABLE fts_check")
    except sqlite3.OperationalError:
        raise ValueError("missing_fts5_support")

    db.executescript(SCHEMA.read_text(encoding='utf-8'))

    # ALTER TABLE to add the extra fields from requirement #3
    # since modifying pack_v2.sql is forbidden and they are not in the schema.
    db.execute('ALTER TABLE lexemes ADD COLUMN surface TEXT')
    db.execute('ALTER TABLE lexemes ADD COLUMN sort_key TEXT')
    db.execute('ALTER TABLE lexemes ADD COLUMN fields_json TEXT')

    # FTS5 virtual table
    db.execute('''
        CREATE VIRTUAL TABLE IF NOT EXISTS fts_lexemes USING fts5(
            lexeme_id UNINDEXED,
            lemma,
            display_text,
            tokenize="unicode61 remove_diacritics 2"
        )
    ''')
    db.execute('PRAGMA foreign_keys=ON')


def _insert_language_profile(db, document, language_code):
    language = document['language']
    db.execute('INSERT INTO language_profiles VALUES (?,?,?,?,1)', (
        language_code, req(language,'name_native'), req(language,'name_ar'),
        req(language,'direction')))


def _insert_concepts(db, document):
    for item in sorted(arr(document,'concepts'), key=lambda x:x['concept_id']):
        obj(item)
        level = req(item, 'cefr_level')
        if level not in LEVELS:
            raise ValueError('invalid_concept_cefr_level')
        db.execute('INSERT INTO concepts VALUES (?,?,?,?)', (
            req(item,'concept_id'), req(item,'category'), level,
            int(item.get('priority',1))))


def _insert_lexemes(db, document, language_code):
    lexemes_count = 0
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

        fields_json = item.get('fields_json')
        if fields_json is None:
            fields_json = '{}'
        sort_key = item.get('sort_key')
        surface = item.get('surface', item.get('display_text'))

        gender = item.get('gender')
        article = item.get('article')
        plural = item.get('plural')

        db.execute('''
            INSERT INTO lexemes (
                lexeme_id, concept_id, language_code, sense_id, part_of_speech,
                lemma, display_text, ipa, gender, article, plural, cefr_level,
                grammar_json, surface, sort_key, fields_json
            ) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
        ''', (
            req(item,'lexeme_id'), req(item,'concept_id'), code,
            req(item,'sense_id'), req(item,'part_of_speech'),
            req(item,'lemma'), req(item,'display_text'), item.get('ipa'),
            gender, article, plural, level,
            json.dumps(grammar,ensure_ascii=False,sort_keys=True,separators=(',',':')),
            surface, sort_key, fields_json
        ))

        db.execute('INSERT INTO fts_lexemes (lexeme_id, lemma, display_text) VALUES (?, ?, ?)', (
            req(item,'lexeme_id'), req(item,'lemma'), req(item,'display_text')
        ))
        lexemes_count += 1
    return lexemes_count


def _insert_example_groups(db, document):
    for item in sorted(arr(document,'example_groups'),key=lambda x:x['group_id']):
        obj(item)
        db.execute('INSERT INTO example_groups VALUES (?,?,?)',(
            req(item,'group_id'),req(item,'concept_id'),item.get('context_type','daily')))


def _insert_examples(db, document, language_code):
    examples_count = 0
    for item in sorted(arr(document,'examples'),key=lambda x:x['example_id']):
        obj(item)
        translation = item.get('translation_ar')
        if not translation or not translation.strip():
            raise ValueError('missing_translation')

        db.execute('INSERT INTO examples VALUES (?,?,?,?,?)',(
            req(item,'example_id'),req(item,'group_id'),language_code,
            req(item,'sentence'), translation.strip()))
        examples_count += 1
    return examples_count


def _verify_database(db):
    if db.execute('PRAGMA integrity_check').fetchone()[0] != 'ok':
        raise ValueError('sqlite_integrity_failed')
    if db.execute('PRAGMA foreign_key_check').fetchall():
        raise ValueError('sqlite_foreign_keys_failed')
    if db.execute('SELECT count(*) FROM lexemes').fetchone()[0] < 1:
        raise ValueError('empty_lexicon')


def _write_output(raw, output, language_code, examples_count, lexemes_count):
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

    print(f'BUILT {path} raw_bytes {len(raw)} sha256 {digest} examples {examples_count} lexemes {lexemes_count}')
    return path


def load_source(source):
    # Try decoding UTF-8. Reject if invalid.
    raw = Path(source).read_bytes()
    try:
        text = raw.decode('utf-8')
    except UnicodeDecodeError:
        raise ValueError('invalid_utf8')

    document = obj(json.loads(text))
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
            _setup_database(db)
            _insert_language_profile(db, document, language_code)
            _insert_concepts(db, document)
            lexemes_count = _insert_lexemes(db, document, language_code)
            _insert_example_groups(db, document)
            examples_count = _insert_examples(db, document, language_code)

            db.commit()
            _verify_database(db)
        except Exception:
            db.rollback()
            raise
        finally:
            db.close()
        raw = database_path.read_bytes()

    return _write_output(raw, output, language_code, examples_count, lexemes_count)

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
