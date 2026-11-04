import unittest
import sys
import os
from typing import Optional, List, Union

sys.path.append(os.path.dirname(__file__))
from tools.morphology.tokenization.engine import TokenizationEngine
from tools.morphology.tokenization.core import Lexicon, Token
from tools.morphology.tokenization.chinese import ChineseTokenizer
from tools.morphology.tokenization.japanese import JapaneseTokenizer
from tools.morphology.tokenization.thai import ThaiTokenizer

class MockLexicon(Lexicon):
    def __init__(self, data: set[str]):
        self.data = data

    def lookup(self, surface: str) -> Optional[str]:
        if surface in self.data:
            return f"id_{surface}"
        return None

class TestTokenizationEngine(unittest.TestCase):
    def setUp(self):
        # We inject mock dictionaries for test purposes
        dictionaries = {
            "zh": {"你好", "世界", "中华", "人民", "共和国", "中华人民", "中华人民共和国"},
            "ja": {"東京", "スカイツリー", "こんにちは", "世界"},
            "th": {"สวัสดี", "ครับ", "กับ"}
        }
        self.engine = TokenizationEngine()
        self.engine.register_tokenizer("zh", ChineseTokenizer(MockLexicon(dictionaries["zh"])))
        self.engine.register_tokenizer("ja", JapaneseTokenizer(MockLexicon(dictionaries["ja"])))
        self.engine.register_tokenizer("th", ThaiTokenizer(MockLexicon(dictionaries["th"])))

    def _segment(self, text: str, lang: str) -> Union[List[Token], str]:
        res = self.engine.segment(text, lang)
        if res.unavailableTokenization:
            return "unavailableTokenization"
        return res.tokens

    def test_unsupported_language(self):
        res = self._segment("hello", "en")
        self.assertEqual(res, "unavailableTokenization")

    def test_chinese_segmentation(self):
        text = "你好世界"
        tokens = self._segment(text, "zh")
        self.assertEqual(len(tokens), 2)
        self.assertEqual(tokens[0].surface, "你好")
        self.assertFalse(tokens[0].is_ambiguous)
        self.assertEqual(tokens[1].surface, "世界")
        self.assertFalse(tokens[1].is_ambiguous)
        self.assertEqual(tokens[0].start_offset, 0)
        self.assertEqual(tokens[0].end_offset, 2)

    def test_chinese_ambiguity(self):
        text = "中华人民共和国"
        tokens = self._segment(text, "zh")
        self.assertEqual("".join(t.surface for t in tokens), text)
        self.assertEqual(tokens[0].surface, "中华人民共和国")

    def test_chinese_fallback_ambiguity(self):
        text = "未知词语"
        tokens = self._segment(text, "zh")
        # Should fallback to char-by-char with is_ambiguous=True
        self.assertEqual(len(tokens), 4)
        for t in tokens:
            self.assertTrue(t.is_ambiguous)

    def test_japanese_segmentation(self):
        text = "こんにちは世界"
        tokens = self._segment(text, "ja")
        self.assertEqual(len(tokens), 2)
        self.assertEqual(tokens[0].surface, "こんにちは")
        self.assertEqual(tokens[1].surface, "世界")

    def test_japanese_mixed(self):
        text = "東京スカイツリー"
        tokens = self._segment(text, "ja")
        self.assertEqual(len(tokens), 2)
        self.assertEqual(tokens[0].surface, "東京")
        self.assertEqual(tokens[1].surface, "スカイツリー")

    def test_thai_segmentation(self):
        text = "กับ"
        tokens = self._segment(text, "th")
        self.assertEqual(len(tokens), 1)
        self.assertEqual(tokens[0].surface, "กับ")

    def test_thai_continuous(self):
        text = "สวัสดีครับ"
        tokens = self._segment(text, "th")
        self.assertEqual(len(tokens), 2)
        self.assertEqual(tokens[0].surface, "สวัสดี")
        self.assertEqual(tokens[1].surface, "ครับ")

    def test_surrogate_pairs(self):
        text = "𠜎𠜱" # two characters outside BMP
        tokens = self._segment(text, "zh")
        self.assertEqual(len(tokens), 2)
        self.assertEqual(tokens[0].surface, "𠜎")
        self.assertEqual(tokens[1].surface, "𠜱")

    def test_punctuation_malformed(self):
        text = "你好，世界！"
        tokens = self._segment(text, "zh")
        self.assertEqual("".join(t.surface for t in tokens), text)
        self.assertTrue(any(t.surface == "，" for t in tokens))
        self.assertTrue(any(t.surface == "！" for t in tokens))

    def test_thai_punctuation_malformed(self):
        text = "สวัสดี!! ครับ?"
        tokens = self._segment(text, "th")
        self.assertEqual("".join(t.surface for t in tokens), text)
        self.assertTrue(any(t.surface == "!" for t in tokens))

    def test_ja_punctuation(self):
        text = "東京、スカイ。ツリー"
        tokens = self._segment(text, "ja")
        self.assertEqual("".join(t.surface for t in tokens), text)
        surfaces = [t.surface for t in tokens]
        self.assertIn("、", surfaces)
        self.assertIn("。", surfaces)

if __name__ == '__main__':
    unittest.main()
