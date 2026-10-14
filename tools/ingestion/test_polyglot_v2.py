"""stdlib-only contract tests; run before any cloud build."""
import copy
import gzip
import hashlib
import json
from pathlib import Path
import sqlite3
import tempfile
import unittest
from compile_v2_pack_safe import build, tag

HERE = Path(__file__).resolve().parent
PROGRESS = HERE.parents[1] / 'assets' / 'polyglot_v2' / 'progress_v2.sql'

class PolyglotV2Test(unittest.TestCase):
    def test_excluded_language_aliases(self):
        for alias in ('he','iw','he-IL','iw-IL','HE','he_il'):
            with self.subTest(alias=alias):
                with self.assertRaises(ValueError): tag(alias)

    def test_sqlite_pack_and_isolated_progress(self):
        with tempfile.TemporaryDirectory() as root:
            pack = build(HERE / 'source_de_train_v2.json', root)
            archive = pack.read_bytes()
            actual_hash = hashlib.sha256(archive).hexdigest()
            checksum = pack.with_suffix(pack.suffix + '.sha256').read_text()
            self.assertTrue(checksum.startswith(actual_hash))
            database = Path(root) / 'de.sqlite'
            database.write_bytes(gzip.decompress(archive))
            with sqlite3.connect(database) as connection:
                self.assertEqual(connection.execute('PRAGMA integrity_check').fetchone()[0], 'ok')
                # Extracting article and plural from fields_json
                fields_json_str = connection.execute('SELECT fields_json FROM lexemes').fetchone()[0]
                fields_json = json.loads(fields_json_str)
                self.assertEqual(fields_json.get('article'), 'der')
                self.assertEqual(fields_json.get('plural'), 'Züge')
                self.assertEqual(connection.execute('SELECT sentence FROM examples').fetchone()[0], 'Ich fahre mit dem Zug.')
                self.assertIsNone(connection.execute("SELECT name FROM sqlite_master WHERE name='srs_progress'").fetchone())
            with sqlite3.connect(Path(root) / 'progress.sqlite') as progress:
                progress.executescript(PROGRESS.read_text())
                self.assertIsNotNone(progress.execute("SELECT name FROM sqlite_master WHERE name='srs_progress'").fetchone())
                progress.execute("""INSERT INTO srs_progress
                    (progress_key,lexeme_id,concept_id,source_language_code,target_language_code,skill)
                    VALUES ('local|ar>de|train|recognition','lex.de.travel.train.01',
                    'travel.train.01','ar','de','recognition')""")
                self.assertEqual(progress.execute('SELECT count(*) FROM srs_progress').fetchone()[0],1)

    def test_reject_nonexistent_concept_reference(self):
        with tempfile.TemporaryDirectory() as root:
            document=json.loads((HERE / 'source_de_train_v2.json').read_text())
            document['lexemes'][0]['concept_id']='nonexistent.concept'
            source=Path(root)/'invalid.json'
            source.write_text(json.dumps(document),encoding='utf-8')
            with self.assertRaises(sqlite3.IntegrityError):
                build(source,root)

    def test_deterministic_output_and_synonym_support(self):
        with tempfile.TemporaryDirectory() as root:
            original=json.loads((HERE / 'source_de_train_v2.json').read_text())
            synonym=copy.deepcopy(original['lexemes'][0])
            synonym['lexeme_id']='lex.de.travel.train.02'
            synonym['lemma']='Eisenbahnzug'
            synonym['display_text']='der Eisenbahnzug'
            original['lexemes'].append(synonym)
            source=Path(root)/'synonyms.json'
            source.write_text(json.dumps(original,ensure_ascii=False),encoding='utf-8')
            first=build(source,Path(root)/'first')
            second=build(source,Path(root)/'second')
            self.assertEqual(first.read_bytes(),second.read_bytes())
            db_path=Path(root)/'data.sqlite'
            db_path.write_bytes(gzip.decompress(first.read_bytes()))
            with sqlite3.connect(db_path) as db:
                self.assertEqual(db.execute('SELECT count(*) FROM lexemes').fetchone()[0],2)

    def test_malformed_data(self):
        with tempfile.TemporaryDirectory() as root:
            source = Path(root) / 'malformed.json'
            # Missing language_code
            source.write_text('{"schema_version": 2, "language": {"name_native":"X","name_ar":"X","direction":"ltr"}, "concepts":[], "lexemes":[], "example_groups":[], "examples":[]}')
            with self.assertRaises(ValueError):
                build(source, root)

    def test_duplicate_ids(self):
        with tempfile.TemporaryDirectory() as root:
            document = json.loads((HERE / 'source_de_train_v2.json').read_text())
            # Duplicate concept ID
            document['concepts'].append(document['concepts'][0])
            source = Path(root) / 'dup.json'
            source.write_text(json.dumps(document), encoding='utf-8')
            with self.assertRaises(sqlite3.IntegrityError):
                build(source, root)

    def test_missing_translations(self):
        with tempfile.TemporaryDirectory() as root:
            document = json.loads((HERE / 'source_de_train_v2.json').read_text())
            document['examples'][0]['translation_ar'] = ''
            source = Path(root) / 'missing_trans.json'
            source.write_text(json.dumps(document), encoding='utf-8')
            with self.assertRaisesRegex(ValueError, 'invalid_or_empty_translation_ar'):
                build(source, root)

    def test_invalid_utf8(self):
        with tempfile.TemporaryDirectory() as root:
            source = Path(root) / 'invalid_utf8.json'
            source.write_bytes(b'{"schema_version": 2, "language": \xff}')
            with self.assertRaisesRegex(ValueError, 'invalid_utf8_encoding'):
                build(source, root)

    def test_missing_fts5_support(self):
        import unittest.mock
        with tempfile.TemporaryDirectory() as root:
            source = Path(root) / 'valid.json'
            source.write_text((HERE / 'source_de_train_v2.json').read_text())
            # mock build_fts5_tables to do nothing, triggering fts5_count_mismatch
            with unittest.mock.patch('compile_v2_pack_safe.build_fts5_tables', lambda db: None):
                with self.assertRaisesRegex(sqlite3.OperationalError, 'no such table: lexemes_fts'):
                    build(source, root)

if __name__ == '__main__':
    unittest.main()
