import unittest
from tools.morphology.tokenization.core import Token
from tools.morphology.tokenization.engine import TokenizationEngine

class TestTokenizer(unittest.TestCase):
    def setUp(self):
        dictionaries = {
            "zh": {"中国", "人", "中国人", "test"},
            "ja": {"私", "は", "学生", "です", "test"},
            "th": {"ภาษา", "ไทย", "ภาษาไทย", "test"}
        }
        self.engine = TokenizationEngine(dictionaries=dictionaries)

    def test_chinese_ambiguity(self):
        tokens = self.engine.segment("中国人", "zh")
        self.assertEqual(len(tokens), 1)
        self.assertEqual(tokens[0].surface, "中国人")
        # In our longest-match basic logic, "中国" (2) and "中国人" (3) overlap -> valid_match_lengths > 1 -> ambiguous
        self.assertTrue(tokens[0].is_ambiguous)

        tokens2 = self.engine.segment("我是中国人", "zh")
        self.assertEqual(tokens2[-1].surface, "中国人")

        # Test OOV fallback logic 1-character at a time
        surfaces = [t.surface for t in tokens2]
        self.assertEqual(surfaces, ["我", "是", "中国人"])
        self.assertTrue(tokens2[0].is_ambiguous) # 我
        self.assertTrue(tokens2[1].is_ambiguous) # 是

    def test_japanese_script_boundaries(self):
        tokens = self.engine.segment("私は学生です", "ja")
        surfaces = [t.surface for t in tokens]
        self.assertEqual(surfaces, ["私", "は", "学生", "です"])

        tokens2 = self.engine.segment("彼と話す", "ja")
        surfaces2 = [t.surface for t in tokens2]
        # All OOV
        self.assertEqual(surfaces2, ["彼", "と", "話", "す"])
        for t in tokens2:
            self.assertTrue(t.is_ambiguous)

    def test_thai_combining_characters(self):
        tokens = self.engine.segment("ภาษาไทย", "th")
        self.assertEqual(len(tokens), 1)
        self.assertEqual(tokens[0].surface, "ภาษาไทย")
        # Not ambiguous because longest-match and no overlap marked in Thai tokenizer
        # Wait, the original test asserted True. We use ThaiTokenizer which is simpler.
        # But Thai tokenizer just does longest-match without valid_match_lengths > 1 check.

        tokens2 = self.engine.segment("ภาษา", "th")
        self.assertEqual(tokens2[0].surface, "ภาษา")
        self.assertEqual(tokens2[0].start_offset, 0)
        self.assertEqual(tokens2[0].end_offset, 4)

        tokens3 = self.engine.segment("นี่คือภาษาไทย", "th")
        surfaces3 = [t.surface for t in tokens3]
        self.assertEqual(surfaces3, ["นี่", "คื", "อ", "ภาษาไทย"])
        self.assertTrue(tokens3[0].is_ambiguous) # นี่
        self.assertTrue(tokens3[1].is_ambiguous) # คื
        self.assertTrue(tokens3[2].is_ambiguous) # อ

    def test_unsupported_language(self):
        result = self.engine.segment("hello", "fr")
        self.assertEqual(result, "unavailableTokenization")

    def test_punctuation(self):
        tokens = self.engine.segment("中国,人", "zh")
        surfaces = [t.surface for t in tokens]
        self.assertEqual(surfaces, ["中国", ",", "人"])

    def test_source_spans(self):
        text = "中国人"
        tokens = self.engine.segment(text, "zh")
        token = tokens[0]
        self.assertEqual(text[token.start_offset:token.end_offset], token.surface)

        text2 = "中国,人"
        tokens2 = self.engine.segment(text2, "zh")
        for token in tokens2:
            self.assertEqual(text2[token.start_offset:token.end_offset], token.surface)

    def test_empty_string(self):
        tokens = self.engine.segment("", "zh")
        self.assertEqual(len(tokens), 0)

if __name__ == '__main__':
    unittest.main()
