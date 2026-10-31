import unittest.mock
import copy
import gzip
import hashlib
import json
from pathlib import Path
import sqlite3
import tempfile
import unittest
from compiler import build, tag

HERE = Path(__file__).resolve().parent
PROGRESS = HERE.parents[1] / 'assets' / 'polyglot_v2' / 'progress_v2.sql'
SOURCE_JSON = HERE.parents[1] / 'tools' / 'polyglot_v2' / 'source_de_train_v2.json'

class PolyglotV2Test(unittest.TestCase):
    def test_excluded_language_aliases(self):
        for alias in ('he','iw','he-IL','iw-IL','HE','he_il'):
            with self.subTest(alias=alias):
                with self.assertRaises(ValueError): tag(alias)

    def test_sqlite_pack_and_isolated_progress(self):
        with tempfile.TemporaryDirectory() as root:
            pack = build(SOURCE_JSON, root)
            archive = pack.read_bytes()
            actual_hash = hashlib.sha256(archive).hexdigest()
            checksum = pack.with_suffix(pack.suffix + '.sha256').read_text()
            self.assertTrue(checksum.startswith(actual_hash))
            database = Path(root) / 'de.sqlite'
            database.write_bytes(gzip.decompress(archive))
            with sqlite3.connect(database) as connection:
                self.assertEqual(connection.execute('PRAGMA integrity_check').fetchone()[0], 'ok')
                self.assertEqual(connection.execute('SELECT article,plural FROM lexemes').fetchone(), ('der','Züge'))
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
            document=json.loads(SOURCE_JSON.read_text())
            document['lexemes'][0]['concept_id']='nonexistent.concept'
            source=Path(root)/'invalid.json'
            source.write_text(json.dumps(document),encoding='utf-8')
            with self.assertRaises(sqlite3.IntegrityError):
                build(source,root)

    def test_deterministic_output_and_synonym_support(self):
        with tempfile.TemporaryDirectory() as root:
            original=json.loads(SOURCE_JSON.read_text())
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


    def test_fts5_virtual_table_search(self):
        with tempfile.TemporaryDirectory() as root:
            pack = build(SOURCE_JSON, root)
            archive = pack.read_bytes()
            database = Path(root) / 'de.sqlite'
            database.write_bytes(gzip.decompress(archive))
            with sqlite3.connect(database) as connection:
                # Test the FTS5 virtual table we added
                result = connection.execute("SELECT lexeme_id FROM fts_lexemes WHERE fts_lexemes MATCH 'Zug'").fetchall()
                self.assertEqual(len(result), 1)
                self.assertEqual(result[0][0], 'lex.de.travel.train.01')

    def test_malformed_data(self):
        with tempfile.TemporaryDirectory() as root:
            document = json.loads(SOURCE_JSON.read_text())
            del document['lexemes'][0]['lemma']
            source = Path(root) / 'malformed.json'
            source.write_text(json.dumps(document), encoding='utf-8')
            with self.assertRaises(ValueError):
                build(source, root)

    def test_duplicate_ids(self):
        with tempfile.TemporaryDirectory() as root:
            document = json.loads(SOURCE_JSON.read_text())
            document['lexemes'].append(document['lexemes'][0])
            source = Path(root) / 'duplicate.json'
            source.write_text(json.dumps(document), encoding='utf-8')
            with self.assertRaises(sqlite3.IntegrityError):
                build(source, root)

    def test_missing_translations(self):
        with tempfile.TemporaryDirectory() as root:
            document = json.loads(SOURCE_JSON.read_text())
            document['examples'][0]['translation_ar'] = '   '
            source = Path(root) / 'missing_trans.json'
            source.write_text(json.dumps(document), encoding='utf-8')
            with self.assertRaisesRegex(ValueError, "missing_translation"):
                build(source, root)

    def test_invalid_utf8(self):
        with tempfile.TemporaryDirectory() as root:
            source = Path(root) / 'invalid.json'
            source.write_bytes(b'{\x80\x81}')
            with self.assertRaisesRegex(ValueError, 'invalid_utf8'):
                build(source, root)



    def test_missing_fts5_support(self):
        with tempfile.TemporaryDirectory() as root:
            # Create a mock sqlite3 module
            class MockConnection:
                def execute(self, statement, *args, **kwargs):
                    if "fts5" in statement.lower():
                        raise sqlite3.OperationalError("no such module: fts5")
                    return self
                def executescript(self, script): pass
                def commit(self): pass
                def close(self): pass
                def rollback(self): pass
                def fetchall(self): return []
                def fetchone(self): return ['ok']

            with unittest.mock.patch('sqlite3.connect') as mock_connect:
                mock_connect.return_value = MockConnection()
                with self.assertRaisesRegex(ValueError, "missing_fts5_support"):
                    build(SOURCE_JSON, root)

if __name__ == '__main__':
    unittest.main()
