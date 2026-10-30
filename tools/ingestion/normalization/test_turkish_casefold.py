"""Directed search aliases preserve the locale's contrastive dotted/dotless I."""
import unittest
from tools.ingestion.normalization.engine import NormalizationEngine


class TurkishCaseFoldTests(unittest.TestCase):
    def setUp(self):
        self.engine = NormalizationEngine()

    def test_turkish_and_azeri_dotted_dotless_pairs(self):
        for locale in ("tr", "az", "tr-TR", "az-Latn"):
            with self.subTest(locale=locale):
                self.assertEqual(
                    self.engine.normalize("I İ ı i", locale).search_key,
                    "ı i ı i",
                )

    def test_linguistic_differences_survive(self):
        self.assertNotEqual(
            self.engine.normalize("I", "tr").search_key,
            self.engine.normalize("İ", "tr").search_key,
        )

    def test_original_and_language_identity_are_untouched(self):
        text = "I İ e\u0301"
        result = self.engine.normalize(text, "tr-TR")
        self.assertEqual(result.original, text)
        self.assertEqual(result.language_code, "tr-TR")

    def test_disabled_case_fold_preserves_case(self):
        self.assertEqual(
            self.engine.normalize("I İ", "tr", fold_case=False).search_key,
            "I İ",
        )

    def test_other_languages_retain_canonical_behavior(self):
        self.assertEqual(self.engine.normalize("I", "en").search_key, "i")
        self.assertEqual(
            self.engine.normalize("Mädchen", "de").search_key,
            "mädchen",
        )
        self.assertEqual(self.engine.normalize("café", "fr").search_key, "café")

    def test_idempotent_search_alias(self):
        key = self.engine.normalize("IĞDIR İZMİR", "tr").search_key
        self.assertEqual(key, "ığdır izmir")
        self.assertEqual(self.engine.normalize(key, "tr").search_key, key)


if __name__ == "__main__":
    unittest.main()
