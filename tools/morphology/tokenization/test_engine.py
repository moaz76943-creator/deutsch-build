import unittest
import sys
import os

sys.path.append(os.path.dirname(__file__))
from tools.morphology.tokenization.engine import SegmentationEngine, CJKThaiTokenizer

class TestTokenizationEngine(unittest.TestCase):
    def setUp(self):
        dictionaries = {
            "zh": {"你好", "世界", "中华", "人民", "共和国", "中华人民", "中华人民共和国"},
            "ja": {"東京", "スカイツリー", "こんにちは", "世界"},
            "th": {"สวัสดี", "ครับ", "กับ"}
        }
        self.engine = SegmentationEngine()
        self.engine.register_tokenizer("zh", CJKThaiTokenizer(dictionaries["zh"]))
        self.engine.register_tokenizer("ja", CJKThaiTokenizer(dictionaries["ja"]))
        self.engine.register_tokenizer("th", CJKThaiTokenizer(dictionaries["th"]))

    def test_unsupported_language(self):
        res = self.engine.tokenize("hello", "en")
        self.assertTrue(res.unavailable_tokenization)

    def test_chinese_segmentation(self):
        text = "你好世界"
        res = self.engine.tokenize(text, "zh")
        tokens = res.tokens
        self.assertEqual(len(tokens), 2)
        self.assertEqual(tokens[0].text, "你好")
        self.assertFalse(tokens[0].is_ambiguous)
        self.assertEqual(tokens[1].text, "世界")
        self.assertFalse(tokens[1].is_ambiguous)
        self.assertEqual(tokens[0].start, 0)
        self.assertEqual(tokens[0].end, 2)

    def test_chinese_ambiguity(self):
        text = "中华人民共和国"
        res = self.engine.tokenize(text, "zh")
        tokens = res.tokens
        self.assertEqual("".join(t.text for t in tokens), text)
        self.assertEqual(tokens[0].text, "中华人民共和国")

    def test_chinese_fallback_ambiguity(self):
        text = "未知词语"
        res = self.engine.tokenize(text, "zh")
        tokens = res.tokens
        # Should fallback to char-by-char with is_ambiguous=False based on current code
        self.assertEqual(len(tokens), 4)

    def test_japanese_segmentation(self):
        text = "こんにちは世界"
        res = self.engine.tokenize(text, "ja")
        tokens = res.tokens
        self.assertEqual(len(tokens), 2)
        self.assertEqual(tokens[0].text, "こんにちは")
        self.assertEqual(tokens[1].text, "世界")

    def test_japanese_mixed(self):
        text = "東京スカイツリー"
        res = self.engine.tokenize(text, "ja")
        tokens = res.tokens
        self.assertEqual(len(tokens), 2)
        self.assertEqual(tokens[0].text, "東京")
        self.assertEqual(tokens[1].text, "スカイツリー")

    def test_thai_segmentation(self):
        text = "กับ"
        res = self.engine.tokenize(text, "th")
        tokens = res.tokens
        self.assertEqual(len(tokens), 1)
        self.assertEqual(tokens[0].text, "กับ")

    def test_thai_continuous(self):
        text = "สวัสดีครับ"
        res = self.engine.tokenize(text, "th")
        tokens = res.tokens
        self.assertEqual(len(tokens), 2)
        self.assertEqual(tokens[0].text, "สวัสดี")
        self.assertEqual(tokens[1].text, "ครับ")

    def test_surrogate_pairs(self):
        text = "𠜎𠜱" # two characters outside BMP
        res = self.engine.tokenize(text, "zh")
        tokens = res.tokens
        self.assertEqual(len(tokens), 2)
        self.assertEqual(tokens[0].text, "𠜎")
        self.assertEqual(tokens[1].text, "𠜱")

    def test_punctuation_malformed(self):
        text = "你好，世界！"
        res = self.engine.tokenize(text, "zh")
        tokens = res.tokens
        self.assertEqual("".join(t.text for t in tokens), text)
        self.assertTrue(any(t.text == "，" for t in tokens))
        self.assertTrue(any(t.text == "！" for t in tokens))

    def test_thai_punctuation_malformed(self):
        text = "สวัสดี!! ครับ?"
        res = self.engine.tokenize(text, "th")
        tokens = res.tokens
        self.assertEqual("".join(t.text for t in tokens), text)
        self.assertTrue(any(t.text == "!" for t in tokens))

    def test_ja_punctuation(self):
        text = "東京、スカイ。ツリー"
        res = self.engine.tokenize(text, "ja")
        tokens = res.tokens
        self.assertEqual("".join(t.text for t in tokens), text)
        texts = [t.text for t in tokens]
        self.assertIn("、", texts)
        self.assertIn("。", texts)

if __name__ == '__main__':
    unittest.main()
