import unittest
from typing import Optional
from tools.morphology.tokenization.core import Lexicon
from tools.morphology.tokenization.utils import get_cluster_boundaries, get_script
from tools.morphology.tokenization.chinese import ChineseTokenizer
from tools.morphology.tokenization.japanese import JapaneseTokenizer
from tools.morphology.tokenization.thai import ThaiTokenizer
from tools.morphology.tokenization.fallback import FallbackTokenizer


class MockLexicon(Lexicon):
    def __init__(self, data: dict[str, str]):
        self.data = data

    def lookup(self, surface: str) -> Optional[str]:
        return self.data.get(surface)


class TestTokenization(unittest.TestCase):
    def test_chinese_ambiguity_and_bounds(self):
        lexicon = MockLexicon({
            "中": "zh-1",
            "中国": "zh-2",
            "中国人": "zh-3",
            "人": "zh-4"
        })
        tokenizer = ChineseTokenizer(lexicon, max_candidates=10)

        # Test longest match
        res = tokenizer.tokenize("中国人")
        self.assertFalse(res.unavailableTokenization)
        self.assertEqual(len(res.tokens), 1)
        self.assertEqual(res.tokens[0].surface, "中国人")
        self.assertEqual(res.tokens[0].lexical_id, "zh-3")

        # Test ambiguity
        lexicon_ambig = MockLexicon({
            "研究": "zh-1",
            "研究生": "zh-2",
            "生命": "zh-3",
            "命": "zh-4"
        })
        tokenizer_ambig = ChineseTokenizer(lexicon_ambig)
        res = tokenizer_ambig.tokenize("研究生命")

        self.assertEqual(res.tokens[0].surface, "研究生")
        self.assertTrue(res.tokens[0].is_ambiguous)

    def test_chinese_candidate_bounding(self):
        lexicon = MockLexicon({"A": "id1"})
        tokenizer = ChineseTokenizer(lexicon, max_candidates=2, max_lookahead=10)
        res = tokenizer.tokenize("ABCDEFGHIJK")
        self.assertTrue(res.tokens[0].is_ambiguous)

    def test_japanese_mixed_scripts(self):
        lexicon = MockLexicon({
            "漢字": "ja-1",
            "ひらがな": "ja-2",
            "カタカナ": "ja-3"
        })
        tokenizer = JapaneseTokenizer(lexicon)
        text = "漢字ひらがなカタカナ"
        res = tokenizer.tokenize(text)

        self.assertFalse(res.unavailableTokenization)
        self.assertEqual(len(res.tokens), 3)
        self.assertEqual(res.tokens[0].surface, "漢字")
        self.assertEqual(res.tokens[0].lexical_id, "ja-1")
        self.assertEqual(res.tokens[1].surface, "ひらがな")
        self.assertEqual(res.tokens[1].lexical_id, "ja-2")
        self.assertEqual(res.tokens[2].surface, "カタカナ")
        self.assertEqual(res.tokens[2].lexical_id, "ja-3")
        self.assertEqual(text[res.tokens[1].start_offset:res.tokens[1].end_offset], "ひらがな")

    def test_japanese_decomposition_without_inventing(self):
         lexicon = MockLexicon({
            "東京": "ja-1"
         })
         tokenizer = JapaneseTokenizer(lexicon)
         res = tokenizer.tokenize("東京都")
         self.assertEqual(len(res.tokens), 2)
         self.assertEqual(res.tokens[0].surface, "東京")
         self.assertEqual(res.tokens[0].lexical_id, "ja-1")
         self.assertEqual(res.tokens[1].surface, "都")
         self.assertIsNone(res.tokens[1].lexical_id)

    def test_thai_continuous_text(self):
        lexicon = MockLexicon({
            "ภาษาไทย": "th-1",
            "ดี": "th-2",
            "มาก": "th-3"
        })
        tokenizer = ThaiTokenizer(lexicon)
        text = "ภาษาไทยดีมาก"
        res = tokenizer.tokenize(text)

        self.assertEqual(len(res.tokens), 3)
        self.assertEqual(res.tokens[0].surface, "ภาษาไทย")
        self.assertEqual(res.tokens[0].lexical_id, "th-1")
        self.assertEqual(res.tokens[1].surface, "ดี")
        self.assertEqual(res.tokens[2].surface, "มาก")

    def test_malformed_and_surrogates(self):
        text = "\uD834\uDD1E"
        text_surrogate = chr(0xD834) + chr(0xDD1E)
        boundaries = get_cluster_boundaries(text_surrogate)
        self.assertEqual(boundaries, [0, 2])

        text_combining = "e\u0301"
        boundaries = get_cluster_boundaries(text_combining)
        self.assertEqual(boundaries, [0, 2])

        lexicon = MockLexicon({"e\u0301": "id1"})
        tokenizer = ThaiTokenizer(lexicon)
        res = tokenizer.tokenize(text_combining)
        self.assertEqual(len(res.tokens), 1)
        self.assertEqual(res.tokens[0].surface, "e\u0301")

        text_jp = "漢\u0301字" + chr(0xD834) + chr(0xDD1E)
        jp_tokenizer = JapaneseTokenizer(lexicon)
        jp_res = jp_tokenizer.tokenize(text_jp)
        self.assertEqual(len(jp_res.tokens), 3)
        self.assertEqual(jp_res.tokens[0].surface, "漢\u0301")

    def test_fallback_tokenizer(self):
        tokenizer = FallbackTokenizer()
        res = tokenizer.tokenize("Some unknown text")
        self.assertTrue(res.unavailableTokenization)
        self.assertEqual(len(res.tokens), 0)

    def test_preserve_source_spans(self):
        lexicon = MockLexicon({})
        text = "Some random text 123"
        tokenizer = ThaiTokenizer(lexicon)
        res = tokenizer.tokenize(text)

        reconstructed = "".join([t.surface for t in res.tokens])
        self.assertEqual(reconstructed, text)

        for t in res.tokens:
             self.assertEqual(text[t.start_offset:t.end_offset], t.surface)

    def test_engine_registration_and_unsupported(self):
        from tools.morphology.tokenization.engine import SegmentationEngine
        engine = SegmentationEngine()

        lexicon = MockLexicon({"สวัสดี": "th-1"})
        tokenizer = ThaiTokenizer(lexicon)
        engine.register_tokenizer("th", tokenizer)

        res = engine.tokenize("สวัสดี", "th")
        self.assertFalse(res.unavailableTokenization)
        self.assertEqual(len(res.tokens), 1)
        self.assertEqual(res.tokens[0].surface, "สวัสดี")

        res = engine.tokenize("hello", "en")
        self.assertTrue(res.unavailableTokenization)
        self.assertEqual(len(res.tokens), 0)

    def test_chinese_punctuation(self):
        lexicon = MockLexicon({"你好": "zh-1", "世界": "zh-2"})
        tokenizer = ChineseTokenizer(lexicon)
        text = "你好，世界！"
        res = tokenizer.tokenize(text)

        self.assertFalse(res.unavailableTokenization)
        surfaces = [t.surface for t in res.tokens]
        self.assertEqual(surfaces, ["你好", "，", "世界", "！"])

        for t in res.tokens:
            self.assertEqual(text[t.start_offset:t.end_offset], t.surface)

    def test_japanese_punctuation(self):
        lexicon = MockLexicon({"東京": "ja-1", "スカイツリー": "ja-2"})
        tokenizer = JapaneseTokenizer(lexicon)
        text = "東京、スカイ。ツリー"
        res = tokenizer.tokenize(text)

        self.assertFalse(res.unavailableTokenization)
        surfaces = [t.surface for t in res.tokens]

        reconstructed = "".join(surfaces)
        self.assertEqual(reconstructed, text)
        self.assertIn("、", surfaces)
        self.assertIn("。", surfaces)

        for t in res.tokens:
            self.assertEqual(text[t.start_offset:t.end_offset], t.surface)

    def test_thai_punctuation_malformed(self):
        lexicon = MockLexicon({"สวัสดี": "th-1", "ครับ": "th-2"})
        tokenizer = ThaiTokenizer(lexicon)
        text = "สวัสดี!! ครับ?"
        res = tokenizer.tokenize(text)

        self.assertFalse(res.unavailableTokenization)
        surfaces = [t.surface for t in res.tokens]
        reconstructed = "".join(surfaces)
        self.assertEqual(reconstructed, text)
        self.assertIn("!", surfaces)
        self.assertIn("?", surfaces)
        self.assertIn(" ", surfaces)

        for t in res.tokens:
            self.assertEqual(text[t.start_offset:t.end_offset], t.surface)

if __name__ == "__main__":
    unittest.main()
