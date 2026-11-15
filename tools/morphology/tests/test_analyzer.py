import unittest
import sqlite3
import tempfile
import os
from pathlib import Path
from tools.morphology.analyzer import MorphologyAnalyzer, get_profile, AnalysisResult

class TestAnalyzer(unittest.TestCase):
    def setUp(self):
        self.verb_db_path = os.path.join(os.path.dirname(__file__), "..", "fixtures", "verbs.sqlite")
        self.noun_db_path = os.path.join(os.path.dirname(__file__), "..", "fixtures", "nominals.sqlite")

    def test_turkish_agglutinative(self):
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
        de = get_profile("de")
        analyzer = MorphologyAnalyzer([self.verb_db_path, self.noun_db_path], de)

        res = analyzer.analyze("gemacht")
        self.assertEqual(len(res), 1)
        self.assertEqual(res[0].lemma, "machen")
        self.assertEqual(res[0].tags, ["PART_PERF", "none"])

        res = analyzer.analyze("Kindern")
        self.assertEqual(len(res), 1)
        self.assertEqual(res[0].lemma, "Kind")
        self.assertEqual(res[0].tags, ["dat", "pl", "def"])

        res = analyzer.analyze("ging")
        self.assertEqual(len(res), 1)
        self.assertEqual(res[0].lemma, "gehen")
        self.assertEqual(res[0].tags, ["past", "3s"])

        analyzer.close()

    def test_ambiguous(self):
        de = get_profile("de")
        analyzer = MorphologyAnalyzer([self.noun_db_path], de)

        res = analyzer.analyze("Toren")
        self.assertEqual(len(res), 2)

        analyzer.close()

    def test_german_dative_plural_false_matches(self):
        de = get_profile("de")
        analyzer = MorphologyAnalyzer([self.noun_db_path], de)

        res = analyzer.analyze("Boden")
        self.assertEqual(len(res), 1) # It matches nom sg now

        res = analyzer.analyze("Kindern")
        self.assertEqual(len(res), 1)
        self.assertEqual(res[0].tags, ["dat", "pl", "def"])

        analyzer.close()


if __name__ == '__main__':
    unittest.main()
