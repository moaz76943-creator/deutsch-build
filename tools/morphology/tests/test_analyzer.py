import unittest
import tempfile
import os
from pathlib import Path

from tools.morphology.analyzer import MorphologyAnalyzer, get_profile, AnalysisResult
from tools.morphology.build_universal_verbs import build_database as build_verbs
from tools.morphology.build_universal_declensions import build_database as build_declensions

FIXTURES_DIR = Path(__file__).parent / "fixtures"

class TestAnalyzer(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.tmp_dir = tempfile.TemporaryDirectory()
        cls.verb_de_db = Path(cls.tmp_dir.name) / "verbs_de.sqlite"
        cls.noun_de_db = Path(cls.tmp_dir.name) / "nominals_de.sqlite"
        cls.noun_tr_db = Path(cls.tmp_dir.name) / "nominals_tr.sqlite"
        cls.noun_fi_db = Path(cls.tmp_dir.name) / "nominals_fi.sqlite"
        cls.noun_de_ambig_db = Path(cls.tmp_dir.name) / "nominals_de_ambig.sqlite"

        build_verbs(FIXTURES_DIR / "verbs_de.json", cls.verb_de_db, overwrite=True)
        build_declensions(FIXTURES_DIR / "nominals_de.json", cls.noun_de_db, overwrite=True)
        build_declensions(FIXTURES_DIR / "nominals_tr.json", cls.noun_tr_db, overwrite=True)
        build_declensions(FIXTURES_DIR / "nominals_fi.json", cls.noun_fi_db, overwrite=True)
        build_declensions(FIXTURES_DIR / "nominals_de_ambiguous.json", cls.noun_de_ambig_db, overwrite=True)

    @classmethod
    def tearDownClass(cls):
        cls.tmp_dir.cleanup()

    def test_turkish_agglutinative(self):
        tr = get_profile("tr")
        analyzer = MorphologyAnalyzer([str(self.noun_tr_db)], tr)

        res = analyzer.analyze("evlerimizde")
        self.assertEqual(len(res), 1)
        self.assertEqual(res[0].lemma, "ev")
        self.assertEqual(res[0].tags, ["PL", "POSS1P", "LOC"])

        # Test vowel harmony restriction
        res2 = analyzer.analyze("arabaler")
        self.assertEqual(len(res2), 0)

        # False match
        res3 = analyzer.analyze("xyzler")
        self.assertEqual(len(res3), 0)

        analyzer.close()

    def test_finnish_agglutinative(self):
        fi = get_profile("fi")
        analyzer = MorphologyAnalyzer([str(self.noun_fi_db)], fi)

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

        res4 = analyzer.analyze("xyzssäni")
        self.assertEqual(len(res4), 0)

        analyzer.close()

    def test_german_strong_weak(self):
        de = get_profile("de")
        analyzer = MorphologyAnalyzer([
            str(self.verb_de_db),
            str(self.noun_de_db)
        ], de)

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

        # False match
        res_false = analyzer.analyze("gexyz")
        self.assertEqual(len(res_false), 0)

        analyzer.close()

    def test_ambiguous(self):
        de = get_profile("de")
        analyzer = MorphologyAnalyzer([str(self.noun_de_ambig_db)], de)

        res = analyzer.analyze("Toren")
        self.assertEqual(len(res), 3)

        analyzer.close()

if __name__ == '__main__':
    unittest.main()
