import unicodedata
from typing import List, Dict, Set
from tools.morphology.tokenization.interfaces import (
    LanguageTokenizer,
    Token,
    TokenizationResult
)

MAX_INPUT_LENGTH = 10000
MAX_CANDIDATE_EVALUATIONS_PER_DOC = 50000

class SegmentationEngine:
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
            return TokenizationResult(tokens=[], unavailable_tokenization=True)

        return tokenizer.tokenize(text)

class CJKThaiTokenizer(LanguageTokenizer):
    """
    Tokenizer for CJK and Thai utilizing bounded longest-match dictionary approach,
    ensuring Unicode combining character integrity and script boundaries.
    """
    def __init__(self, dictionary: Set[str]):
        self.dictionary = dictionary

    def _is_combining(self, char: str) -> bool:
        category = unicodedata.category(char)
        return category.startswith('M') or ('\u0e31' <= char <= '\u0e3a') or ('\u0e47' <= char <= '\u0e4e')

    def _get_grapheme_clusters(self, text: str) -> List[str]:
        clusters = []
        if not text:
            return clusters

        current_cluster = text[0]
        for char in text[1:]:
            if self._is_combining(char):
                current_cluster += char
            else:
                clusters.append(current_cluster)
                current_cluster = char

        if current_cluster:
            clusters.append(current_cluster)
        return clusters

    def tokenize(self, text: str) -> TokenizationResult:
        if not text:
            return TokenizationResult(tokens=[])

        clusters = self._get_grapheme_clusters(text)
        cluster_offsets = []
        current_offset = 0
        for cluster in clusters:
            cluster_offsets.append((current_offset, current_offset + len(cluster)))
            current_offset += len(cluster)

        tokens: List[Token] = []
        idx = 0

        while idx < len(clusters):
            match_found = False
            max_len = min(len(clusters) - idx, 20)

            best_match_len = 0
            is_ambiguous = False

            token_evaluations = 0
            MAX_EVALS_PER_TOKEN = 100

            for length in range(max_len, 0, -1):
                token_evaluations += 1
                if token_evaluations > MAX_EVALS_PER_TOKEN:
                    break

                candidate = "".join(clusters[idx:idx+length])
                if candidate in self.dictionary:
                    # Check for ambiguity
                    for sub_len in range(length - 1, 0, -1):
                        sub_candidate = "".join(clusters[idx:idx+sub_len])
                        if sub_candidate in self.dictionary:
                            is_ambiguous = True
                            break
                    for sub_len in range(1, length):
                        sub_candidate = "".join(clusters[idx+sub_len:idx+length])
                        if sub_candidate in self.dictionary:
                            is_ambiguous = True
                            break

                    best_match_len = length
                    match_found = True
                    break

            if match_found:
                start_offset = cluster_offsets[idx][0]
                end_offset = cluster_offsets[idx + best_match_len - 1][1]
                token_text = "".join(clusters[idx:idx+best_match_len])
                tokens.append(Token(text=token_text, start=start_offset, end=end_offset, is_ambiguous=is_ambiguous))
                idx += best_match_len
            else:
                # OOV Fallback: fallback 1 cluster to allow longest match to pick up the next word
                fallback_len = 1
                start_offset = cluster_offsets[idx][0]
                end_offset = cluster_offsets[idx + fallback_len - 1][1]
                token_text = "".join(clusters[idx:idx+fallback_len])
                tokens.append(Token(text=token_text, start=start_offset, end=end_offset, is_ambiguous=False))
                idx += fallback_len

        return TokenizationResult(tokens=tokens)
