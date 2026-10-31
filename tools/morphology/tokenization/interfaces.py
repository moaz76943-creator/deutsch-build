from dataclasses import dataclass
from typing import List
from abc import ABC, abstractmethod

@dataclass
class Token:
    """
    Represents a lexical token emitted from the segmentation engine.
    Suitable for FTS5 indexing. Preserves source offsets and Unicode code points.
    """
    text: str
    start: int
    end: int
    is_ambiguous: bool

@dataclass
class TokenizationResult:
    tokens: List[Token]
    unavailable_tokenization: bool = False

class LanguageTokenizer(ABC):
    """
    Pluggable language-specific tokenizer interface.
    """
    @abstractmethod
    def tokenize(self, text: str) -> TokenizationResult:
        """
        Tokenizes the input text preserving boundaries and offsets.
        """
        pass
