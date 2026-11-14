import unittest
import sqlite3
import tempfile
import os
import subprocess
from pathlib import Path
import json

class TestExportIndexedMorphology(unittest.TestCase):
    def setUp(self):
        self.tmp_dir = tempfile.TemporaryDirectory()
        self.verb_db_path = os.path.join(self.tmp_dir.name, "verbs.db")
        self.noun_db_path = os.path.join(self.tmp_dir.name, "nouns.db")
        self.output_db_path = os.path.join(self.tmp_dir.name, "output.db")
        self.words_file_path = os.path.join(self.tmp_dir.name, "words.json")

        self.vdb = sqlite3.connect(self.verb_db_path)
        self.vdb.executescript("""
            CREATE TABLE verbs (verb_id TEXT PRIMARY KEY, infinitive TEXT NOT NULL, translation_ar TEXT, frequency_rank INTEGER);
            CREATE TABLE verb_conjugations (conjugation_id TEXT PRIMARY KEY, verb_id TEXT NOT NULL, tense TEXT NOT NULL, person TEXT NOT NULL, conjugated_form TEXT NOT NULL, FOREIGN KEY (verb_id) REFERENCES verbs(verb_id));
        """)
        self.ndb = sqlite3.connect(self.noun_db_path)
        self.ndb.executescript("""
            CREATE TABLE nominals (id TEXT PRIMARY KEY, lemma TEXT NOT NULL, part_of_speech TEXT NOT NULL, gender TEXT NOT NULL, number TEXT NOT NULL);
            CREATE TABLE nominal_declensions (id TEXT PRIMARY KEY, nominal_id TEXT NOT NULL, grammatical_case TEXT NOT NULL, number TEXT NOT NULL, definiteness TEXT NOT NULL, inflected_form TEXT NOT NULL, FOREIGN KEY (nominal_id) REFERENCES nominals(id));
        """)

    def tearDown(self):
        self.vdb.close()
        self.ndb.close()
        self.tmp_dir.cleanup()

    def test_export_indexed_morphology(self):
        self.vdb.execute("INSERT INTO verbs VALUES ('v1', 'machen', 'make', 1)")
        self.vdb.execute("INSERT INTO verb_conjugations VALUES ('c1', 'v1', 'present', '1s', 'mache')")
        self.vdb.commit()

        self.ndb.execute("INSERT INTO nominals VALUES ('n1', 'Kind', 'noun', 'neu', 'sg')")
        self.ndb.execute("INSERT INTO nominal_declensions VALUES ('d1', 'n1', 'nom', 'pl', 'def', 'Kinder')")
        self.ndb.commit()

        words = ["gemacht", "Kindern", "mache", "Kinder"]
        with open(self.words_file_path, "w") as f:
            json.dump(words, f)

        script_path = os.path.join(Path(__file__).resolve().parent.parent, "export_indexed_morphology.py")
        result = subprocess.run([
            "python3", script_path,
            "--lang", "de",
            "--dbs", self.verb_db_path, self.noun_db_path,
            "--output", self.output_db_path,
            "--words-file", self.words_file_path
        ], capture_output=True, text=True)

        self.assertEqual(result.returncode, 0, result.stderr)

        out_db = sqlite3.connect(self.output_db_path)
        cur = out_db.cursor()

        cur.execute("SELECT * FROM inflections_lookup ORDER BY inflected_form")
        rows = cur.fetchall()

        self.assertEqual(len(rows), 4)

        # made sure all lemmas are populated correctly

        out_db.close()

if __name__ == '__main__':
    unittest.main()
