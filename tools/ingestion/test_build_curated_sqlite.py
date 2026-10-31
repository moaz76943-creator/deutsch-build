"""Offline regression tests for the editorial German→Arabic SQLite v2 builder."""
import csv
import hashlib
import json
import sqlite3
import tempfile
import unittest
from pathlib import Path

from build_curated_sqlite import build_curated_sqlite, german_sort_key


class CuratedPackTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.source = self.root / "curated.tsv"
        self.output = self.root / "pack.sqlite"

    def write_rows(self, rows):
        with self.source.open("w", encoding="utf-8", newline="") as stream:
            writer = csv.DictWriter(stream, fieldnames=["lemma", "pos", "translation_ar", "ipa", "cefr", "gender_article"], delimiter="\t")
            writer.writeheader()
            writer.writerows(rows)

    def test_sort_key_folds_german_and_strips_punctuation(self):
        self.assertEqual(german_sort_key("Äpfel-Öl ÜBER! Straße"), "aepfeloelueberstrasse")

    def test_complete_contracts_fts_and_exact_digest(self):
        self.write_rows([
            dict(lemma="Äpfel", pos="noun", translation_ar="تفاح", ipa="ˈɛpfl̩", cefr="A1", gender_article="die"),
            dict(lemma="überprüfen", pos="verb", translation_ar="يتحقق", ipa="yːbɐ", cefr="B2", gender_article=""),
        ])
        sha = build_curated_sqlite(self.source, self.output, expected_count=2)
        self.assertEqual(sha, hashlib.sha256(self.output.read_bytes()).hexdigest())
        with sqlite3.connect(self.output) as db:
            self.assertEqual(db.execute("PRAGMA integrity_check").fetchone()[0], "ok")
            self.assertEqual(db.execute("PRAGMA foreign_key_check").fetchall(), [])
            for name in ("lexicon", "lexemes", "examples", "inflections_lookup", "lexicon_fts", "metadata", "concepts", "grammar", "verbs", "verb_conjugations", "nominals", "nominal_declensions", "idioms"):
                self.assertIsNotNone(db.execute("SELECT name FROM sqlite_master WHERE name=?", (name,)).fetchone(), name)
            for name in ("lexicon", "lexemes", "inflections_lookup", "lexicon_fts"):
                self.assertEqual(db.execute(f"SELECT count(*) FROM {name}").fetchone()[0], 2)
            self.assertEqual(db.execute("SELECT count(*) FROM examples").fetchone()[0], 0)
            result = db.execute("SELECT l.surface FROM lexicon_fts f JOIN lexicon l ON l.rowid=f.rowid WHERE lexicon_fts MATCH 'تفاح'").fetchone()
            self.assertEqual(result, ("Äpfel",))
            info = db.execute("SELECT sort_key,pos,part_of_speech,cefr_level,ipa,language_code,fields_json FROM lexicon WHERE surface='Äpfel'").fetchone()
            self.assertEqual(info[:6], ("aepfel", "noun", "noun", "A1", "ˈɛpfl̩", "de"))
            obj = json.loads(info[-1])
            self.assertEqual(obj["translation_ar"], "تفاح")
            self.assertEqual(obj["translation"], "تفاح")
            self.assertEqual(obj["translations"], [{"languageCode":"ar","text":"تفاح"}])
            self.assertEqual(obj["article"], "die")
            self.assertEqual(db.execute("SELECT count(*) FROM inflections_lookup WHERE inflected_form=lemma AND surface_form=lemma").fetchone()[0], 2)
        # No destructive overwrite; idempotent same-content builds accepted.
        self.assertEqual(build_curated_sqlite(self.source, self.output, expected_count=2), sha)

    def test_rejects_duplicate_lemma_pos_and_missing_translation(self):
        self.write_rows([
            dict(lemma="Haus", pos="noun", translation_ar="بيت", ipa="haʊs", cefr="A1", gender_article="das"),
            dict(lemma="Haus", pos="noun", translation_ar="منزل", ipa="haʊs", cefr="A1", gender_article="das"),
        ])
        with self.assertRaisesRegex(ValueError, "duplicate"):
            build_curated_sqlite(self.source, self.output, expected_count=2)
        self.assertFalse(self.output.exists())

    def test_rejects_invalid_cefr(self):
        self.write_rows([
            dict(lemma="Haus", pos="noun", translation_ar="بيت", ipa="haʊs", cefr="Z9", gender_article="das"),
        ])
        with self.assertRaisesRegex(ValueError, "CEFR"):
            build_curated_sqlite(self.source, self.output, expected_count=1)

if __name__ == "__main__":
    unittest.main()
