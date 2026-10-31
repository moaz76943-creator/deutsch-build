import importlib.util
import json
from pathlib import Path
import tempfile
import unittest

MODULE_PATH = Path(__file__).resolve().parents[1] / "tools" / "generate_phonetics_map.py"
spec = importlib.util.spec_from_file_location("generate_phonetics_map", MODULE_PATH)
phonetics = importlib.util.module_from_spec(spec)
spec.loader.exec_module(phonetics)


class GeneratePhoneticsMapTest(unittest.TestCase):
    def test_seed_covers_a1_a2_and_requested_difficult_graphemes(self):
        payload = phonetics.build_phonetics_map()

        levels = {entry["cefr"] for entry in payload["entries"].values()}
        graphemes = {
            highlight["grapheme"].casefold()
            for entry in payload["entries"].values()
            for highlight in entry["highlights"]
        }

        self.assertTrue({"A1", "A2"}.issubset(levels))
        self.assertTrue({"ch", "sch", "eu", "äu", "st", "sp"}.issubset(graphemes))

    def test_highlight_offsets_match_the_original_word(self):
        payload = phonetics.build_phonetics_map()

        for word, entry in payload["entries"].items():
            for highlight in entry["highlights"]:
                actual = word[highlight["start"]:highlight["end"]]
                self.assertEqual(actual.casefold(), highlight["grapheme"].casefold())

    def test_ch_rules_distinguish_ich_laut_and_ach_laut(self):
        payload = phonetics.build_phonetics_map()

        self.assertEqual(payload["rules"]["de.ch.ich"]["ipa"], "/ç/")
        self.assertEqual(payload["rules"]["de.ch.ach"]["ipa"], "/x/")
        self.assertEqual(payload["entries"]["ich"]["ipa"], "/ɪç/")
        self.assertEqual(payload["entries"]["Buch"]["ipa"], "/buːx/")

    def test_rejects_duplicate_words_case_insensitively(self):
        duplicate = list(phonetics.SEED_ENTRIES) + [
            phonetics.PhoneticEntry(
                word="ICH",
                cefr="A1",
                ipa="/ɪç/",
                highlights=(
                    phonetics.Highlight(1, 3, "ch", "de.ch.ich"),
                ),
            )
        ]

        with self.assertRaisesRegex(phonetics.PhoneticsMapError, "Duplicate word"):
            phonetics.build_phonetics_map(duplicate)

    def test_rejects_invalid_ipa_before_writing(self):
        invalid = [
            phonetics.PhoneticEntry(
                word="Test",
                cefr="A1",
                ipa="tɛst",
                highlights=(),
            )
        ]

        with self.assertRaisesRegex(phonetics.PhoneticsMapError, "IPA"):
            phonetics.build_phonetics_map(invalid)

    def test_generate_writes_deterministic_utf8_json(self):
        with tempfile.TemporaryDirectory() as tmp:
            output = Path(tmp) / "phonetics.json"

            first = phonetics.generate_phonetics_map(output)
            first_text = output.read_text(encoding="utf-8")
            second = phonetics.generate_phonetics_map(output)
            second_text = output.read_text(encoding="utf-8")

            self.assertEqual(first, output)
            self.assertEqual(second, output)
            self.assertEqual(first_text, second_text)
            payload = json.loads(first_text)
            self.assertEqual(payload["language"], "de")
            self.assertEqual(payload["playbackLocale"], "de-DE")
            self.assertEqual(payload["entries"]["heute"]["ttsText"], "heute")


if __name__ == "__main__":
    unittest.main()
