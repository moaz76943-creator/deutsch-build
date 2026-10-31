"""Focused offline regression tests for nominal case morphology."""

import copy
import json
import sqlite3
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from build_universal_declensions import (  # noqa: E402
    ValidationError,
    build_database,
    verify_database,
    verify_declension_index,
    verify_orphan_declensions,
)


class UniversalDeclensionsTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.source = self.root / "nominals.json"
        self.output = self.root / "nominals.sqlite"
        self.sample = {
            "nominals": [
                {
                    "id": "de:Haus", "lemma": "Haus", "part_of_speech": "noun",
                    "gender": "neuter", "number": "singular",
                    "declensions": [
                        {"id": "de:Haus:nom:sg", "grammatical_case": "Nominative", "number": "singular", "definiteness": "definite", "inflected_form": "das Haus"},
                        {"id": "de:Haus:gen:sg", "grammatical_case": "Genitive", "number": "singular", "definiteness": "definite", "inflected_form": "des Hauses"},
                    ],
                },
                {
                    "id": "ar:كتاب", "lemma": "كتاب", "part_of_speech": "noun",
                    "gender": "masculine", "number": "singular",
                    "declensions": [
                        {"id": "ar:كتاب:acc:sg", "grammatical_case": "Accusative", "number": "singular", "definiteness": "indefinite", "inflected_form": "كتابًا"},
                    ],
                },
            ]
        }

    def write(self, value=None):
        self.source.write_text(json.dumps(self.sample if value is None else value, ensure_ascii=False), encoding="utf-8")

    def test_nested_data_round_trip_and_index(self):
        self.write()
        self.assertEqual(build_database(self.source, self.output, batch_size=1), (2, 3))
        with sqlite3.connect(self.output) as db:
            self.assertEqual(db.execute("SELECT lemma, part_of_speech, gender, number FROM nominals WHERE id=?", ("ar:كتاب",)).fetchone(), ("كتاب", "noun", "masculine", "singular"))
            self.assertEqual(db.execute("SELECT grammatical_case,inflected_form FROM nominal_declensions WHERE id=?", ("de:Haus:gen:sg",)).fetchone(), ("genitive", "des Hauses"))
            verify_database(db)
            self.assertEqual(db.execute("PRAGMA foreign_key_check").fetchall(), [])
            self.assertEqual(db.execute("PRAGMA integrity_check").fetchone(), ("ok",))

    def test_flat_data_and_seven_declension_cases(self):
        cases = ["Nominative", "Accusative", "Dative", "Genitive", "Instrumental", "Locative", "Prepositional"]
        payload = {
            "nominals": [
                {"id": "ru:стол", "lemma": "стол", "part_of_speech": "noun", "gender": "masculine", "number": "singular"},
                {"id": "fi:talo", "lemma": "talo", "part_of_speech": "noun", "gender": "none", "number": "singular"},
                {"id": "hu:ház", "lemma": "ház", "part_of_speech": "noun", "gender": "none", "number": "singular"},
            ],
            "nominal_declensions": [
                {"id": f"ru:стол:{i}", "nominal_id": "ru:стол", "grammatical_case": case, "number": "singular", "definiteness": "none", "inflected_form": "стол"}
                for i, case in enumerate(cases)
            ] + [
                {"id": "fi:talo:inessive", "nominal_id": "fi:talo", "grammatical_case": "inessive", "number": "singular", "definiteness": "none", "inflected_form": "talossa"},
                {"id": "hu:ház:inessive", "nominal_id": "hu:ház", "grammatical_case": "inessive", "number": "singular", "definiteness": "none", "inflected_form": "házban"},
            ],
        }
        self.write(payload)
        self.assertEqual(build_database(self.source, self.output, batch_size=3), (3, 9))
        with sqlite3.connect(self.output) as db:
            self.assertEqual({r[0] for r in db.execute("SELECT DISTINCT grammatical_case FROM nominal_declensions")}, {c.lower() for c in cases} | {"inessive"})
            self.assertEqual(db.execute("SELECT count(*) FROM nominal_declensions WHERE grammatical_case='inessive'").fetchone()[0], 2)

    def test_supports_noun_adjective_pronoun_and_dual(self):
        payload = {"nominals": [
            {"id": "ar:هما", "lemma": "هما", "part_of_speech": "pronoun", "gender": "none", "number": "dual", "declensions": [
                {"id": "ar:هما:nom", "grammatical_case": "nominative", "number": "dual", "definiteness": "definite", "inflected_form": "هما"}]},
            {"id": "de:klein", "lemma": "klein", "part_of_speech": "adjective", "gender": "none", "number": "none"},
        ]}
        self.write(payload)
        self.assertEqual(build_database(self.source, self.output), (2, 1))

    def test_missing_fields_and_invalid_parts_of_speech_fail_closed(self):
        for key in ("id", "lemma", "part_of_speech", "gender", "number"):
            with self.subTest(nominal_field=key):
                v = copy.deepcopy(self.sample)
                del v["nominals"][0][key]
                self.write(v)
                with self.assertRaises(ValidationError):
                    build_database(self.source, self.output)
                self.assertFalse(self.output.exists())
        for key in ("id", "grammatical_case", "number", "definiteness", "inflected_form"):
            with self.subTest(form_field=key):
                v = copy.deepcopy(self.sample)
                del v["nominals"][0]["declensions"][0][key]
                self.write(v)
                with self.assertRaises(ValidationError):
                    build_database(self.source, self.output)
                self.assertFalse(self.output.exists())
        v = copy.deepcopy(self.sample)
        v["nominals"][0]["part_of_speech"] = "verb"
        self.write(v)
        with self.assertRaises(ValidationError):
            build_database(self.source, self.output)

    def test_duplicate_and_orphan_forms_fail_without_output(self):
        v = copy.deepcopy(self.sample)
        v["nominals"][0]["declensions"].append(v["nominals"][0]["declensions"][0])
        self.write(v)
        with self.assertRaises((ValidationError, sqlite3.IntegrityError)):
            build_database(self.source, self.output)
        self.assertFalse(self.output.exists())
        v = {"nominals": [], "nominal_declensions": [{"id": "x", "nominal_id": "missing", "grammatical_case": "dative", "number": "singular", "definiteness": "none", "inflected_form": "X"}]}
        self.write(v)
        with self.assertRaises((ValidationError, sqlite3.IntegrityError)):
            build_database(self.source, self.output)
        self.assertFalse(self.output.exists())
        self.assertEqual(sorted(p.name for p in self.root.iterdir()), ["nominals.json"])

    def test_nested_flat_mixing_and_parent_mismatch_rejected(self):
        v = copy.deepcopy(self.sample)
        v["nominal_declensions"] = []
        self.write(v)
        with self.assertRaises(ValidationError):
            build_database(self.source, self.output)
        v = copy.deepcopy(self.sample)
        v["nominals"][0]["declensions"][0]["nominal_id"] = "ar:كتاب"
        self.write(v)
        with self.assertRaises(ValidationError):
            build_database(self.source, self.output)

    def test_no_overwrite_or_input_output_overlap(self):
        self.write()
        self.output.write_bytes(b"ORIGINAL")
        with self.assertRaises(FileExistsError):
            build_database(self.source, self.output)
        self.assertEqual(self.output.read_bytes(), b"ORIGINAL")
        with self.assertRaises(ValueError):
            build_database(self.source, self.source, overwrite=True)
        self.assertEqual(self.output.read_bytes(), b"ORIGINAL")

    def test_overwrite_replaces_only_on_success(self):
        self.write()
        self.output.write_bytes(b"ORIGINAL")
        self.assertEqual(build_database(self.source, self.output, overwrite=True), (2, 3))
        snapshot = self.output.read_bytes()
        v = copy.deepcopy(self.sample)
        v["nominals"][0]["declensions"][0]["inflected_form"] = ""
        self.write(v)
        with self.assertRaises(ValidationError):
            build_database(self.source, self.output, overwrite=True)
        self.assertEqual(self.output.read_bytes(), snapshot)

    def test_integrity_verification_rejects_orphans_and_dropped_index(self):
        self.write()
        build_database(self.source, self.output)
        with sqlite3.connect(self.output) as db:
            db.execute("PRAGMA foreign_keys=OFF")
            db.execute("INSERT INTO nominal_declensions VALUES (?, ?, ?, ?, ?, ?)", ("bad", "absent", "dative", "singular", "none", "bad"))
            with self.assertRaises(ValidationError):
                verify_orphan_declensions(db)
        with sqlite3.connect(self.output) as db:
            db.execute("DELETE FROM nominal_declensions WHERE id='bad'")
            db.execute("DROP INDEX idx_nominal_declensions_nominal_case_number")
            with self.assertRaises(ValidationError):
                verify_declension_index(db)

    def test_explicit_null_flat_forms_rejected(self):
        self.write({"nominals": self.sample["nominals"], "nominal_declensions": None})
        with self.assertRaises(ValidationError):
            build_database(self.source, self.output)
        self.assertFalse(self.output.exists())

    def test_atomic_batch_rolls_back_after_previous_batch(self):
        value = copy.deepcopy(self.sample)
        value["nominals"][1]["declensions"][0]["id"] = "de:Haus:nom:sg"
        self.write(value)
        with self.assertRaises(sqlite3.IntegrityError):
            build_database(self.source, self.output, batch_size=1)
        self.assertFalse(self.output.exists())
        self.assertEqual(sorted(p.name for p in self.root.iterdir()), ["nominals.json"])

    def test_empty_and_invalid_batch_rejected(self):
        self.write({"nominals": []})
        with self.assertRaises(ValidationError):
            build_database(self.source, self.output)
        self.write()
        for bad in (0, -1, True, 1.2):
            with self.subTest(batch=bad):
                with self.assertRaises(ValueError):
                    build_database(self.source, self.output, batch_size=bad)


if __name__ == "__main__":
    unittest.main()
