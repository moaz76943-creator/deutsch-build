from typing import Dict
from tools.morphology.tokenization.core import (
    LanguageTokenizer,
    TokenizationResult
)

MAX_INPUT_LENGTH = 10000

class TokenizationEngine:
    """
    Registers and queries tokenizers.
    """
    def __init__(self):
        self._tokenizers: Dict[str, LanguageTokenizer] = {}

    def register_tokenizer(self, language_code: str, tokenizer: LanguageTokenizer):
        self._tokenizers[language_code] = tokenizer

    def tokenize(self, text: str, language_code: str) -> TokenizationResult:
        if len(text) > MAX_INPUT_LENGTH:
            raise ValueError(f"Input text exceeds maximum length of {MAX_INPUT_LENGTH}")

        tokenizer = self._tokenizers.get(language_code)
        if not tokenizer:
            return TokenizationResult(tokens=[], unavailableTokenization=True)

        return tokenizer.tokenize(text)

    def segment(self, text: str, language_code: str) -> TokenizationResult:
        """Alias for tokenize to maintain compatibility."""
        return self.tokenize(text, language_code)
