import unittest
import sqlite3
import tempfile
import os
from pathlib import Path
from tools.morphology.analyzer import MorphologyAnalyzer, get_profile, AnalysisResult
from tools.morphology.build_universal_verbs import build_database as build_universal_verbs_db
from tools.morphology.build_universal_declensions import build_database as build_nominal_db

class TestAnalyzer(unittest.TestCase):
    def setUp(self):
        self.tmp_dir = tempfile.TemporaryDirectory()

        self.verb_de_db_path = os.path.join(self.tmp_dir.name, "verbs_de.db")
        self.noun_de_db_path = os.path.join(self.tmp_dir.name, "nouns_de.db")
        self.noun_tr_db_path = os.path.join(self.tmp_dir.name, "nouns_tr.db")
        self.noun_fi_db_path = os.path.join(self.tmp_dir.name, "nouns_fi.db")

        fixtures_dir = Path("tools/morphology/tests/fixtures")

        build_universal_verbs_db(fixtures_dir / "verbs_de.json", Path(self.verb_de_db_path))
        build_nominal_db(fixtures_dir / "nominals_de.json", Path(self.noun_de_db_path))
        build_nominal_db(fixtures_dir / "nominals_tr.json", Path(self.noun_tr_db_path))
        build_nominal_db(fixtures_dir / "nominals_fi.json", Path(self.noun_fi_db_path))

    def tearDown(self):
        self.tmp_dir.cleanup()

    def test_turkish_agglutinative(self):
        tr = get_profile("tr")
        analyzer = MorphologyAnalyzer([self.noun_tr_db_path], tr)

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
        analyzer = MorphologyAnalyzer([self.noun_fi_db_path], fi)

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
        analyzer = MorphologyAnalyzer([self.verb_de_db_path, self.noun_de_db_path], de)

        res = analyzer.analyze("Kinder")
        self.assertEqual(len(res), 1)
        self.assertEqual(res[0].lemma, "Kind")
        self.assertEqual(res[0].tags, ["nom", "pl", "def"])

        res = analyzer.analyze("Kindern")
        self.assertEqual(len(res), 1)
        self.assertEqual(res[0].lemma, "Kind")
        self.assertEqual(res[0].tags, ["dat", "pl", "def"])

        res = analyzer.analyze("gemacht")
        self.assertEqual(len(res), 1)
        # "gemachts" is completely invalid
        res = analyzer.analyze("gemachts")
        self.assertEqual(len(res), 0)
        self.assertEqual(res[0].tags, ["PART_PERF", "none"])

        res = analyzer.analyze("ging")
        self.assertEqual(len(res), 1)
        self.assertEqual(res[0].lemma, "gehen")
        self.assertEqual(res[0].tags, ["past", "3s"])

        analyzer.close()

    def test_ambiguous(self):
        de = get_profile("de")
        analyzer = MorphologyAnalyzer([self.noun_de_db_path], de)

        res = analyzer.analyze("Toren")
        self.assertEqual(len(res), 1)  # Found d_tor2_nom_pl but d_tor1_nom_pl form is Tore

        analyzer.close()

    def test_false_matches_rejected(self):
        de = get_profile("de")
        analyzer = MorphologyAnalyzer([self.verb_de_db_path, self.noun_de_db_path], de)

        # "gemacht" is not in the verb db, previously matched via heuristic stripping
        res = analyzer.analyze("gemacht")
        self.assertEqual(len(res), 1)
        # "gemachts" is completely invalid
        res = analyzer.analyze("gemachts")
        self.assertEqual(len(res), 0)
        # "Kinderns" is completely invalid
        res = analyzer.analyze("Kinderns")
        self.assertEqual(len(res), 0)

        analyzer.close()

if __name__ == '__main__':
    unittest.main()
