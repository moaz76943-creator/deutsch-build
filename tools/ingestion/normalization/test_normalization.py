<<<<<<< HEAD
import unittest
import unicodedata
from tools.ingestion.normalization.engine import NormalizationEngine, ScopeGuard, J002CompilerContract

class TestNormalizationEngine(unittest.TestCase):
    def setUp(self):
        self.engine = NormalizationEngine()

    def test_german_umlauts_and_sz(self):
        result = self.engine.normalize("äpfel", "de")
        self.assertEqual(result.search_key, "aepfel")
        self.assertEqual(result.original, "äpfel")

        result_sz = self.engine.normalize("Straße", "de")
        self.assertEqual(result_sz.search_key, "strasse")
        self.assertEqual(result_sz.original, "Straße")

    def test_arabic_normalization(self):
        # Tashkeel, Alef variants, Taa Marbouta, Yaa
        result = self.engine.normalize("أَحْمَدٌ", "ar")
        self.assertEqual(result.search_key, "احمد")

        result_marbouta = self.engine.normalize("مدرسة", "ar")
        self.assertEqual(result_marbouta.search_key, "مدرسه")

        result_yaa = self.engine.normalize("مستشفى", "ar")
        self.assertEqual(result_yaa.search_key, "مستشفي")

    def test_hebrew_niqqud(self):
        result = self.engine.normalize("שָׁלוֹם", "he")
        self.assertEqual(result.search_key, "שלום")

    def test_cjk_preservation(self):
        # Ensure characters aren't arbitrarily stripped
        result = self.engine.normalize("こんにちは", "ja")
        self.assertEqual(result.search_key, "こんにちは")

        result_zh = self.engine.normalize("你好，世界！", "zh")
        self.assertEqual(result_zh.search_key, "你好世界") # punctuation stripped

    def test_vietnamese_diacritics(self):
        # Should fold case, strip punctuation, but leave letters/marks intact by default
        result = self.engine.normalize("Tiếng Việt", "vi")
        self.assertEqual(result.search_key, "tiếng việt")

    def test_indic_preservation(self):
        result = self.engine.normalize("नमस्ते", "hi")
        self.assertEqual(result.search_key, "नमस्ते")

    def test_mixed_rtl_ltr(self):
        result = self.engine.normalize("English العربية", "ar")
        self.assertEqual(result.search_key, "english العربيه")

    def test_combining_marks(self):
        # Let's test a word that gets NFC normalized
        # e + combining acute accent
        text = "e\u0301"
        result = self.engine.normalize(text, "fr")
        self.assertEqual(result.original, "é") # NFC form
        self.assertEqual(result.search_key, "é")

    def test_idempotency(self):
        text = "Mädchen!"
        result1 = self.engine.normalize(text, "de")
        result2 = self.engine.normalize(result1.search_key, "de", fold_case=False, strip_punctuation=False)
        self.assertEqual(result1.search_key, result2.search_key)

    def test_normalization_collisions(self):
        # "Strasse" and "Straße" normalize to the same search key but keep different original lexical identities
        res1 = self.engine.normalize("Strasse", "de")
        res2 = self.engine.normalize("Straße", "de")

        self.assertEqual(res1.search_key, res2.search_key)
        self.assertNotEqual(res1.original, res2.original)

    def test_max_input_length(self):
        long_text = "a" * 10001
        with self.assertRaises(ValueError):
            self.engine.normalize(long_text, "en")

    def test_invalid_unicode(self):
        with self.assertRaises(ValueError):
            self.engine.normalize("\ud800", "en") # Surrogate character

if __name__ == '__main__':
=======
"""Regression tests for distinct original orthography and bounded search aliases."""
import unittest

from tools.ingestion.normalization.engine import NormalizationEngine


class NormalizationTests(unittest.TestCase):
    def setUp(self):
        self.engine = NormalizationEngine()

    def test_german_orthographic_collision_retains_identity(self):
        a = self.engine.normalize("Straße", "de")
        b = self.engine.normalize("Strasse", "de")
        self.assertEqual(a.search_key, b.search_key)
        self.assertNotEqual(a.original, b.original)
        self.assertEqual(self.engine.normalize("Mädchen", "de").search_key, "maedchen")

    def test_arabic_combining_marks_and_original(self):
        word = "أَحْمَدٌ"
        normalized = self.engine.normalize(word, "ar")
        self.assertEqual(normalized.original, word)
        self.assertEqual(normalized.search_key, "أحمد")
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
        self.assertEqual(self.engine.normalize("你好，世界！", "zh").search_key, "你好世界")

    def test_idempotent_search_key(self):
        first = self.engine.normalize("Mädchen!", "de")
        second = self.engine.normalize(first.search_key, "de")
        self.assertEqual(first.search_key, second.search_key)


if __name__ == "__main__":
>>>>>>> pr-179
    unittest.main()
