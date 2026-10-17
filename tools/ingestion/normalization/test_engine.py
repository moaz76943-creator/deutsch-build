import unittest
from tools.ingestion.normalization.engine import NormalizationEngine

class TestNormalizationEngine(unittest.TestCase):
    def setUp(self):
        self.engine = NormalizationEngine()

    def test_max_length(self):
        text = "a" * (NormalizationEngine.MAX_INPUT_LENGTH + 1)
        with self.assertRaises(ValueError):
            self.engine.normalize(text, "en")

    def test_german(self):
        result = self.engine.normalize("über die Straße", "de")
        self.assertEqual(result.search_key, "ueber die strasse")
        self.assertEqual(result.original_text, "über die Straße")

    def test_arabic(self):
        # Arabic text with tatweel, diacritics, alefs
        # أهـلاً -> اھلا  (with normalization)
        text = "أَهْلاً بِكُمْ"
        result = self.engine.normalize(text, "ar")
        # Removing diacritics
        # أ (Alef with hamza above) -> ا
        # ه -> ه
        # ل -> ل
        # ا -> ا
        # ب -> ب
        # ك -> ك
        # م -> م
        self.assertEqual(result.search_key, "اهلا بكم")

    def test_hebrew(self):
        text = "שָׁלוֹם"
        result = self.engine.normalize(text, "he")
        self.assertEqual(result.search_key, "שלום")

    def test_cjk(self):
        text = "こんにちは"
        result = self.engine.normalize(text, "ja")
        self.assertEqual(result.search_key, "こんにちは")

    def test_idempotent(self):
        text = "über die Straße"
        res1 = self.engine.normalize(text, "de")
        res2 = self.engine.normalize(res1.search_key, "de")
        self.assertEqual(res1.search_key, res2.search_key)

    def test_case_and_punctuation(self):
        text = "Hello, World!  "
        result = self.engine.normalize(text, "en")
        self.assertEqual(result.search_key, "hello world")

    def test_combining_marks_hindi(self):
        text = "हिंदी"
        result = self.engine.normalize(text, "hi")
        # Ensure the combining marks (M) are not stripped
        self.assertEqual(result.search_key, "हिंदी")

    def test_mixed_rtl_ltr(self):
        text = "English و عربي"
        result = self.engine.normalize(text, "ar")
        # Ensure directionality is handled without loss
        self.assertEqual(result.search_key, "english و عربي")

    def test_normalization_collisions(self):
        text1 = "cafe"
        text2 = "café"
        res1 = self.engine.normalize(text1, "en")
        res2 = self.engine.normalize(text2, "en")
        self.assertNotEqual(res1.search_key, res2.search_key) # They are different words lexically

if __name__ == '__main__':
    unittest.main()
