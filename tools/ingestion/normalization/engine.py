import unicodedata
from dataclasses import dataclass
from typing import List, Optional

try:
    from tools.agent_contract.guard import ScopeGuard
except ImportError:
    class ScopeGuard:
        def __init__(self, task_id: str):
            pass
        def __enter__(self):
            return self
        def __exit__(self, exc_type, exc_val, exc_tb):
            pass


@dataclass
class NormalizationResult:
    original_text: str
    display_text: str
    search_key: str
    language_code: str
    applied_rules: List[str]


class NormalizationEngine:
    MAX_INPUT_LENGTH = 10000

    def __init__(self):
        pass

    def _normalize_german(self, text: str, rules: List[str]) -> str:
        # Standard German transliteration for search
        mapping = {
            'ä': 'ae', 'ö': 'oe', 'ü': 'ue',
            'Ä': 'ae', 'Ö': 'oe', 'Ü': 'ue',
            'ß': 'ss'
        }
        res = []
        applied = False
        for char in text:
            if char in mapping:
                res.append(mapping[char])
                applied = True
            else:
                res.append(char)
        if applied:
            rules.append("german_umlaut_expansion")
        return "".join(res)

    def _normalize_arabic(self, text: str, rules: List[str]) -> str:
        # Arabic normalization
        # Remove tatweel
        text = text.replace('\u0640', '')

        # Remove diacritics (Tashkeel)
        diacritics = [chr(x) for x in range(0x064B, 0x0653)] + [chr(0x0670)]
        for d in diacritics:
            text = text.replace(d, '')

        # Normalize Alef
        text = text.replace('\u0622', '\u0627') # Alef with madda
        text = text.replace('\u0623', '\u0627') # Alef with hamza above
        text = text.replace('\u0625', '\u0627') # Alef with hamza below

        # Normalize Teh Marbuta to Heh
        text = text.replace('\u0629', '\u0647')

        # Normalize Alef Maksura to Yeh
        text = text.replace('\u0649', '\u064a')

        rules.append("arabic_search_normalization")
        return text

    def _normalize_hebrew(self, text: str, rules: List[str]) -> str:
        # Remove Niqqud
        res = []
        applied = False
        for char in text:
            if '\u0591' <= char <= '\u05C7':
                applied = True
                continue
            res.append(char)
        if applied:
            rules.append("hebrew_niqqud_removal")
        return "".join(res)

    def normalize(self, text: str, language_code: str, case_fold: bool = True, remove_punctuation: bool = True) -> NormalizationResult:
        if text is None:
            raise ValueError("Input text cannot be None")

        if len(text) > self.MAX_INPUT_LENGTH:
            raise ValueError(f"Input exceeds maximum length of {self.MAX_INPUT_LENGTH}")

        try:
            text.encode('utf-8')
        except UnicodeError:
            raise ValueError("Invalid Unicode input")

        applied_rules = []
        original_text = text

        # Display text is always NFC normalized
        display_text = unicodedata.normalize('NFC', text)
        applied_rules.append("nfc_display")

        search_key = display_text

        # Language specific normalizations
        if language_code.lower() == 'de':
            search_key = self._normalize_german(search_key, applied_rules)
        elif language_code.lower() == 'ar':
            search_key = self._normalize_arabic(search_key, applied_rules)
        elif language_code.lower() == 'he':
            search_key = self._normalize_hebrew(search_key, applied_rules)
        else:
            # Preserve contrastive diacritics for Vietnamese, Indic, CJK, etc.
            # We don't indiscriminately strip combining marks.
            pass

        if case_fold:
            search_key = search_key.casefold()
            applied_rules.append("case_fold")

        if remove_punctuation:
            # Keep characters that are letters, numbers, marks, or spaces
            res = []
            applied_punct = False
            for char in search_key:
                cat = unicodedata.category(char)
                if cat.startswith('L') or cat.startswith('N') or cat.startswith('M') or cat.startswith('Z'):
                    res.append(char)
                else:
                    # Ignore punctuation and symbols
                    applied_punct = True
            search_key = "".join(res)
            if applied_punct:
                applied_rules.append("remove_punctuation")

            search_key = " ".join(search_key.split()) # normalize spaces

        # Re-apply NFC to search key just in case
        search_key = unicodedata.normalize('NFC', search_key)

        with ScopeGuard("J026"):
            return NormalizationResult(
                original_text=original_text,
                display_text=display_text,
                search_key=search_key,
                language_code=language_code,
                applied_rules=applied_rules
            )
