"""Offline deterministic pilot-pack compiler regression checks."""
import base64
import gzip
import json
import sqlite3
import tempfile
import unittest
from pathlib import Path

try:
    from tools.ingestion.build_pilot_packs import compile_pilots
except ModuleNotFoundError:
    from build_pilot_packs import compile_pilots


class PilotPackTest(unittest.TestCase):
    def test_deterministic_schema_fts_and_manifest(self):
        with tempfile.TemporaryDirectory() as root:
            root = Path(root)
            incoming = root / "input"
            ranks = root / "ranks"
            output = root / "built"
            incoming.mkdir()
            ranks.mkdir()
            records = [
                {"word": "book", "pos": "noun",
                 "senses": [{"glosses": ["printed pages"]}],
                 "translations": [{"lang_code": "ar", "word": "كتاب"}]},
                {"word": "house", "pos": "noun",
                 "senses": [{"glosses": ["a dwelling"]}],
                 "translations": [{"lang_code": "ar", "word": "بيت"}]},
            ]
            (incoming / "en.jsonl").write_text(
                "\n".join(json.dumps(record) for record in records) + "\n",
                encoding="utf-8")
            (ranks / "en.csv").write_text(
                "word,rank,cefr\nhouse,1,A1\nbook,2,A1\n", encoding="utf-8")

            manifest = compile_pilots(incoming, ranks, output, 2)
            bundle = (output / "en.pack.gz").read_bytes()
            import hashlib
            self.assertEqual(manifest["packs"][0]["sha256"],
                             hashlib.sha256(bundle).hexdigest())
            archive = json.loads(gzip.decompress(bundle))
            self.assertEqual(archive["packId"], "en")
            files = {item["path"]: base64.b64decode(item["contentBase64"])
                     for item in archive["files"]}
            self.assertEqual(set(files), {"content/content.json",
                                           "content/content.sqlite",
                                           "metadata/pack.json"})
            db_path = root / "content.sqlite"
            db_path.write_bytes(files["content/content.sqlite"])
            with sqlite3.connect(db_path) as db:
                self.assertEqual(db.execute("PRAGMA integrity_check").fetchone()[0], "ok")
                self.assertEqual(db.execute(
                    "SELECT COUNT(*) FROM lexicon_fts").fetchone()[0], 2)
                self.assertEqual(db.execute(
                    "SELECT cefr_level,frequency_rank FROM lexicon "
                    "WHERE surface='house'").fetchone(), ("A1", 1))
                self.assertEqual(db.execute(
                    "SELECT surface FROM lexicon_fts "
                    "WHERE lexicon_fts MATCH 'house'").fetchone()[0], "house")
                for name in ("verbs", "verb_conjugations", "idioms",
                             "nominals", "nominal_declensions", "inflections_lookup"):
                    self.assertTrue(db.execute(
                        "SELECT name FROM sqlite_master WHERE name=?", (name,)
                    ).fetchone())
                columns = {column[1] for column in db.execute(
                    "PRAGMA table_info(inflections_lookup)")}
                self.assertEqual(columns, {
                    "surface_form", "lemma", "lexicon_id", "language_code"})
                indexes = {index[1] for index in db.execute(
                    "PRAGMA index_list(inflections_lookup)")}
                self.assertIn("idx_inflections_lookup_surface", indexes)
                fields = json.loads(db.execute(
                    "SELECT fields_json FROM lexicon WHERE surface='book'"
                ).fetchone()[0])
                self.assertEqual(fields["translation_ar"], "كتاب")
                self.assertEqual(fields["translation"], "كتاب")
                self.assertEqual(fields["translationLanguageCode"], "ar")
                self.assertEqual(fields["translations"],
                                 [{"languageCode": "ar", "text": "كتاب"}])
                self.assertEqual(fields["definitions"],
                                 [{"languageCode": "en", "text": "printed pages"}])
            self.assertEqual(compile_pilots(incoming, ranks, output, 2),
                             manifest)
            self.assertEqual((output / "en.pack.gz").read_bytes(), bundle)

    def test_english_gloss_does_not_claim_to_be_arabic(self):
        try:
            from tools.ingestion.build_pilot_packs import to_entry, materialize
        except ModuleNotFoundError:
            from build_pilot_packs import to_entry, materialize

        entry = to_entry({
            "word": "Hund", "pos": "noun",
            "senses": [{"glosses": ["dog"]}],
        }, "de", {})
        self.assertIsNotNone(entry)
        with tempfile.TemporaryDirectory() as directory:
            target = Path(directory) / "de.sqlite"
            materialize(target, "de", [entry])
            with sqlite3.connect(target) as db:
                fields = json.loads(db.execute(
                    "SELECT fields_json FROM lexicon").fetchone()[0])
                self.assertIsNone(fields["translation_ar"])
                self.assertEqual(fields["translation"], "dog")
                self.assertEqual(fields["translationLanguageCode"], "en")
                self.assertEqual(fields["definitions"],
                                 [{"languageCode": "en", "text": "dog"}])

    def test_missing_inputs_do_not_publish(self):
        with tempfile.TemporaryDirectory() as directory:
            base = Path(directory)
            sources = base / "sources"
            sources.mkdir()
            with self.assertRaises(ValueError):
                compile_pilots(sources, None, base / "output", 10)
            self.assertFalse((base / "output").exists())


if __name__ == "__main__":
    unittest.main()
