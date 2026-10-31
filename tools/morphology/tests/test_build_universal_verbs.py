"""Focused regression tests for the standalone morphology pack builder."""

import json
import sqlite3
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from build_universal_verbs import (  # noqa: E402
    ValidationError,
    build_database,
    verify_conjugation_index,
    verify_orphan_forms,
)


class BuildUniversalVerbsTests(unittest.TestCase):
    def setUp(self):
        self.tempdir = tempfile.TemporaryDirectory()
        self.addCleanup(self.tempdir.cleanup)
        self.root = Path(self.tempdir.name)
        self.source = self.root / "verbs.json"
        self.output = self.root / "verbs.sqlite"
        self.sample = {
            "verbs": [
                {
                    "verb_id": "de:gehen",
                    "infinitive": "gehen",
                    "translation_ar": "يذهب",
                    "frequency_rank": 5,
                    "conjugations": [
                        {
                            "conjugation_id": "de:gehen:present:ich",
                            "tense": "present",
                            "person": "ich",
                            "conjugated_form": "gehe",
                        },
                        {
                            "conjugation_id": "de:gehen:present:du",
                            "tense": "present",
                            "person": "du",
                            "conjugated_form": "gehst",
                        },
                    ],
                }
            ]
        }

    def write_input(self, data):
        self.source.write_text(json.dumps(data, ensure_ascii=False), encoding="utf-8")

    def test_build_nested_forms_and_composite_index(self):
        self.write_input(self.sample)
        counts = build_database(self.source, self.output)
        self.assertEqual(counts, (1, 2))
        with sqlite3.connect(self.output) as db:
            self.assertEqual(db.execute("SELECT infinitive, translation_ar, frequency_rank FROM verbs").fetchone(), ("gehen", "يذهب", 5))
            self.assertEqual(db.execute("SELECT conjugated_form FROM verb_conjugations WHERE person = 'du'").fetchone()[0], "gehst")
            verify_orphan_forms(db)
            verify_conjugation_index(db)
            self.assertEqual([c[2] for c in db.execute("PRAGMA table_info(verb_conjugations)")][:3], ["TEXT", "TEXT", "TEXT"])

    def test_flat_json_forms(self):
        flat = {"verbs": [{"verb_id": "fr:aller", "infinitive": "aller"}], "verb_conjugations": [
            {"conjugation_id": "fr:aller:present:je", "verb_id": "fr:aller", "tense": "present", "person": "je", "conjugated_form": "vais"}
        ]}
        self.write_input(flat)
        self.assertEqual(build_database(self.source, self.output), (1, 1))

    def test_orphan_rejected_without_output_or_temp_files(self):
        flat = {"verbs": [], "verb_conjugations": [{"conjugation_id": "missing:1", "verb_id": "missing", "tense": "past", "person": "1sg", "conjugated_form": "x"}]}
        self.write_input(flat)
        with self.assertRaises((ValidationError, sqlite3.IntegrityError)):
            build_database(self.source, self.output)
        self.assertFalse(self.output.exists())
        self.assertEqual(sorted(p.name for p in self.root.iterdir()), ["verbs.json"])

    def test_duplicate_conjugation_id_fails_closed(self):
        self.sample["verbs"][0]["conjugations"].append(dict(self.sample["verbs"][0]["conjugations"][0]))
        self.write_input(self.sample)
        with self.assertRaises((ValidationError, sqlite3.IntegrityError)):
            build_database(self.source, self.output)
        self.assertFalse(self.output.exists())

    def test_missing_required_field_rejected(self):
        del self.sample["verbs"][0]["conjugations"][0]["tense"]
        self.write_input(self.sample)
        with self.assertRaises(ValidationError):
            build_database(self.source, self.output)

    def test_no_overwrite_by_default(self):
        self.write_input(self.sample)
        self.output.write_bytes(b"EXISTING")
        with self.assertRaises(FileExistsError):
            build_database(self.source, self.output)
        self.assertEqual(self.output.read_bytes(), b"EXISTING")

    def test_explicit_overwrite_replaces_db(self):
        self.write_input(self.sample)
        self.output.write_bytes(b"EXISTING")
        self.assertEqual(build_database(self.source, self.output, overwrite=True), (1, 2))
        with sqlite3.connect(self.output) as db:
            self.assertEqual(db.execute("SELECT count(*) FROM verbs").fetchone()[0], 1)

    def test_verifier_finds_orphan_even_with_foreign_keys_disabled(self):
        self.write_input(self.sample)
        build_database(self.source, self.output)
        with sqlite3.connect(self.output) as db:
            db.execute("PRAGMA foreign_keys = OFF")
            db.execute("INSERT INTO verb_conjugations VALUES (?, ?, ?, ?, ?)", ("bad", "absent", "present", "1sg", "bad"))
            with self.assertRaises(ValidationError):
                verify_orphan_forms(db)

    def test_verifier_requires_composite_index(self):
        self.write_input(self.sample)
        build_database(self.source, self.output)
        with sqlite3.connect(self.output) as db:
            db.execute("DROP INDEX idx_verb_conjugations_verb_tense")
            with self.assertRaises(ValidationError):
                verify_conjugation_index(db)

    def test_nested_form_with_mismatched_verb_id_rejected(self):
        self.sample["verbs"][0]["conjugations"][0]["verb_id"] = "fr:aller"
        self.write_input(self.sample)
        with self.assertRaises(ValidationError):
            build_database(self.source, self.output)

    def test_invalid_frequency_rank_rejected(self):
        self.sample["verbs"][0]["frequency_rank"] = True
        self.write_input(self.sample)
        with self.assertRaises(ValidationError):
            build_database(self.source, self.output)


if __name__ == "__main__":
    unittest.main()
