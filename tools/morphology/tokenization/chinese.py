from typing import List, Optional
from tools.morphology.tokenization.core import LanguageTokenizer, Lexicon, Token, TokenizationResult
from tools.morphology.tokenization.utils import get_cluster_boundaries


class ChineseTokenizer(LanguageTokenizer):
    def __init__(self, lexicon: Lexicon, max_candidates: int = 1000, max_lookahead: int = 10):
        self.lexicon = lexicon
        self.max_candidates = max_candidates
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
            candidate_count = 0
            longest_match_lexical_id: Optional[str] = None
            longest_match_surface = text[start_idx:boundaries[i + 1]]
            ambiguous = False

            # Check for ambiguity by tracking if multiple overlapping longest paths exist
            # For simplicity, if we find a long match, we mark it ambiguous if there is
            # another long match that overlaps significantly, but a simpler bounded greedy approach
            # meets the longest-match requirement. We will just check if multiple valid matches
            # of different lengths exist at this position as a basic ambiguity marker.
            valid_match_lengths = []

            lookahead_limit = min(len(boundaries) - 1, i + self.max_lookahead)

            # We want to find ALL valid matches to correctly flag ambiguity,
            # so we shouldn't break out immediately after finding the longest.
            # We iterate from longest possible to shortest.
            for j in range(lookahead_limit, i, -1):
                candidate_count += 1
                if candidate_count > self.max_candidates:
                    # Break out early to bound processing time
                    break

                end_idx = boundaries[j]
                surface = text[start_idx:end_idx]

                lexical_id = self.lexicon.lookup(surface)
                if lexical_id is not None:
                    valid_match_lengths.append(j - i)
                    if j > longest_match_end_i:
                        longest_match_end_i = j
                        longest_match_lexical_id = lexical_id
                        longest_match_surface = surface

            if candidate_count > self.max_candidates:
                 # If we exceeded candidate bound, just fallback to single cluster
                 longest_match_end_i = i + 1
                 longest_match_surface = text[start_idx:boundaries[longest_match_end_i]]
                 longest_match_lexical_id = self.lexicon.lookup(longest_match_surface)
                 ambiguous = True

            # If there's more than one valid match of length > 1, it's potentially ambiguous
            if len(valid_match_lengths) > 1:
                ambiguous = True
            elif longest_match_lexical_id is None:
                # If there are no matches, OOV fallback to char-by-char is considered ambiguous
                ambiguous = True

            end_idx = boundaries[longest_match_end_i]
            tokens.append(Token(
                surface=longest_match_surface,
                start_offset=start_idx,
                end_offset=end_idx,
                lexical_id=longest_match_lexical_id,
                is_ambiguous=ambiguous
            ))

            i = longest_match_end_i

        return TokenizationResult(tokens=tokens)
