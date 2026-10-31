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

        # Should token as 研究生 and 命 or 研究 and 生命 depending on longest match,
        # but in our greedy longest match, "研究生" (3 chars) takes precedence over "研究" (2 chars).
        self.assertEqual(res.tokens[0].surface, "研究生")
        # In our basic implementation, since "研究" (len 2) and "研究生" (len 3) are both valid,
        # len(valid_match_lengths) > 1, so is_ambiguous should be True.
        self.assertTrue(res.tokens[0].is_ambiguous)

    def test_chinese_candidate_bounding(self):
        lexicon = MockLexicon({"A": "id1"})
        # Intentionally low bounds
        tokenizer = ChineseTokenizer(lexicon, max_candidates=2, max_lookahead=10)
        res = tokenizer.tokenize("ABCDEFGHIJK")
        # With max_candidates=2, it will break early and fallback
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

        # Check offsets are preserved
        self.assertEqual(text[res.tokens[1].start_offset:res.tokens[1].end_offset], "ひらがな")

    def test_japanese_decomposition_without_inventing(self):
         lexicon = MockLexicon({
            "東京": "ja-1"
            # "都" is not in dict
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
        # Surrogate pair for a musical symbol U+1D11E 𝄞
        text = "\uD834\uDD1E"
        boundaries = get_cluster_boundaries(text)
        # Should be treated as 1 cluster in Python if it represents one character,
        # but in Python strings U+1D11E is len 1. If we force surrogate pair:
        text_surrogate = chr(0xD834) + chr(0xDD1E)
        boundaries = get_cluster_boundaries(text_surrogate)
        self.assertEqual(boundaries, [0, 2])

        # Combining marks
        # e.g., 'e' + acute accent
        text_combining = "e\u0301"
        boundaries = get_cluster_boundaries(text_combining)
        self.assertEqual(boundaries, [0, 2])

        lexicon = MockLexicon({"e\u0301": "id1"})
        tokenizer = ThaiTokenizer(lexicon) # Any tokenizer using get_cluster_boundaries
        res = tokenizer.tokenize(text_combining)
        self.assertEqual(len(res.tokens), 1)
        self.assertEqual(res.tokens[0].surface, "e\u0301")

        # Test malformed / surrogate / combining marks with Japanese Tokenizer directly
        text_jp = "漢\u0301字" + chr(0xD834) + chr(0xDD1E)
        jp_tokenizer = JapaneseTokenizer(lexicon) # Dict empty for these chars, will fall back
        jp_res = jp_tokenizer.tokenize(text_jp)
        # Should gracefully return token boundaries
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
        # We can use ThaiTokenizer as a generic longest-match fallback to clusters
        tokenizer = ThaiTokenizer(lexicon)
        res = tokenizer.tokenize(text)

        reconstructed = "".join([t.surface for t in res.tokens])
        self.assertEqual(reconstructed, text)

        # Verify offsets
        for t in res.tokens:
             self.assertEqual(text[t.start_offset:t.end_offset], t.surface)

if __name__ == "__main__":
    unittest.main()
