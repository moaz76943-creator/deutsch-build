import unittest
import sqlite3
import tempfile
import os
from pathlib import Path
from tools.morphology.export_indexed_morphology import export_indexed_morphology

class TestExportIndexedMorphology(unittest.TestCase):
    def setUp(self):
        self.tmp_dir = tempfile.TemporaryDirectory()
        self.noun_db_path = os.path.join(self.tmp_dir.name, "nouns.db")
        self.out_db_path = os.path.join(self.tmp_dir.name, "out.db")

        self.ndb = sqlite3.connect(self.noun_db_path)
        self.ndb.executescript("""
            CREATE TABLE nominals (id TEXT PRIMARY KEY, lemma TEXT NOT NULL, part_of_speech TEXT NOT NULL, gender TEXT NOT NULL, number TEXT NOT NULL);
            CREATE TABLE nominal_declensions (id TEXT PRIMARY KEY, nominal_id TEXT NOT NULL, grammatical_case TEXT NOT NULL, number TEXT NOT NULL, definiteness TEXT NOT NULL, inflected_form TEXT NOT NULL, FOREIGN KEY (nominal_id) REFERENCES nominals(id));
        """)

        # Add some German noun fixtures
        self.ndb.execute("INSERT INTO nominals VALUES ('n1', 'Kind', 'noun', 'neu', 'sg')")
        self.ndb.execute("INSERT INTO nominal_declensions VALUES ('d1', 'n1', 'nom', 'pl', 'def', 'Kinder')")
        self.ndb.commit()

    def tearDown(self):
        self.ndb.close()
        self.tmp_dir.cleanup()

    def test_export_indexed_morphology(self):
        words = ["Kindern", "invalid_word"]

        export_indexed_morphology([self.noun_db_path], "de", self.out_db_path, words)

        conn = sqlite3.connect(self.out_db_path)
        conn.row_factory = sqlite3.Row
        cursor = conn.execute("SELECT * FROM inflections_lookup")
        rows = cursor.fetchall()

        self.assertEqual(len(rows), 1)
        row = dict(rows[0])
        self.assertEqual(row['inflected_form'], "Kindern")
        self.assertEqual(row['language_code'], "de")
        self.assertEqual(row['lemma'], "Kind")
        self.assertEqual(row['pos'], "noun")
        self.assertEqual(row['lexicon_id'], "n1")
        self.assertEqual(row['source_kind'], "lexicon")

        conn.close()

if __name__ == '__main__':
    unittest.main()
