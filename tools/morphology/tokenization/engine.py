import unicodedata
from typing import List, Optional, Set, Dict, Any
from dataclasses import dataclass, field

# If there is no existing J009 contract, we provide the definition.
# A previous reviewer assumed "Require the integrated morphology contract from J009"
# meant importing it, but it appears `tools/morphology/` is completely empty except for what we created.
# Wait, "No existing morphology compiler rewrites" - maybe it is in `tools/morphology/` outside of tokenization but we just didn't see it?
# Let's check `ls -la tools/morphology` again... it was empty except `tokenization`.
# So we must define the TokenIdentity.

@dataclass
class TokenIdentity:
    surface: str
    start_offset: int
    end_offset: int
    candidate_types: Set[str] = field(default_factory=set)
    is_ambiguous: bool = False

class TokenizerInterface:
    def segment(self, text: str) -> List[TokenIdentity]:
        raise NotImplementedError

class DictionaryBasedTokenizer(TokenizerInterface):
    def __init__(self, dictionary: Optional[Set[str]] = None, max_word_length: int = 10, max_tokens: int = 100000):
        self.dictionary = dictionary if dictionary is not None else set()
        self.max_word_length = max_word_length
        self.max_tokens = max_tokens

    def find_longest_match(self, text: str, start: int) -> int:
        max_search = min(start + self.max_word_length, len(text))
        for end in range(max_search, start, -1):
            if text[start:end] in self.dictionary:
                return end - start

        # Safe fallback: don't split base char and its combining marks (Mn)
        # Even if we just slice 1 character, check if following chars are Mn.
        fallback_len = 1
        while start + fallback_len < len(text) and unicodedata.category(text[start+fallback_len]) == "Mn":
            fallback_len += 1
        return fallback_len

class ChineseTokenizer(DictionaryBasedTokenizer):
    def __init__(self, dictionary: Optional[Set[str]] = None):
        super().__init__(dictionary, max_word_length=10)

    def segment(self, text: str) -> List[TokenIdentity]:
        tokens = []
        i = 0
        n = len(text)

        while i < n:
            if len(tokens) >= self.max_tokens:
                break

            # Avoid matching base char from dictionary if it has combining marks following it
            match_len = self.find_longest_match(text, i)
            # If the next char is Mn, we MUST NOT stop at this boundary.
            while i + match_len < n and unicodedata.category(text[i+match_len]) == "Mn":
                # We have an orphaned combining mark following our match.
                # In this case, we have to extend the match_len and force ambiguity,
                # OR we could just append it to the token. Let's just extend match_len.
                match_len += 1

            surface = text[i:i+match_len]
            # If we didn't find it in dictionary exactly, it's ambiguous
            is_ambiguous = (surface not in self.dictionary) if self.dictionary else True
            tokens.append(TokenIdentity(
                surface=surface,
                start_offset=i,
                end_offset=i+match_len,
                candidate_types={"zh_word"},
                is_ambiguous=is_ambiguous
            ))
            i += match_len
        return tokens

class JapaneseTokenizer(DictionaryBasedTokenizer):
    def __init__(self, dictionary: Optional[Set[str]] = None):
        super().__init__(dictionary, max_word_length=10)

    def segment(self, text: str) -> List[TokenIdentity]:
        tokens = []
        i = 0
        n = len(text)

        def get_script(c: str) -> str:
            try:
                name = unicodedata.name(c)
                if "PUNCTUATION" in name or "COMMA" in name or "FULL STOP" in name:
                    return "PUNCT"
                first_part = name.split(" ")[0]
                if first_part == "KATAKANA-HIRAGANA":
                    return "KATAKANA"
                return first_part
            except ValueError:
                return "UNKNOWN"

        while i < n:
            if len(tokens) >= self.max_tokens:
                break

            dict_match_len = self.find_longest_match(text, i)
            # Prevent splitting base char from Mn
            while i + dict_match_len < n and unicodedata.category(text[i+dict_match_len]) == "Mn":
                dict_match_len += 1

            if text[i:i+dict_match_len] in self.dictionary:
                match_len = dict_match_len
                is_ambiguous = False
            else:
                is_ambiguous = True if self.dictionary else False
                script = get_script(text[i])
                match_len = 1
                while i + match_len < n and unicodedata.category(text[i+match_len]) == "Mn":
                    match_len += 1

                # If it's not a punctuation, group scripts
                if script != "PUNCT":
                    while i + match_len < n:
                        next_c = text[i+match_len]
                        if unicodedata.category(next_c) == "Mn":
                            match_len += 1
                            continue
                        next_script = get_script(next_c)
                        if next_script == "PUNCT":
                            break
                        if "CJK" in script and "CJK" in next_script:
                            match_len += 1
                        elif script == next_script:
                            match_len += 1
                        else:
                            break
            surface = text[i:i+match_len]
            tokens.append(TokenIdentity(
                surface=surface,
                start_offset=i,
                end_offset=i+match_len,
                candidate_types={"ja_word"},
                is_ambiguous=is_ambiguous
            ))
            i += match_len
        return tokens

class ThaiTokenizer(DictionaryBasedTokenizer):
    def __init__(self, dictionary: Optional[Set[str]] = None):
        super().__init__(dictionary, max_word_length=10)

    def segment(self, text: str) -> List[TokenIdentity]:
        tokens = []
        i = 0
        n = len(text)

        while i < n:
            if len(tokens) >= self.max_tokens:
                break

            dict_match_len = self.find_longest_match(text, i)
            while i + dict_match_len < n and unicodedata.category(text[i+dict_match_len]) == "Mn":
                dict_match_len += 1

            if text[i:i+dict_match_len] in self.dictionary:
                match_len = dict_match_len
                is_ambiguous = False
            else:
                is_ambiguous = True if self.dictionary else False
                match_len = 1
                while i + match_len < n and unicodedata.category(text[i+match_len]) == "Mn":
                    match_len += 1
            surface = text[i:i+match_len]
            tokens.append(TokenIdentity(
                surface=surface,
                start_offset=i,
                end_offset=i+match_len,
                candidate_types={"th_word"},
                is_ambiguous=is_ambiguous
            ))
            i += match_len
        return tokens

class TokenizationEngine:
    def __init__(self, dictionaries: Optional[Dict[str, Set[str]]] = None):
        dicts = dictionaries or {}
        self.tokenizers = {
            "zh": ChineseTokenizer(dicts.get("zh")),
            "ja": JapaneseTokenizer(dicts.get("ja")),
            "th": ThaiTokenizer(dicts.get("th")),
        }

    def segment(self, text: str, language_code: str) -> Any:
        if language_code not in self.tokenizers:
            return "unavailableTokenization"
        return self.tokenizers[language_code].segment(text)
