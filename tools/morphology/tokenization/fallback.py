from tools.morphology.tokenization.core import LanguageTokenizer, TokenizationResult


class FallbackTokenizer(LanguageTokenizer):
    def tokenize(self, text: str) -> TokenizationResult:
        """
        Always returns unavailableTokenization for unsupported languages.
        """
        return TokenizationResult(tokens=[], unavailableTokenization=True)
