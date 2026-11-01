import unittest
import sqlite3
import tempfile
import os
from pathlib import Path
from tools.morphology.analyzer import MorphologyAnalyzer, get_profile, AnalysisResult

class TestAnalyzer(unittest.TestCase):
    def setUp(self):
        self.tmp_dir = tempfile.TemporaryDirectory()
        self.verb_db_path = os.path.join(self.tmp_dir.name, "verbs.db")
        self.noun_db_path = os.path.join(self.tmp_dir.name, "nouns.db")

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

    def test_turkish_agglutinative(self):
        self.ndb.execute("INSERT INTO nominals VALUES ('ev1', 'ev', 'noun', 'none', 'sg')")
        self.ndb.execute("INSERT INTO nominals VALUES ('araba1', 'araba', 'noun', 'none', 'sg')")
        self.ndb.commit()

        tr = get_profile("tr")
        analyzer = MorphologyAnalyzer([self.noun_db_path], tr)

        res = analyzer.analyze("evlerimizde")
        self.assertEqual(len(res), 1)
        self.assertEqual(res[0].lemma, "ev")
        self.assertEqual(res[0].tags, ["PL", "POSS1P", "LOC"])

        # Test vowel harmony restriction
        res2 = analyzer.analyze("arabaler")
        self.assertEqual(len(res2), 0)

        analyzer.close()

    def test_finnish_agglutinative(self):
        self.ndb.execute("INSERT INTO nominals VALUES ('talo1', 'talo', 'noun', 'none', 'sg')")
        self.ndb.execute("INSERT INTO nominals VALUES ('metsä1', 'metsä', 'noun', 'none', 'sg')")
        self.ndb.commit()

        fi = get_profile("fi")
        analyzer = MorphologyAnalyzer([self.noun_db_path], fi)

        res = analyzer.analyze("talossani")
        self.assertEqual(len(res), 1)
        self.assertEqual(res[0].lemma, "talo")
        self.assertEqual(res[0].tags, ["INE", "POSS1S"])

        res2 = analyzer.analyze("metsässäni")
        self.assertEqual(len(res2), 1)
        self.assertEqual(res2[0].lemma, "metsä")
        self.assertEqual(res2[0].tags, ["INE", "POSS1S"])

        res3 = analyzer.analyze("talossä")
        self.assertEqual(len(res3), 0)

        analyzer.close()

    def test_german_strong_weak(self):
        self.vdb.execute("INSERT INTO verbs VALUES ('v1', 'machen', 'make', 1)")
        self.vdb.execute("INSERT INTO verbs VALUES ('v2', 'gehen', 'go', 2)")
        self.vdb.execute("INSERT INTO verb_conjugations VALUES ('c1', 'v1', 'present', '1s', 'mache')")
        self.vdb.execute("INSERT INTO verb_conjugations VALUES ('c2', 'v2', 'past', '3s', 'ging')")
        self.vdb.execute("INSERT INTO verb_conjugations VALUES ('c3', 'v1', 'PART_PERF', '', 'gemacht')")
        self.vdb.commit()

        self.ndb.execute("INSERT INTO nominals VALUES ('n1', 'Kind', 'noun', 'neu', 'sg')")
        self.ndb.execute("INSERT INTO nominal_declensions VALUES ('d1', 'n1', 'nom', 'pl', 'def', 'Kinder')")
        self.ndb.execute("INSERT INTO nominal_declensions VALUES ('d2', 'n1', 'DAT', 'PL', '', 'Kindern')")
        self.ndb.commit()

        de = get_profile("de")
        analyzer = MorphologyAnalyzer([self.verb_db_path, self.noun_db_path], de)

        res = analyzer.analyze("gemacht")
        self.assertEqual(len(res), 1)
        self.assertEqual(res[0].lemma, "machen")
        self.assertEqual(res[0].tags, ["PART_PERF"])

        res = analyzer.analyze("Kindern")
        self.assertEqual(len(res), 1)
        self.assertEqual(res[0].lemma, "Kind")
        self.assertEqual(res[0].tags, ["DAT", "PL"])

        res = analyzer.analyze("ging")
        self.assertEqual(len(res), 1)
        self.assertEqual(res[0].lemma, "gehen")
        self.assertEqual(res[0].tags, ["past", "3s"])

        analyzer.close()

    def test_ambiguous(self):
        self.ndb.execute("INSERT INTO nominals VALUES ('n1', 'Tor', 'noun', 'neu', 'sg')")
        self.ndb.execute("INSERT INTO nominal_declensions VALUES ('d1', 'n1', 'nom', 'sg', 'def', 'Tor')")
        self.ndb.execute("INSERT INTO nominal_declensions VALUES ('d2', 'n1', 'nom', 'pl', 'def', 'Tore')")
        self.ndb.execute("INSERT INTO nominal_declensions VALUES ('d2b', 'n1', 'DAT', 'PL', 'def', 'Toren')")

        self.ndb.execute("INSERT INTO nominals VALUES ('n2', 'Tor', 'noun', 'masc', 'sg')")
        self.ndb.execute("INSERT INTO nominal_declensions VALUES ('d3', 'n2', 'nom', 'sg', 'def', 'Tor')")
        self.ndb.execute("INSERT INTO nominal_declensions VALUES ('d4', 'n2', 'nom', 'pl', 'def', 'Toren')")
        self.ndb.commit()

        de = get_profile("de")
        analyzer = MorphologyAnalyzer([self.noun_db_path], de)

        res = analyzer.analyze("Toren")
        self.assertEqual(len(res), 2)

        analyzer.close()

    def test_german_dative_plural_false_matches(self):
        self.ndb.execute("INSERT INTO nominals VALUES ('n1', 'Boden', 'noun', 'masc', 'sg')")
        self.ndb.execute("INSERT INTO nominal_declensions VALUES ('d1', 'n1', 'nom', 'sg', 'def', 'Bode')") # mock stem
        self.ndb.execute("INSERT INTO nominal_declensions VALUES ('d3', 'n1', 'nom', 'sg', 'def', 'Boden')")

        self.ndb.execute("INSERT INTO nominals VALUES ('n2', 'Kind', 'noun', 'neu', 'sg')")
        self.ndb.execute("INSERT INTO nominal_declensions VALUES ('d2', 'n2', 'nom', 'pl', 'def', 'Kinder')")
        self.ndb.execute("INSERT INTO nominal_declensions VALUES ('d4', 'n2', 'DAT', 'PL', '', 'Kindern')")
        self.ndb.commit()

        de = get_profile("de")
        analyzer = MorphologyAnalyzer([self.noun_db_path], de)

        res = analyzer.analyze("Boden")
        self.assertEqual(len(res), 1)
        self.assertEqual(res[0].tags, ["nom", "sg", "def"])

        res = analyzer.analyze("Kindern")
        self.assertEqual(len(res), 1)
        self.assertEqual(res[0].tags, ["DAT", "PL"])

        analyzer.close()


if __name__ == '__main__':
    unittest.main()
