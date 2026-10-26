from typing import List, Dict, Set, Optional, Union
from tools.morphology.tokenization.core import LanguageTokenizer, Token, TokenizationResult, Lexicon
from tools.morphology.tokenization.chinese import ChineseTokenizer
from tools.morphology.tokenization.japanese import JapaneseTokenizer
from tools.morphology.tokenization.thai import ThaiTokenizer

# Re-export Token as TokenIdentity for backwards compatibility / test support
TokenIdentity = Token

class SetLexicon(Lexicon):
    def __init__(self, dictionary: Set[str]):
        self.dictionary = dictionary

    def lookup(self, surface: str) -> Optional[str]:
        # Simple lookup: returns surface as ID if found, else None
        return surface if surface in self.dictionary else None

class TokenizationEngine:
    """
    Registers and queries tokenizers.
    """
    def __init__(self, dictionaries: Optional[Dict[str, Set[str]]] = None):
        self._tokenizers: Dict[str, LanguageTokenizer] = {}
        if dictionaries:
            for lang_code, dictionary in dictionaries.items():
                lexicon = SetLexicon(dictionary)
                if lang_code == "zh":
                    self.register_tokenizer(lang_code, ChineseTokenizer(lexicon))
                elif lang_code == "ja":
                    self.register_tokenizer(lang_code, JapaneseTokenizer(lexicon))
                elif lang_code == "th":
                    self.register_tokenizer(lang_code, ThaiTokenizer(lexicon))
                else:
                    # Generic fallback or ignore for unknown codes if needed,
                    # but test specifies zh, ja, th.
                    pass

    def register_tokenizer(self, language_code: str, tokenizer: LanguageTokenizer):
        self._tokenizers[language_code] = tokenizer

    def segment(self, text: str, language_code: str) -> Union[List[Token], str]:
        """
        Segments text for the given language code.
        Returns a list of Tokens or the string "unavailableTokenization".
        """
        if not text:
            return []

        tokenizer = self._tokenizers.get(language_code)
        if not tokenizer:
            return "unavailableTokenization"

        result = tokenizer.tokenize(text)
        if result.unavailableTokenization:
            return "unavailableTokenization"

        return result.tokens

