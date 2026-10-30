import sys
import types
import unittest

# Mock required ScopeGuard as per explicit instructions
module = types.ModuleType('tools.agent_contract.guard')
module.ScopeGuard = lambda x: None
sys.modules['tools.agent_contract.guard'] = module

module_contracts = types.ModuleType('tools.ingestion.contracts')
module_contracts.J002CompilerContract = type('J002CompilerContract', (), {})
sys.modules['tools.ingestion.contracts'] = module_contracts

import sys
import types
module = types.ModuleType('tools.agent_contract.guard')
class DummyScopeGuard:
    def __init__(self, *args, **kwargs):
        pass
    def add_allowed_path(self, *args, **kwargs):
        pass
module.ScopeGuard = DummyScopeGuard
sys.modules['tools.agent_contract.guard'] = module

module_contracts = types.ModuleType('tools.ingestion.contracts')
module_contracts.J002CompilerContract = type('J002CompilerContract', (), {})
sys.modules['tools.ingestion.contracts'] = module_contracts

from tools.ingestion.normalization.engine import NormalizationEngine, NormalizationResult

class TestNormalizationEngine(unittest.TestCase):
    def setUp(self):
        self.engine = NormalizationEngine()

    def test_basic_normalization(self):
        result = self.engine.normalize('Hello', 'en')
        self.assertEqual(result.search_key, 'hello')
        self.assertEqual(result.original_text, 'Hello')

    def test_max_input_length(self):
        long_text = 'a' * 1001
        with self.assertRaises(ValueError):
            self.engine.normalize(long_text, 'en')

    def test_invalid_type(self):
        with self.assertRaises(TypeError):
            self.engine.normalize(123, 'en')

    def test_combining_marks_and_normalization_collisions(self):
        # e + combining acute accent
        text1 = 'e\u0301'
        # precomposed é
        text2 = '\u00e9'

        res1 = self.engine.normalize(text1, 'en')
        res2 = self.engine.normalize(text2, 'en')

        # Original should be NFC
        self.assertEqual(res1.original_text, res2.original_text)
        self.assertEqual(res1.search_key, res2.search_key)
        self.assertEqual(res1.search_key, '\u00e9')

    def test_german_normalization(self):
        res1 = self.engine.normalize('Straße', 'de')
        self.assertEqual(res1.search_key, 'straße')
        self.assertIn('DE_PRESERVE_UMLAUT_SZ', res1.applied_rules)

        res2 = self.engine.normalize('STRASSE', 'de')
        self.assertEqual(res2.search_key, 'strasse')

        res_sz_upper = self.engine.normalize('STRAẞE', 'de')
        self.assertEqual(res_sz_upper.search_key, 'straße')

        # Umlauts preserved (not converted to ae)
        res3 = self.engine.normalize('Äpfel', 'de')
        self.assertEqual(res3.search_key, 'äpfel')

        # Original text should be strictly preserved
        self.assertEqual(res1.original_text, 'Straße')

    def test_arabic_normalization(self):
        # Mixed text with tatweel and tashkeel
        text = 'مَـكْتَبَة'
        res = self.engine.normalize(text, 'ar')
        self.assertEqual(res.search_key, 'مكتبة')
        self.assertIn('AR_STRIP_TATWEEL', res.applied_rules)
        self.assertIn('AR_STRIP_TASHKEEL', res.applied_rules)

        # Alif variants
        res2 = self.engine.normalize('أحمد', 'ar')
        self.assertEqual(res2.search_key, 'احمد')
        self.assertIn('AR_NORMALIZE_ALIF', res2.applied_rules)

    def test_hebrew_normalization(self):
        text = 'שָׁלוֹם'
        res = self.engine.normalize(text, 'he')
        self.assertEqual(res.search_key, 'שלום')
        self.assertIn('HE_STRIP_NIQQUD', res.applied_rules)

    def test_cjk_vietnamese_indic_preservation(self):
        ja_text = 'こんにちは'
        vi_text = 'Tiếng Việt'
        hi_text = 'नमस्ते'

        self.assertEqual(self.engine.normalize(ja_text, 'ja').search_key, ja_text)
        self.assertEqual(self.engine.normalize(vi_text, 'vi').search_key, 'tiếng việt')
        self.assertEqual(self.engine.normalize(hi_text, 'hi').search_key, hi_text)

    def test_mixed_rtl_ltr(self):
        text = 'مكتبة library'
        res = self.engine.normalize(text, 'ar')
        self.assertEqual(res.search_key, 'مكتبة library')

    def test_optional_case_folding_and_punctuation(self):
        text = 'Hello, World!'

        # Default behavior: case folding is True, punctuation stripping is False
        res1 = self.engine.normalize(text, 'en')
        self.assertEqual(res1.search_key, 'hello, world!')

        # Disable case folding
        res2 = self.engine.normalize(text, 'en', fold_case=False)
        self.assertEqual(res2.search_key, 'Hello, World!')

        # Enable punctuation stripping
        res3 = self.engine.normalize(text, 'en', strip_punctuation=True)
        self.assertEqual(res3.search_key, 'hello world')
        self.assertIn('STRIP_PUNCTUATION', res3.applied_rules)

        # Enable punctuation stripping and disable case folding
        res4 = self.engine.normalize(text, 'en', fold_case=False, strip_punctuation=True)
        self.assertEqual(res4.search_key, 'Hello World')
        self.assertIn('STRIP_PUNCTUATION', res4.applied_rules)

if __name__ == '__main__':
    unittest.main()
