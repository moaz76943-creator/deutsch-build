"""Offline regression checks for the bounded Kaikki pilot harvester."""
import gzip
import json
import tempfile
import unittest
from pathlib import Path

try:
    from tools.ingestion.fetch_kaikki_pilot import fetch_one, main
except ModuleNotFoundError:
    from fetch_kaikki_pilot import fetch_one, main


class PilotFetchTest(unittest.TestCase):
    def test_local_jsonl_filters_and_deduplicates(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source = root / "source"
            source.mkdir()
            records = [
                {"word": "Haus", "pos": "noun", "lang_code": "de",
                 "senses": [{"glosses": ["house"]}]},
                {"word": "Haus", "pos": "noun", "lang_code": "de",
                 "senses": [{"glosses": ["house"]}]},
                {"word": "Casa", "pos": "noun", "lang_code": "es",
                 "senses": [{"glosses": ["house"]}]},
                {"word": "gehen", "pos": "verb", "lang_code": "de",
                 "senses": [{"glosses": ["to go"]}], "cefr": "A1"},
            ]
            (source / "de.jsonl").write_text(
                "".join(json.dumps(item) + "\n" for item in records),
                encoding="utf-8")
            count, path = fetch_one("de", root / "inputs", source, 10, 10, 2)
            self.assertEqual(count, 2)
            rows = [json.loads(line) for line in path.read_text().splitlines()]
            self.assertEqual([row["word"] for row in rows], ["Haus", "gehen"])
            self.assertNotIn("cefr", rows[0])
            self.assertEqual(rows[1]["cefr"], "A1")
            self.assertEqual(fetch_one("de", root / "inputs", source, 10, 10, 2)[0], 2)
            (source / "de.jsonl").write_text(json.dumps(
                {"word": "neu", "pos": "noun", "lang_code": "de",
                 "senses": [{"glosses": ["new"]}]}) + "\n", encoding="utf-8")
            with self.assertRaises(FileExistsError):
                fetch_one("de", root / "inputs", source, 10, 10, 2)
            self.assertEqual(len(path.read_text().splitlines()), 2)

    def test_gzip_local_and_no_network(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source = root / "source"
            source.mkdir()
            with gzip.open(source / "fr.jsonl.gz", "wt", encoding="utf-8") as output:
                output.write(json.dumps({"word": "livre", "pos": "noun",
                    "lang_code": "fr", "senses": [{"glosses": ["book"]}]}) + "\n")
            self.assertEqual(main(["--source-dir", str(source),
                                   "--input-dir", str(root / "inputs"),
                                   "--languages", "fr"]), 0)
            self.assertTrue((root / "inputs" / "fr.jsonl").exists())

    def test_empty_input_never_publishes(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "en.jsonl").write_text('{"lang_code":"de"}\n')
            with self.assertRaises(ValueError):
                fetch_one("en", root / "out", root, 5, 5, 1)
            self.assertFalse((root / "out" / "en.jsonl").exists())


if __name__ == "__main__":
    unittest.main()
