"""Regression tests for distinct original orthography and bounded search aliases."""
import unittest

from tools.ingestion.normalization.engine import NormalizationEngine


class NormalizationTests(unittest.TestCase):
    def setUp(self):
        self.engine = NormalizationEngine()

    def test_german_orthographic_collision_retains_identity(self):
        a = self.engine.normalize("Straße", "de")
        b = self.engine.normalize("Strasse", "de")
        self.assertNotEqual(a.search_key, b.search_key)
        self.assertNotEqual(a.original, b.original)
        self.assertEqual(self.engine.normalize("Mädchen", "de").search_key, "mädchen")

    def test_arabic_combining_marks_and_original(self):
        word = "أَحْمَدٌ"
        normalized = self.engine.normalize(word, "ar")
        self.assertEqual(normalized.original, word)
        self.assertEqual(normalized.search_key, "احمد")
        self.assertEqual(self.engine.normalize("مُعَلِّم", "ar").search_key, "معلم")

    def test_hebrew_mark_stripping_is_language_scoped(self):
        self.assertEqual(self.engine.normalize("שָׁלוֹם", "he").search_key, "שלום")
        self.assertNotEqual(self.engine.normalize("שָׁלוֹם", "en").search_key, "שלום")

    def test_indic_and_cjk_marks_survive(self):
        for language, word in [
            ("hi", "नमस्ते"), ("bn", "বাংলা"), ("ta", "தமிழ்"),
            ("zh", "你好"), ("ja", "こんにちは"), ("ko", "한국어")
        ]:
            with self.subTest(language=language):
                r = self.engine.normalize(word, language)
                self.assertEqual(r.original, word)
                self.assertEqual(r.search_key, word)

    def test_decomposed_unicode_keeps_exact_original(self):
        text = "e\u0301"
        r = self.engine.normalize(text, "fr")
        self.assertEqual(r.original, text)
        self.assertEqual(r.search_key, "é")
        self.assertIn("NFC_SEARCH", r.applied_rules)

    def test_english_arabic_mixed_direction_without_control_reordering(self):
        original = "English العربية 123"
        r = self.engine.normalize(original, "ar")
        self.assertEqual(r.original, original)
        self.assertEqual(r.search_key, "english العربية 123")

    def test_missing_language_and_unicode_controls_fail_closed(self):
        for tag in ("", "??", "de__ar"):
            with self.assertRaises(ValueError):
                self.engine.normalize("x", tag)
        for value in ("x\ud800", "\u202etest", "a\u2067b\u2069", "x" * 10001):
            with self.assertRaises(ValueError):
                self.engine.normalize(value, "de")

    def test_optional_punctuation_and_case(self):
        r = self.engine.normalize("A،B!", "en", fold_case=False, strip_punctuation=False)
        self.assertEqual(r.search_key, "A،B!")
        self.assertEqual(self.engine.normalize("你好，世界！", "zh", strip_punctuation=True).search_key, "你好世界")

    def test_idempotent_search_key(self):
        first = self.engine.normalize("Mädchen!", "de")
        second = self.engine.normalize(first.search_key, "de")
        self.assertEqual(first.search_key, second.search_key)


if __name__ == "__main__":
    unittest.main()
