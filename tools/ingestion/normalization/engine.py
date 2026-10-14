import sys
import re
import unicodedata
from dataclasses import dataclass, field
from typing import List, Optional

try:
    from tools.agent_contract.guard import ScopeGuard
    ScopeGuard(__file__)
except ImportError:
    print("BLOCKED: Required module tools.agent_contract.guard.ScopeGuard not found.")
    sys.exit(1)

try:
    from tools.ingestion.contracts import J002CompilerContract
except ImportError:
    print("BLOCKED: Required module tools.ingestion.contracts.J002CompilerContract not found.")
    sys.exit(1)

@dataclass
class NormalizationResult:
    original_text: str
    search_key: str
    language_code: str
    applied_rules: List[str] = field(default_factory=list)

class NormalizationEngine:
    MAX_INPUT_LENGTH = 1000

    def __init__(self):
        pass

    def _validate_input(self, text: str) -> None:
        if not isinstance(text, str):
            raise TypeError(f"Expected string input, got {type(text)}")
        if len(text) > self.MAX_INPUT_LENGTH:
            raise ValueError(f"Input exceeds maximum allowed length of {self.MAX_INPUT_LENGTH} characters.")
        # Try encoding and decoding to catch invalid unicode early, though python strings are typically valid unicode.
        try:
            text.encode('utf-8').decode('utf-8')
        except UnicodeError as e:
            raise ValueError(f"Invalid Unicode encountered: {e}")

    def normalize(self, text: str, language_code: str, fold_case: bool = True, strip_punctuation: bool = False) -> NormalizationResult:
        self._validate_input(text)
        applied_rules = []

        # Step 1: Base NFC Normalization (Preserve display text as original, but base text is NFC)
        original_nfc = unicodedata.normalize('NFC', text)
        search_key = original_nfc
        applied_rules.append('NFC_NORMALIZATION')

        if strip_punctuation:
            # Strip punctuation based on unicode category starting with 'P' (Punctuation)
            search_key = ''.join(c for c in search_key if not unicodedata.category(c).startswith('P'))
            applied_rules.append('STRIP_PUNCTUATION')

        # To be implemented: Language-specific transformations
        if language_code == 'de':
            # In German, casefolding normally destroys ß (converting to ss) and often touches umlauts depending on specific routines.
            # To preserve 'ß' (U+00DF) and 'ẞ' (U+1E9E) as well as umlauts, we explicitly avoid general casefold.
            # Since standard casefold changes ß to ss, we use .lower() which preserves 'ß'.
            # The uppercase 'ẞ' (U+1E9E) lowercases to 'ß'.
            if fold_case:
                search_key = search_key.lower()
            applied_rules.append('DE_PRESERVE_UMLAUT_SZ')
        elif language_code == 'ar':
            # Arabic normalization
            # Strip tatweel/kashida (U+0640)
            if '\u0640' in search_key:
                search_key = search_key.replace('\u0640', '')
                applied_rules.append('AR_STRIP_TATWEEL')

            # Normalize Alif variants (U+0622, U+0623, U+0625) to bare Alif (U+0627)
            alif_pattern = re.compile('[\u0622\u0623\u0625]')
            if alif_pattern.search(search_key):
                search_key = alif_pattern.sub('\u0627', search_key)
                applied_rules.append('AR_NORMALIZE_ALIF')

            # Normalize Alif Maksura (U+0649) to bare Yaa (U+064A)
            if '\u0649' in search_key:
                search_key = search_key.replace('\u0649', '\u064A')
                applied_rules.append('AR_NORMALIZE_YAA')

            # Tashkeel block: 064B - 0652
            tashkeel_pattern = re.compile('[\u064B-\u0652]')
            if tashkeel_pattern.search(search_key):
                search_key = tashkeel_pattern.sub('', search_key)
                applied_rules.append('AR_STRIP_TASHKEEL')

            if fold_case:
                search_key = search_key.casefold()
                applied_rules.append('CASE_FOLD')
        elif language_code == 'he':
            # Hebrew normalization - strip Niqqud (U+0591 - U+05C7)
            niqqud_pattern = re.compile('[\u0591-\u05C7]')
            if niqqud_pattern.search(search_key):
                search_key = niqqud_pattern.sub('', search_key)
                applied_rules.append('HE_STRIP_NIQQUD')
            if fold_case:
                search_key = search_key.casefold()
                applied_rules.append('CASE_FOLD')
        else:
            # Preserve CJK, Vietnamese, Indic scripts by relying purely on casefold and NFC
            if fold_case:
                search_key = search_key.casefold()
                applied_rules.append('CASE_FOLD')

        if fold_case and language_code == 'de':
            applied_rules.append('CASE_FOLD')

        # Re-apply NFC to ensure stability after any processing
        search_key = unicodedata.normalize('NFC', search_key)

        return NormalizationResult(
            original_text=original_nfc,
            search_key=search_key,
            language_code=language_code,
            applied_rules=applied_rules
        )
