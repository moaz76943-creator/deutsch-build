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
    unittest.main()
