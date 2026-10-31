import unittest
from tools.morphology.tokenization.interfaces import Token
from tools.morphology.tokenization.engine import SegmentationEngine, CJKThaiTokenizer

class TestTokenizer(unittest.TestCase):
    def setUp(self):
        self.dictionary = {
            "中国", "人", "中国人",
            "私", "は", "学生", "です",
            "ภาษา", "ไทย", "ภาษาไทย",
            "test"
        }
        self.tokenizer = CJKThaiTokenizer(self.dictionary)
        self.engine = SegmentationEngine()
        self.engine.register_tokenizer("zh", self.tokenizer)
        self.engine.register_tokenizer("ja", self.tokenizer)
        self.engine.register_tokenizer("th", self.tokenizer)

    def test_chinese_ambiguity(self):
        result = self.tokenizer.tokenize("中国人")
        self.assertEqual(len(result.tokens), 1)
        self.assertEqual(result.tokens[0].text, "中国人")
        self.assertTrue(result.tokens[0].is_ambiguous)

        result2 = self.tokenizer.tokenize("我是中国人")
        self.assertEqual(result2.tokens[-1].text, "中国人")

        # Test OOV fallback logic 1-character at a time
        tokens2 = [t.text for t in result2.tokens]
        self.assertEqual(tokens2, ["我", "是", "中国人"])

    def test_japanese_script_boundaries(self):
        result = self.tokenizer.tokenize("私は学生です")
        tokens = [t.text for t in result.tokens]
        self.assertEqual(tokens, ["私", "は", "学生", "です"])

        result2 = self.tokenizer.tokenize("彼と話す")
        tokens2 = [t.text for t in result2.tokens]
        # All OOV
        self.assertEqual(tokens2, ["彼", "と", "話", "す"])

    def test_thai_combining_characters(self):
        result = self.tokenizer.tokenize("ภาษาไทย")
        self.assertEqual(len(result.tokens), 1)
        self.assertEqual(result.tokens[0].text, "ภาษาไทย")
        self.assertTrue(result.tokens[0].is_ambiguous)

        result2 = self.tokenizer.tokenize("ภาษา")
        self.assertEqual(result2.tokens[0].text, "ภาษา")
        self.assertEqual(result2.tokens[0].start, 0)
        self.assertEqual(result2.tokens[0].end, 4)

        result3 = self.tokenizer.tokenize("นี่คือภาษาไทย")
        tokens3 = [t.text for t in result3.tokens]
        self.assertEqual(tokens3, ["นี่", "คื", "อ", "ภาษาไทย"])

    def test_unsupported_language(self):
        result = self.engine.tokenize("hello", "fr")
        self.assertTrue(result.unavailable_tokenization)
        self.assertEqual(len(result.tokens), 0)

    def test_punctuation(self):
        result = self.tokenizer.tokenize("中国,人")
        tokens = [t.text for t in result.tokens]
        self.assertEqual(tokens, ["中国", ",", "人"])

    def test_source_spans(self):
        text = "中国人"
        result = self.tokenizer.tokenize(text)
        token = result.tokens[0]
        self.assertEqual(text[token.start:token.end], token.text)

        text2 = "中国,人"
        result2 = self.tokenizer.tokenize(text2)
        for token in result2.tokens:
            self.assertEqual(text2[token.start:token.end], token.text)

    def test_empty_string(self):
        result = self.tokenizer.tokenize("")
        self.assertEqual(len(result.tokens), 0)

if __name__ == '__main__':
    unittest.main()
