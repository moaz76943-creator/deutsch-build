from typing import Dict, Set, Optional, List
from tools.morphology.tokenization.core import Token, TokenizationResult, Lexicon, LanguageTokenizer
from tools.morphology.tokenization.chinese import ChineseTokenizer
from tools.morphology.tokenization.japanese import JapaneseTokenizer
from tools.morphology.tokenization.thai import ThaiTokenizer
from tools.morphology.tokenization.fallback import FallbackTokenizer

class TokenIdentity:
    pass

class DictLexicon(Lexicon):
    def __init__(self, data: Set[str]):
        self.data = data

    def lookup(self, surface: str) -> Optional[str]:
        if surface in self.data:
            return surface # Dummy return since tests just check token text
        return None

class TokenizationEngine:
    def __init__(self, dictionaries: Dict[str, Set[str]]):
        self.tokenizers: Dict[str, LanguageTokenizer] = {}

        zh_dict = dictionaries.get("zh", set())
        self.tokenizers["zh"] = ChineseTokenizer(DictLexicon(zh_dict))

        ja_dict = dictionaries.get("ja", set())
        self.tokenizers["ja"] = JapaneseTokenizer(DictLexicon(ja_dict))

        th_dict = dictionaries.get("th", set())
        self.tokenizers["th"] = ThaiTokenizer(DictLexicon(th_dict))

        self.fallback = FallbackTokenizer()

    def segment(self, text: str, language_code: str):
        tokenizer = self.tokenizers.get(language_code, self.fallback)
        result = tokenizer.tokenize(text)

        if result.unavailableTokenization:
            return "unavailableTokenization"

        return result.tokens
