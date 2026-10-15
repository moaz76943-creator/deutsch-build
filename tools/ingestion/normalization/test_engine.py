import unittest
from engine import normalize_text, NormalizationResult

class TestNormalizationEngine(unittest.TestCase):
    def test_original_text_is_nfc(self):
        text = "A\u0308"
        res = normalize_text(text, "en")
        self.assertEqual(res.original_text, "Ä")

    def test_german_umlauts_and_sz(self):
        res = normalize_text("Straße Über", "de")
        self.assertEqual(res.original_text, "Straße Über")
        self.assertEqual(res.search_key, "strasse ueber")
        self.assertIn("de_umlaut_expansion", res.applied_rules)

    def test_arabic_normalization(self):
        res = normalize_text("الْأُمَّةُ", "ar")
        self.assertEqual(res.search_key, "الامه")
        self.assertIn("ar_orthography_normalization", res.applied_rules)

        res2 = normalize_text("مـرحـبـاً", "ar")
        self.assertEqual(res2.search_key, "مرحبا")

    def test_hebrew_niqqud(self):
        res = normalize_text("שָׁלוֹם", "he")
        self.assertEqual(res.search_key, "שלום")
        self.assertIn("strip_diacritics", res.applied_rules)

    def test_vietnamese_preservation(self):
        text = "Tiếng Việt"
        res = normalize_text(text, "vi")
        self.assertEqual(res.search_key, "tiếng việt")
        self.assertIn("preserve_diacritics", res.applied_rules)

    def test_cjk_preservation(self):
        text = "한국어"
        res = normalize_text(text, "ko")
        self.assertEqual(res.search_key, "한국어")
        self.assertIn("nfc_recomposition", res.applied_rules)

        text_zh = "中文，测试"
        res_zh = normalize_text(text_zh, "zh")
        self.assertEqual(res_zh.search_key, "中文测试")

    def test_mixed_rtl_ltr(self):
        text = "Hello مرحبا"
        res = normalize_text(text, "ar")
        self.assertEqual(res.search_key, "hello مرحبا")

    def test_excessive_input_size(self):
        with self.assertRaises(ValueError):
            normalize_text("A" * 40000, "en")

    def test_invalid_unicode(self):
        with self.assertRaises(ValueError):
            normalize_text("Hello \ud800 World", "en")

    def test_idempotent(self):
        text = "Mädchen"
        res1 = normalize_text(text, "de")
        res2 = normalize_text(res1.search_key, "de")
        self.assertEqual(res1.search_key, res2.search_key)

    def test_normalization_collisions(self):
        res1 = normalize_text("Maedchen", "de")
        res2 = normalize_text("Mädchen", "de")
        self.assertEqual(res1.search_key, res2.search_key)
        self.assertNotEqual(res1.original_text, res2.original_text)

if __name__ == '__main__':
    unittest.main()
