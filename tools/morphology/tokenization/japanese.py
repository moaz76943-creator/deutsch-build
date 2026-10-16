from typing import List, Optional
from tools.morphology.tokenization.core import LanguageTokenizer, Lexicon, Token, TokenizationResult
from tools.morphology.tokenization.utils import get_script, get_cluster_boundaries


class JapaneseTokenizer(LanguageTokenizer):
    def __init__(self, lexicon: Lexicon):
        self.lexicon = lexicon

    def tokenize(self, text: str) -> TokenizationResult:
        if not text:
            return TokenizationResult(tokens=[])

        boundaries = get_cluster_boundaries(text)
        tokens: List[Token] = []

        i = 0
        while i < len(boundaries) - 1:
            start_idx = boundaries[i]
            first_char = text[start_idx:boundaries[i+1]]
            current_script = get_script(first_char)

            # Find the end of this script chunk
            chunk_end_i = i + 1
            while chunk_end_i < len(boundaries) - 1:
                next_start = boundaries[chunk_end_i]
                next_end = boundaries[chunk_end_i + 1]
                next_char = text[next_start:next_end]
                next_script = get_script(next_char)

                if next_script != current_script and next_script != 'UNKNOWN':
                     # We break at script boundaries, unless it's a mark/unknown that just attaches
                     break
                chunk_end_i += 1

            # Now we have a chunk from boundaries[i] to boundaries[chunk_end_i]
            # Decompose this chunk using dictionary lookup.
            # Simple longest match for this chunk:
            chunk_start_i = i
            while chunk_start_i < chunk_end_i:
                 longest_match_end_i = chunk_start_i + 1
                 longest_match_lexical_id: Optional[str] = None

                 for j in range(chunk_end_i, chunk_start_i, -1):
                     surface = text[boundaries[chunk_start_i]:boundaries[j]]
                     lexical_id = self.lexicon.lookup(surface)
                     if lexical_id is not None:
                         longest_match_end_i = j
                         longest_match_lexical_id = lexical_id
                         break

                 # Extract the token
                 token_surface = text[boundaries[chunk_start_i]:boundaries[longest_match_end_i]]

                 # If we didn't find it in the dictionary and it's multiple chars, just emit it as one chunk
                 # or fall back to single chars. We fall back to single clusters to avoid inventing readings
                 # but actually, if it's all same script and not in dict, breaking it down to clusters or keeping as chunk?
                 # Issue says: "Preserve Japanese script boundaries and candidate lexical decomposition without inventing readings."
                 # So we emit the matched candidates, and un-matched parts as single clusters.

                 tokens.append(Token(
                     surface=token_surface,
                     start_offset=boundaries[chunk_start_i],
                     end_offset=boundaries[longest_match_end_i],
                     lexical_id=longest_match_lexical_id,
                     is_ambiguous=False
                 ))
                 chunk_start_i = longest_match_end_i

            i = chunk_end_i

        return TokenizationResult(tokens=tokens)
