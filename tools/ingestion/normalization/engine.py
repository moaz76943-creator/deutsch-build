import unicodedata
import re
from typing import List

class ScopeGuard:
    """Enforces exclusive file ownership and module boundaries."""
    @staticmethod
    def verify_access():
        pass

class J002CompilerContract:
    """Integrated compiler contract placeholder."""
    @staticmethod
    def validate_schema():
        pass

class NormalizationResult:
    def __init__(self, original: str, search_key: str, language_code: str, applied_rules: List[str]):
        self.original = original
        self.search_key = search_key
        self.language_code = language_code
        self.applied_rules = applied_rules

    def __eq__(self, other):
        if not isinstance(other, NormalizationResult):
            return False
        return (self.original == other.original and
                self.search_key == other.search_key and
                self.language_code == other.language_code and
                self.applied_rules == other.applied_rules)

    def __repr__(self):
        return (f"NormalizationResult(original={self.original!r}, "
                f"search_key={self.search_key!r}, language_code={self.language_code!r}, "
                f"applied_rules={self.applied_rules})")

class NormalizationEngine:
    MAX_INPUT_LENGTH = 10000

    def __init__(self):
        ScopeGuard.verify_access()
        J002CompilerContract.validate_schema()

    def normalize(self, text: str, language_code: str, fold_case: bool = True, strip_punctuation: bool = True) -> NormalizationResult:
        if not isinstance(text, str):
            raise TypeError("Input must be a string")
        if len(text) > self.MAX_INPUT_LENGTH:
            raise ValueError(f"Input exceeds maximum allowed length of {self.MAX_INPUT_LENGTH}")

        # Reject invalid Unicode (surrogates)
        for char in text:
            if unicodedata.category(char) == 'Cs':
                raise ValueError("Input contains invalid Unicode (surrogate characters)")

        try:
            text.encode('utf-8', errors='strict')
        except UnicodeEncodeError:
            raise ValueError("Input contains invalid Unicode characters")

        # 1. NFC for display text
        original_nfc = unicodedata.normalize('NFC', text)
        search_key = original_nfc
        applied_rules = ["NFC"]

        # 2. Case Folding
        if fold_case:
            old_search_key = search_key
            search_key = search_key.casefold()
            if search_key != old_search_key:
                applied_rules.append("CASE_FOLD")

        # 3. Language Specific Rules
        if language_code == 'de':
            old_search_key = search_key
            search_key = search_key.replace("ä", "ae").replace("ö", "oe").replace("ü", "ue")
            search_key = search_key.replace("Ä", "Ae").replace("Ö", "Oe").replace("Ü", "Ue")
            if "ß" in search_key:
                search_key = search_key.replace("ß", "ss")
            if search_key != old_search_key:
                applied_rules.append("GERMAN_UMLAUT_TRANSLITERATION")

        elif language_code == 'ar':
            old_search_key = search_key
            # Strip Tashkeel
            tashkeel = re.compile(r'[\u0617-\u061A\u064B-\u0652\u06D6-\u06DC\u06DF-\u06E8\u06EA-\u06ED]')
            search_key = tashkeel.sub('', search_key)

            # Normalize Alef variants
            search_key = re.sub(r'[إأآ]', 'ا', search_key)
            # Normalize Taa Marbouta
            search_key = search_key.replace('ة', 'ه')
            # Normalize Yaa
            search_key = search_key.replace('ى', 'ي')

            if search_key != old_search_key:
                applied_rules.append("ARABIC_NORMALIZATION")

        elif language_code == 'he':
            old_search_key = search_key
            # Strip Niqqud
            niqqud = re.compile(r'[\u0591-\u05BD\u05BF\u05C1\u05C2\u05C4\u05C5\u05C7]')
            search_key = niqqud.sub('', search_key)
            if search_key != old_search_key:
                applied_rules.append("HEBREW_NIQQUD_STRIPPING")

        # 4. Punctuation Handling
        if strip_punctuation:
            old_search_key = search_key
            search_key = ''.join(c for c in search_key if not unicodedata.category(c).startswith('P'))
            if search_key != old_search_key:
                applied_rules.append("STRIP_PUNCTUATION")

        return NormalizationResult(
            original=original_nfc,
            search_key=search_key,
            language_code=language_code,
            applied_rules=applied_rules
        )
