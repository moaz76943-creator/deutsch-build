import unittest
import sqlite3
import tempfile
import os
from tools.morphology.analyzer import MorphologyAnalyzer, get_profile
from tools.morphology.export_indexed_morphology import export_to_db

class TestExportIndexedMorphology(unittest.TestCase):
    def setUp(self):
        self.tmp_dir = tempfile.TemporaryDirectory()
        self.verb_db_path = os.path.join(self.tmp_dir.name, "verbs.db")
        self.noun_db_path = os.path.join(self.tmp_dir.name, "nouns.db")
        self.output_db_path = os.path.join(self.tmp_dir.name, "output.db")

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

    def test_export_to_db(self):
        self.vdb.execute("INSERT INTO verbs VALUES ('v1', 'sagen', 'say', 1)")
        self.vdb.commit()

        de = get_profile("de")
        analyzer = MorphologyAnalyzer([self.verb_db_path], de)

        words = ["sagtest"]
        export_to_db(analyzer, words, "de", self.output_db_path)

        conn = sqlite3.connect(self.output_db_path)
        row = conn.execute("SELECT count(*) FROM inflections_lookup").fetchone()
        self.assertEqual(row[0], 1)

        result = conn.execute("SELECT inflected_form, language_code, lemma, pos FROM inflections_lookup").fetchone()
        self.assertEqual(result, ("sagtest", "de", "sagen", "verb"))

        conn.close()
        analyzer.close()

if __name__ == '__main__':
    unittest.main()
