import unittest
import sys
import os

sys.path.append(os.path.dirname(__file__))
from engine import TokenizationEngine, TokenIdentity

class TestTokenizationEngine(unittest.TestCase):
    def setUp(self):
        # We inject mock dictionaries for test purposes
        dictionaries = {
            "zh": {"你好", "世界", "中华", "人民", "共和国", "中华人民", "中华人民共和国"},
            "ja": {"東京", "スカイツリー", "こんにちは", "世界"},
            "th": {"สวัสดี", "ครับ", "กับ"}
        }
        self.engine = TokenizationEngine(dictionaries=dictionaries)

    def test_unsupported_language(self):
        res = self.engine.segment("hello", "en")
        self.assertEqual(res, "unavailableTokenization")

    def test_chinese_segmentation(self):
        text = "你好世界"
        tokens = self.engine.segment(text, "zh")
        self.assertEqual(len(tokens), 2)
        self.assertEqual(tokens[0].surface, "你好")
        self.assertFalse(tokens[0].is_ambiguous)
        self.assertEqual(tokens[1].surface, "世界")
        self.assertFalse(tokens[1].is_ambiguous)
        self.assertEqual(tokens[0].start_offset, 0)
        self.assertEqual(tokens[0].end_offset, 2)

    def test_chinese_ambiguity(self):
        text = "中华人民共和国"
        tokens = self.engine.segment(text, "zh")
        self.assertEqual("".join(t.surface for t in tokens), text)
        self.assertEqual(tokens[0].surface, "中华人民共和国")

    def test_chinese_fallback_ambiguity(self):
        text = "未知词语"
        tokens = self.engine.segment(text, "zh")
        # Should fallback to char-by-char with is_ambiguous=True
        self.assertEqual(len(tokens), 4)
        for t in tokens:
            self.assertTrue(t.is_ambiguous)

    def test_japanese_segmentation(self):
        text = "こんにちは世界"
        tokens = self.engine.segment(text, "ja")
        self.assertEqual(len(tokens), 2)
        self.assertEqual(tokens[0].surface, "こんにちは")
        self.assertEqual(tokens[1].surface, "世界")

    def test_japanese_mixed(self):
        text = "東京スカイツリー"
        tokens = self.engine.segment(text, "ja")
        self.assertEqual(len(tokens), 2)
        self.assertEqual(tokens[0].surface, "東京")
        self.assertEqual(tokens[1].surface, "スカイツリー")

    def test_thai_segmentation(self):
        text = "กับ"
        tokens = self.engine.segment(text, "th")
        self.assertEqual(len(tokens), 1)
        self.assertEqual(tokens[0].surface, "กับ")

    def test_thai_continuous(self):
        text = "สวัสดีครับ"
        tokens = self.engine.segment(text, "th")
        self.assertEqual(len(tokens), 2)
        self.assertEqual(tokens[0].surface, "สวัสดี")
        self.assertEqual(tokens[1].surface, "ครับ")

    def test_surrogate_pairs(self):
        text = "𠜎𠜱" # two characters outside BMP
        tokens = self.engine.segment(text, "zh")
        self.assertEqual(len(tokens), 2)
        self.assertEqual(tokens[0].surface, "𠜎")
        self.assertEqual(tokens[1].surface, "𠜱")

    def test_punctuation_malformed(self):
        text = "你好，世界！"
        tokens = self.engine.segment(text, "zh")
        self.assertEqual("".join(t.surface for t in tokens), text)
        self.assertTrue(any(t.surface == "，" for t in tokens))
        self.assertTrue(any(t.surface == "！" for t in tokens))

    def test_thai_punctuation_malformed(self):
        text = "สวัสดี!! ครับ?"
        tokens = self.engine.segment(text, "th")
        self.assertEqual("".join(t.surface for t in tokens), text)
        self.assertTrue(any(t.surface == "!" for t in tokens))

    def test_ja_punctuation(self):
        text = "東京、スカイ。ツリー"
        tokens = self.engine.segment(text, "ja")
        self.assertEqual("".join(t.surface for t in tokens), text)
        surfaces = [t.surface for t in tokens]
        self.assertIn("、", surfaces)
        self.assertIn("。", surfaces)

if __name__ == '__main__':
    unittest.main()
