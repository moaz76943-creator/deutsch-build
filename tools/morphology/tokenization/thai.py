from typing import List, Optional
from tools.morphology.tokenization.core import LanguageTokenizer, Lexicon, Token, TokenizationResult
from tools.morphology.tokenization.utils import get_cluster_boundaries


class ThaiTokenizer(LanguageTokenizer):
    def __init__(self, lexicon: Lexicon, max_lookahead: int = 15):
        self.lexicon = lexicon
        self.max_lookahead = max_lookahead

    def tokenize(self, text: str) -> TokenizationResult:
        if not text:
            return TokenizationResult(tokens=[])

        boundaries = get_cluster_boundaries(text)
        tokens: List[Token] = []
        i = 0

        while i < len(boundaries) - 1:
            start_idx = boundaries[i]
            longest_match_end_i = i + 1
            longest_match_lexical_id: Optional[str] = None

            lookahead_limit = min(len(boundaries) - 1, i + self.max_lookahead)

            for j in range(lookahead_limit, i, -1):
                surface = text[start_idx:boundaries[j]]
                lexical_id = self.lexicon.lookup(surface)

                if lexical_id is not None:
                    longest_match_end_i = j
                    longest_match_lexical_id = lexical_id
                    break

            end_idx = boundaries[longest_match_end_i]
            surface = text[start_idx:end_idx]

            # If no dictionary match, it falls back to a single cluster
            if longest_match_lexical_id is None:
                 lexical_id = self.lexicon.lookup(surface)
            else:
                 lexical_id = longest_match_lexical_id

            tokens.append(Token(
                surface=surface,
                start_offset=start_idx,
                end_offset=end_idx,
                lexical_id=lexical_id,
                is_ambiguous=False
            ))

            i = longest_match_end_i

        return TokenizationResult(tokens=tokens)
