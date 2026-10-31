"""Focused offline regression tests for schema injection."""
import importlib.util
import json
import sqlite3
import tempfile
import unittest
from pathlib import Path

spec = importlib.util.spec_from_file_location("schema_v2", Path(__file__).with_name("inject_schema_v2.py"))
schema = importlib.util.module_from_spec(spec)
spec.loader.exec_module(schema)


class SchemaV2Test(unittest.TestCase):
    def test_lossless_upgrade_and_fts(self):
        with tempfile.TemporaryDirectory() as directory:
            source = Path(directory) / "source.sqlite"
            target = Path(directory) / "target.sqlite"
            with sqlite3.connect(source) as db:
                db.execute("CREATE TABLE lexicon(id TEXT PRIMARY KEY, surface TEXT, part_of_speech TEXT, fields_json TEXT)")
                fields = {"canonical": {"cefr": "A2", "frequencyRank": 6},
                          "translations": [{"languageCode": "ar", "text": "البيت"}]}
                db.execute("INSERT INTO lexicon VALUES (?,?,?,?)",
                           ("1", "Haus", "noun", json.dumps(fields)))
            self.assertEqual(schema.build_copy(source, target), 1)
            with sqlite3.connect(source) as db:
                self.assertEqual(len(list(db.execute("PRAGMA table_info(lexicon)"))), 4)
            with sqlite3.connect(target) as db:
                self.assertEqual(db.execute("SELECT cefr_level,frequency_rank,sort_key FROM lexicon").fetchone(),
                                 ("A2", 6, "haus"))
                self.assertEqual(db.execute("SELECT rowid FROM lexicon_fts WHERE lexicon_fts MATCH 'Haus'").fetchone()[0], 1)
                self.assertEqual(db.execute("SELECT translation_ar FROM lexicon_fts").fetchone()[0], "البيت")
                for table in ("verbs", "verb_conjugations", "idioms", "nominals", "nominal_declensions"):
                    self.assertIsNotNone(db.execute("SELECT name FROM sqlite_master WHERE name=?", (table,)).fetchone())
                self.assertEqual(schema.inject_schema(db), 1)
                self.assertEqual(db.execute("SELECT count(*) FROM lexicon_fts").fetchone()[0], 1)
            with self.assertRaises(ValueError):
                schema.build_copy(source, target)

    def test_rejects_invalid_inputs(self):
        with sqlite3.connect(":memory:") as db:
            with self.assertRaises(ValueError):
                schema.inject_schema(db)
        with sqlite3.connect(":memory:") as db:
            db.execute("CREATE TABLE lexicon(id TEXT, surface TEXT, part_of_speech TEXT, fields_json TEXT)")
            db.execute("INSERT INTO lexicon VALUES('1','Haus','noun',?)",
                       (json.dumps({"frequencyRank": False}),))
            with self.assertRaises(ValueError):
                schema.inject_schema(db)


if __name__ == "__main__":
    unittest.main()
