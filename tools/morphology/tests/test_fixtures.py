import unittest
import sqlite3
import os
import json
from pathlib import Path
from tools.morphology.analyzer import MorphologyAnalyzer, get_profile
from tools.morphology.tests.generate_fixtures import generate_fixtures

class TestFixturesOutput(unittest.TestCase):
    def setUp(self):
        generate_fixtures()
        self.verb_db = "tools/morphology/tests/fixtures/verbs.db"
        self.noun_db = "tools/morphology/tests/fixtures/nouns.db"

    def tearDown(self):
        pass # Let fixtures remain for review

    def test_generate_real_indexed_morphology_output(self):
        analyzer_tr = MorphologyAnalyzer([self.noun_db], get_profile("tr"))
        res_tr = analyzer_tr.analyze("evlerimizde")

        analyzer_fi = MorphologyAnalyzer([self.noun_db], get_profile("fi"))
        res_fi = analyzer_fi.analyze("talossani")

        analyzer_de = MorphologyAnalyzer([self.noun_db, self.verb_db], get_profile("de"))
        res_de_ambig = analyzer_de.analyze("Toren")
        res_de_past = analyzer_de.analyze("gearbeitet")

        output = {
            "turkish": [{"surface": r.surface, "lemma": r.lemma, "tags": r.tags} for r in res_tr],
            "finnish": [{"surface": r.surface, "lemma": r.lemma, "tags": r.tags} for r in res_fi],
            "german_ambiguous": [{"surface": r.surface, "lemma": r.lemma, "tags": r.tags} for r in res_de_ambig],
            "german_past": [{"surface": r.surface, "lemma": r.lemma, "tags": r.tags} for r in res_de_past]
        }

        output_path = "tools/morphology/tests/fixtures/morphology_output.json"
        with open(output_path, "w") as f:
            json.dump(output, f, indent=2, ensure_ascii=False)

        self.assertTrue(os.path.exists(output_path))
        self.assertTrue(len(res_tr) > 0)
        self.assertTrue(len(res_fi) > 0)
        self.assertTrue(len(res_de_ambig) > 0)
        self.assertTrue(len(res_de_past) > 0)

        analyzer_tr.close()
        analyzer_fi.close()
        analyzer_de.close()

if __name__ == '__main__':
    unittest.main()
