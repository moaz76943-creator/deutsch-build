from typing import Dict, List
from tools.morphology.tokenization.core import (
    LanguageTokenizer,
    TokenizationResult,
    Token
)

class TokenizationEngine:
    def __init__(self):
        self._registry: Dict[str, LanguageTokenizer] = {}

    def register_tokenizer(self, language_code: str, tokenizer: LanguageTokenizer) -> None:
        """Registers a tokenizer for a given language code."""
        self._registry[language_code] = tokenizer

    def tokenize(self, text: str, language_code: str) -> TokenizationResult:
        """
        Routes the text to the appropriate language tokenizer.
        Returns unavailableTokenization if no tokenizer is registered for the language.
        """
        if not text:
            return TokenizationResult(tokens=[])

        tokenizer = self._registry.get(language_code)
        if not tokenizer:
            return TokenizationResult(tokens=[], unavailableTokenization=True)

        return tokenizer.tokenize(text)

