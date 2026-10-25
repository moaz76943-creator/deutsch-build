import unittest
from tools.morphology.tokenization.core import Token, Lexicon
from tools.morphology.tokenization.engine import TokenizationEngine
from tools.morphology.tokenization.chinese import ChineseTokenizer
from tools.morphology.tokenization.japanese import JapaneseTokenizer
from tools.morphology.tokenization.thai import ThaiTokenizer

class MockLexicon(Lexicon):
    def __init__(self, data: set[str]):
        self.data = data

    def lookup(self, surface: str) -> str | None:
        return surface if surface in self.data else None

class TestTokenizer(unittest.TestCase):
    def setUp(self):
        self.dictionary = {
            "中国", "人", "中国人",
            "私", "は", "学生", "です",
            "ภาษา", "ไทย", "ภาษาไทย",
            "test"
        }
        lexicon = MockLexicon(self.dictionary)
        self.zh_tokenizer = ChineseTokenizer(lexicon)
        self.ja_tokenizer = JapaneseTokenizer(lexicon)
        self.th_tokenizer = ThaiTokenizer(lexicon)
        self.engine = TokenizationEngine()
        self.engine.register_tokenizer("zh", self.zh_tokenizer)
        self.engine.register_tokenizer("ja", self.ja_tokenizer)
        self.engine.register_tokenizer("th", self.th_tokenizer)

    def test_chinese_ambiguity(self):
        result = self.zh_tokenizer.tokenize("中国人")
        self.assertEqual(len(result.tokens), 1)
        self.assertEqual(result.tokens[0].surface, "中国人")
        self.assertTrue(result.tokens[0].is_ambiguous)

        result2 = self.zh_tokenizer.tokenize("我是中国人")
        self.assertEqual(result2.tokens[-1].surface, "中国人")

        # Test OOV fallback logic 1-character at a time
        tokens2 = [t.surface for t in result2.tokens]
        self.assertEqual(tokens2, ["我", "是", "中国人"])

    def test_japanese_script_boundaries(self):
        result = self.ja_tokenizer.tokenize("私は学生です")
        tokens = [t.surface for t in result.tokens]
        self.assertEqual(tokens, ["私", "は", "学生", "です"])

        result2 = self.ja_tokenizer.tokenize("彼と話す")
        tokens2 = [t.surface for t in result2.tokens]
        # All OOV
        self.assertEqual(tokens2, ["彼", "と", "話", "す"])

    def test_thai_combining_characters(self):
        result = self.th_tokenizer.tokenize("ภาษาไทย")
        self.assertEqual(len(result.tokens), 1)
        self.assertEqual(result.tokens[0].surface, "ภาษาไทย")

        result2 = self.th_tokenizer.tokenize("ภาษา")
        self.assertEqual(result2.tokens[0].surface, "ภาษา")
        self.assertEqual(result2.tokens[0].start_offset, 0)
        self.assertEqual(result2.tokens[0].end_offset, 4)

        result3 = self.th_tokenizer.tokenize("นี่คือภาษาไทย")
        tokens3 = [t.surface for t in result3.tokens]
        self.assertEqual(tokens3, ["นี่", "คื", "อ", "ภาษาไทย"])

    def test_unsupported_language(self):
        result = self.engine.tokenize("hello", "fr")
        self.assertTrue(result.unavailableTokenization)
        self.assertEqual(len(result.tokens), 0)

    def test_punctuation(self):
        result = self.zh_tokenizer.tokenize("中国,人")
        tokens = [t.surface for t in result.tokens]
        self.assertEqual(tokens, ["中国", ",", "人"])

    def test_source_spans(self):
        text = "中国人"
        result = self.zh_tokenizer.tokenize(text)
        token = result.tokens[0]
        self.assertEqual(text[token.start_offset:token.end_offset], token.surface)

        text2 = "中国,人"
        result2 = self.zh_tokenizer.tokenize(text2)
        for token in result2.tokens:
            self.assertEqual(text2[token.start_offset:token.end_offset], token.surface)

    def test_empty_string(self):
        result = self.zh_tokenizer.tokenize("")
        self.assertEqual(len(result.tokens), 0)

if __name__ == '__main__':
    unittest.main()
