"""Standard-library tests for deterministic SQLite BINARY sort keys."""
from __future__ import annotations

import sqlite3
import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from sort_key_generator import generate_sort_key, generate_sort_keys


class LocalizedSortKeyTests(unittest.TestCase):
    def assert_order(self, words: list[str], language: str, expected: list[str]) -> None:
        self.assertEqual(sorted(words, key=lambda word: generate_sort_key(word, language)), expected)

    def test_german_umlauts_expand_in_dictionary_style(self) -> None:
        self.assert_order(
            ["Bär", "Ähre", "Zebra", "Affe", "Adler", "Auge"], "de-DE",
            ["Adler", "Ähre", "Affe", "Auge", "Bär", "Zebra"],
        )
        self.assertEqual(generate_sort_key("Äpfel", "de"), generate_sort_key("Aepfel", "de"))
        self.assertEqual(generate_sort_key("Öl", "de"), generate_sort_key("Oel", "de"))
        self.assertEqual(generate_sort_key("MÜLLER", "de"), generate_sort_key("Mueller", "de"))
        self.assertEqual(generate_sort_key("Straße", "de"), generate_sort_key("STRASSE", "de"))
        self.assertEqual(generate_sort_key("a\u0308pfel", "de"), generate_sort_key("Äpfel", "de"))

    def test_swedish_three_final_letters_are_not_ascii_folded(self) -> None:
        self.assert_order(
            ["Örebro", "äpple", "zebra", "Åbo", "yxa", "öga", "älg"], "sv-SE",
            ["yxa", "zebra", "Åbo", "älg", "äpple", "öga", "Örebro"],
        )
        self.assertNotEqual(generate_sort_key("Å", "sv"), generate_sort_key("A", "sv"))
        self.assertEqual(generate_sort_key("a\u030a", "sv"), generate_sort_key("Å", "sv"))

    def test_arabic_harakat_tatweel_and_alef_variants(self) -> None:
        self.assertEqual(generate_sort_key("إِبْرَاهِيم", "ar-SA"), generate_sort_key("ابراهيم", "ar"))
        self.assertEqual(generate_sort_key("آمَال", "ar"), generate_sort_key("امال", "ar"))
        self.assertEqual(generate_sort_key("أَمَل", "ar"), generate_sort_key("ا\u0654مل", "ar"))
        self.assertEqual(generate_sort_key("كـتاب", "ar"), generate_sort_key("كتاب", "ar"))
        self.assert_order(["ثوب", "تفاح", "باب", "أسد"], "ar", ["أسد", "باب", "تفاح", "ثوب"])

    def test_russian_yo_and_short_i_keep_distinct_alphabet_positions(self) -> None:
        self.assert_order(
            ["Яма", "Йога", "Ёж", "Жук", "Ель", "Кит", "Ива"], "ru-RU",
            ["Ель", "Ёж", "Жук", "Ива", "Йога", "Кит", "Яма"],
        )
        self.assertNotEqual(generate_sort_key("еж", "ru"), generate_sort_key("ёж", "ru"))
        self.assertNotEqual(generate_sort_key("и", "ru"), generate_sort_key("й", "ru"))
        self.assertEqual(generate_sort_key("Е\u0301ль", "ru"), generate_sort_key("ель", "ru"))

    def test_greek_tonos_final_sigma_and_devanagari_alphabet(self) -> None:
        self.assert_order(["γάμμα", "Άλφα", "βήτα"], "el-GR", ["Άλφα", "βήτα", "γάμμα"])
        self.assertEqual(generate_sort_key("Όρος", "el"), generate_sort_key("οροσ", "el"))
        self.assertEqual(generate_sort_key("κόσμος", "el"), generate_sort_key("κοσμοσ", "el"))
        self.assert_order(["ग", "आ", "ख", "अ", "क", "इ"], "hi-IN", ["अ", "आ", "इ", "क", "ख", "ग"])
        self.assertEqual(generate_sort_key("क़", "hi"), generate_sort_key("क\u093c", "hi"))
        self.assertNotEqual(generate_sort_key("का", "hi"), generate_sort_key("कि", "hi"))

    def test_other_locales_fallback_is_deterministic_not_system_locale_based(self) -> None:
        self.assertEqual(generate_sort_key("CAFÉ", "fr-FR"), generate_sort_key("cafe\u0301", "fr"))
        self.assertEqual(generate_sort_key("casa", "en_US"), generate_sort_key("CASA", "en"))
        self.assertEqual(generate_sort_key("", "ja"), "")
        self.assertEqual(generate_sort_key("中文", "zh"), generate_sort_key("中文", "zh-CN"))
        self.assert_order(["nube", "ñandú", "oso"], "es", ["nube", "ñandú", "oso"])
        self.assert_order(["ızgara", "ışık", "inek"], "tr", ["ışık", "ızgara", "inek"])

    def test_sqlite_binary_order_and_prefixes(self) -> None:
        words = ["Zebra", "öga", "Älg", "Åbo", "ab", "aba", "a"]
        with sqlite3.connect(":memory:") as db:
            db.execute("CREATE TABLE lexicon (word TEXT, sort_key TEXT NOT NULL)")
            db.executemany("INSERT INTO lexicon VALUES (?, ?)",
                           [(word, generate_sort_key(word, "sv")) for word in words])
            actual = [row[0] for row in db.execute("SELECT word FROM lexicon ORDER BY sort_key COLLATE BINARY")]
        self.assertEqual(actual, ["a", "ab", "aba", "Zebra", "Åbo", "Älg", "öga"])

    def test_lazy_batch_processing_preserves_input_order(self) -> None:
        entries = ((word, lang) for word, lang in [
            ("Äpfel", "de"), ("Örebro", "sv"), ("الكتاب", "ar")
        ])
        iterator = generate_sort_keys(entries)
        self.assertEqual(
            list(iterator),
            [generate_sort_key("Äpfel", "de"),
             generate_sort_key("Örebro", "sv"),
             generate_sort_key("الكتاب", "ar")],
        )

    def test_invalid_arguments(self) -> None:
        with self.assertRaises(TypeError):
            generate_sort_key(None, "de")  # type: ignore[arg-type]
        with self.assertRaises(ValueError):
            generate_sort_key("abc", "")
        with self.assertRaises(TypeError):
            generate_sort_key("abc", None)  # type: ignore[arg-type]


if __name__ == "__main__":
    unittest.main()
