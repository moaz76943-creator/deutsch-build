from dataclasses import dataclass
from typing import Protocol, List, Optional


class Lexicon(Protocol):
    def lookup(self, surface: str) -> Optional[str]:
        """Looks up a surface form and returns its lexical ID if found."""
        ...


@dataclass
class Token:
    surface: str
    start_offset: int
    end_offset: int
    lexical_id: Optional[str]
    is_ambiguous: bool = False


@dataclass
class TokenizationResult:
    tokens: List[Token]
    unavailableTokenization: bool = False


class LanguageTokenizer(Protocol):
    def tokenize(self, text: str) -> TokenizationResult:
        """Tokenizes the given text."""
        ...
