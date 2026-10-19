import unittest
import sqlite3
import tempfile
import os
from pathlib import Path
from tools.morphology.analyzer import MorphologyAnalyzer, get_profile, AnalysisResult
from tools.morphology.build_universal_verbs import build_database as build_verbs
from tools.morphology.build_universal_declensions import build_database as build_declensions

class TestAnalyzer(unittest.TestCase):
    def setUp(self):
        self.tmp_dir = tempfile.TemporaryDirectory()
        self.fixtures_dir = Path(__file__).parent / "fixtures"

    def tearDown(self):
        self.tmp_dir.cleanup()

    def test_turkish_agglutinative(self):
        noun_db_path = Path(self.tmp_dir.name) / "tr_nouns.sqlite"
        build_declensions(self.fixtures_dir / "tr_nominals.json", noun_db_path)

        tr = get_profile("tr")
        analyzer = MorphologyAnalyzer([str(noun_db_path)], tr)

        res = analyzer.analyze("evlerimizde")
        self.assertEqual(len(res), 1)
        self.assertEqual(res[0].lemma, "ev")
        self.assertEqual(res[0].tags, ["PL", "POSS1P", "LOC"])

        # Test vowel harmony restriction
        res2 = analyzer.analyze("arabaler")
        self.assertEqual(len(res2), 0)

        analyzer.close()

    def test_finnish_agglutinative(self):
        noun_db_path = Path(self.tmp_dir.name) / "fi_nouns.sqlite"
        build_declensions(self.fixtures_dir / "fi_nominals.json", noun_db_path)

        fi = get_profile("fi")
        analyzer = MorphologyAnalyzer([str(noun_db_path)], fi)

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
        verb_db_path = Path(self.tmp_dir.name) / "de_verbs.sqlite"
        noun_db_path = Path(self.tmp_dir.name) / "de_nouns.sqlite"
        build_verbs(self.fixtures_dir / "de_verbs.json", verb_db_path)
        build_declensions(self.fixtures_dir / "de_nominals.json", noun_db_path)

        de = get_profile("de")
        analyzer = MorphologyAnalyzer([str(verb_db_path), str(noun_db_path)], de)

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
        noun_db_path = Path(self.tmp_dir.name) / "ambiguous_nouns.sqlite"
        build_declensions(self.fixtures_dir / "ambiguous_nominals.json", noun_db_path)

        de = get_profile("de")
        analyzer = MorphologyAnalyzer([str(noun_db_path)], de)

        res = analyzer.analyze("Toren")
        # German ambiguous forms - one form multiple matches in DB
        self.assertGreaterEqual(len(res), 2)

        # Test "Tore" returns correctly as well
        res2 = analyzer.analyze("Tore")
        self.assertEqual(len(res2), 1)

        analyzer.close()

if __name__ == '__main__':
    unittest.main()
