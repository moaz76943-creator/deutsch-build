"""Focused stdlib tests; no network, UI, or global test changes."""
import copy
import json
import tempfile
import unittest
from pathlib import Path

import build_canonical_lexicon as subject


def strict_factory_shape(document):
    """Minimal stand-in ONLY for local unit tests (never production validation)."""
    if set(document) != {"schemaVersion", "pack", "requiredLocalizationKeys", "localization", "lexicon", "grammar"}:
        raise ValueError("factory document has invalid root keys")
    if document["schemaVersion"] != 1 or document["pack"]["contractVersion"] != "1.0.0":
        raise ValueError("wrong factory version")
    for row in document["lexicon"]:
        if not set(row) == {"id", "surface", "partOfSpeech", "direction", "fields"}:
            raise ValueError("bad lexicon entry")
        if row["fields"]["canonical"]["cefr"] not in ("A1", "A2"):
            raise ValueError("bad CEFR")
    return document


class CanonicalIngestionTests(unittest.TestCase):
    def test_editorial_starters_cover_five_languages_and_both_levels(self):
        for language in subject.LANGUAGES:
            rows = subject.starter_records(language)
            self.assertEqual(len(rows), 12)
            self.assertEqual({r["cefr"] for r in rows}, {"A1", "A2"})
            document = subject.make_document(language, rows)
            self.assertEqual(len(strict_factory_shape(document)["lexicon"]), 12)
            self.assertEqual(document["pack"]["textDirection"], "rtl" if language == "ar" else "ltr")
            self.assertEqual(document["grammar"], [])

    def test_unattributed_input_is_not_mislabeled_as_editorial(self):
        record = subject.starter_records("en")[0]
        del record["sourceRef"]
        del record["license"]
        fields = subject.make_document("en", [record])["lexicon"][0]["fields"]
        self.assertEqual(fields["provenance"]["cefrStatus"], "unverified")
        self.assertEqual(fields["provenance"]["sourceRef"], "unspecified-source")

    def test_unicode_format_controls_rejected(self):
        record = subject.starter_records("ar")[0]
        record["surface"] += "\u200f"
        with self.assertRaisesRegex(ValueError, "control"):
            subject.make_document("ar", [record])

    def test_noncanonical_record_rejected(self):
        row = subject.starter_records("en")[0]
        for field in ("definitions", "translations", "examples", "cefr", "languageCode"):
            with self.subTest(field=field):
                broken = copy.deepcopy(row)
                del broken[field]
                with self.assertRaises(ValueError):
                    subject.make_document("en", [broken])

    def test_mixed_direction_and_unreviewed_placeholder_rejected(self):
        row = subject.starter_records("ar")[0]
        row["surface"] = "hello"
        with self.assertRaisesRegex(ValueError, "direction|expected"):
            subject.make_document("ar", [row])
        row = subject.starter_records("en")[0]
        row["definitions"][0]["text"] = "TRANSLATE_ME"
        with self.assertRaisesRegex(ValueError, "fallback"):
            subject.make_document("en", [row])

    def test_write_validate_roundtrip_idempotent_and_no_accidental_overwrite(self):
        calls = []
        def validator(doc):
            calls.append(doc["pack"]["languageCode"])
            return strict_factory_shape(doc)
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            output = subject.build(["en", "ar"], [], root, validator=validator)
            self.assertEqual(calls, ["en", "en", "ar", "ar"])
            self.assertEqual(len(output), 2)
            for path, count, digest in output:
                self.assertTrue(path.exists())
                doc = json.loads(path.read_text(encoding="utf-8"))
                self.assertEqual(len(doc["lexicon"]), count)
                self.assertEqual(len(digest), 64)
            first = output[0][0]
            original = first.read_bytes()
            subject.build(["en", "ar"], [], root, validator=validator)
            self.assertEqual(first.read_bytes(), original)
            first.write_text("different", encoding="utf-8")
            with self.assertRaises(FileExistsError):
                subject.build(["en", "ar"], [], root, validator=validator)
            subject.build(["en", "ar"], [], root, validator=validator, force=True)
            self.assertEqual(first.read_bytes(), original)

    def test_validator_failure_leaves_no_partial_output(self):
        def validator(doc):
            if doc["pack"]["languageCode"] == "ar":
                raise ValueError("failed second language")
            return strict_factory_shape(doc)
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            with self.assertRaisesRegex(ValueError, "second language"):
                subject.build(["en", "ar"], [], root, validator=validator)
            self.assertFalse((root / "assets").exists())

    def test_read_external_jsonl_and_fail_closed_on_missing_language(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            data = root / "reviewed.jsonl"
            data.write_text(json.dumps(subject.starter_records("es")[0], ensure_ascii=False) + "\n", encoding="utf-8")
            self.assertEqual(len(subject.read_records(data)), 1)
            result = subject.build(["es"], [data], root, validator=strict_factory_shape)
            self.assertEqual(result[0][1], 1)
            with self.assertRaisesRegex(ValueError, "empty lexicon"):
                subject.build(["es", "fr"], [data], root, validator=strict_factory_shape)


if __name__ == "__main__":
    unittest.main()
