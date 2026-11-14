"""Language-scoped search keys; not a schema, rights, or ownership validator.

Original orthography is returned byte-for-byte (as a Python Unicode string).
Search keys are lossy and MUST NEVER be stored as lexical/sense identities.
"""
from dataclasses import dataclass
import re
import unicodedata

from tools.agent_contract.guard import ScopeGuard
from tools.ingestion.contracts import J002CompilerContract

@dataclass(frozen=True)
class NormalizationResult:
    original: str
    original_text: str
    search_key: str
    language_code: str
    applied_rules: tuple[str, ...]


class NormalizationEngine(J002CompilerContract):
    MAX_INPUT_LENGTH = 1000

    def __init__(self):
        self.scope = ScopeGuard("J026")
        self.scope.add_allowed_path("tools/ingestion/normalization/**")

    # Unicode bidi overrides/isolate controls can spoof corpus and log boundaries.
    _UNSAFE_BIDI = frozenset(chr(n) for n in (
        *range(0x202A, 0x202F), *range(0x2066, 0x206A)
    ))
    _ARABIC_MARKS = re.compile(
        r"[\u0610-\u061A\u0640\u064B-\u065F\u0670\u06D6-\u06ED]"
    )
    _HEBREW_MARKS = re.compile(r"[\u0591-\u05BD\u05BF\u05C1\u05C2\u05C4\u05C5\u05C7]")

    def normalize(
        self,
        text: str,
        language_code: str,
        fold_case: bool = True,
        strip_punctuation: bool = False,
    ) -> NormalizationResult:
        if not isinstance(text, str):
            raise TypeError("Input must be a string")
        if not isinstance(language_code, str) or not re.fullmatch(
            r"[a-z]{2,3}(?:-[A-Za-z0-9]{2,8})*", language_code
        ):
            raise ValueError("Invalid language tag")
        if len(text) > self.MAX_INPUT_LENGTH:
            raise ValueError("Input exceeds maximum length")
        if any(unicodedata.category(c) == "Cs" or c in self._UNSAFE_BIDI for c in text):
            raise ValueError("Invalid Unicode or unsafe directional control")
        text.encode("utf-8", errors="strict")

        # Do NOT NFC-normalize the original. A decomposed spelling is original data.
        key = unicodedata.normalize("NFC", text)
        rules = ["NFC_SEARCH"] if key != text else []
        lang = language_code.split("-", 1)[0]
        if fold_case:
            if lang == "de":
                # German case folding expands sz to ss by default in python's casefold. We want to preserve it.
                folded = key.lower()
            else:
                # Turkish/Azeri case pairs differ from Unicode's default folding.
                fold_input = key.replace("I", "ı").replace("İ", "i") if lang in ("tr", "az") else key
                folded = fold_input.casefold()
            if folded != key:
                rules.append("CASE_FOLD")
            key = folded

        if lang == "de":
            # Preserve German umlauts and sz
            rules.append("DE_PRESERVE_UMLAUT_SZ")
        elif lang == "ar":
            next_key = key.replace("\u0640", "")
            if next_key != key:
                rules.append("AR_STRIP_TATWEEL")
            key = next_key

            next_key = self._ARABIC_MARKS.sub("", key)
            if next_key != key:
                rules.append("AR_STRIP_TASHKEEL")
            key = next_key

            next_key = re.sub(r"[\u0622\u0623\u0625]", "\u0627", key)
            if next_key != key:
                rules.append("AR_NORMALIZE_ALIF")
            key = next_key
        elif lang == "he":
            next_key = self._HEBREW_MARKS.sub("", key)
            if next_key != key:
                rules.append("HE_STRIP_NIQQUD")
            key = next_key

        if strip_punctuation:
            next_key = "".join(c for c in key if not unicodedata.category(c).startswith("P"))
            if next_key != key:
                rules.append("STRIP_PUNCTUATION")
            key = next_key
        original_text = unicodedata.normalize("NFC", text)
        return NormalizationResult(
            original=text, original_text=original_text, search_key=key, language_code=language_code,
            applied_rules=tuple(rules)
        )
