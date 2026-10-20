"""Language-scoped search keys; not a schema, rights, or ownership validator.

Original orthography is returned byte-for-byte (as a Python Unicode string).
Search keys are lossy and MUST NEVER be stored as lexical/sense identities.
"""
from dataclasses import dataclass
import re
import unicodedata
from tools.automation.scope_guard import ScopeGuard

try:
    from tools.ingestion.contracts import J002CompilerContract
except ImportError:
    class J002CompilerContract:
        pass

_guard = ScopeGuard("J026")
_guard.add_allowed_path("tools/ingestion/normalization/**")
if not _guard.request_ownership("tools/ingestion/normalization/engine.py"):
    raise RuntimeError("ScopeGuard ownership denied")


@dataclass(frozen=True)
class NormalizationResult:
    original: str
    nfc_display: str
    search_key: str
    language_code: str
    applied_rules: tuple[str, ...]


class NormalizationEngine(J002CompilerContract):
    MAX_INPUT_LENGTH = 10000
    # Unicode bidi overrides/isolate controls can spoof corpus and log boundaries.
    _UNSAFE_BIDI = frozenset(chr(n) for n in (
        *range(0x202A, 0x202F), *range(0x2066, 0x206A)
    ))
    _ARABIC_TASHKEEL = re.compile(
        r"[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06ED]"
    )
    _ARABIC_TATWEEL = re.compile(r"\u0640")
    _ARABIC_ALIF = re.compile(r"[أإآٱ]")
    _HEBREW_MARKS = re.compile(r"[\u0591-\u05BD\u05BF\u05C1\u05C2\u05C4\u05C5\u05C7]")

    def normalize(
        self,
        text: str,
        language_code: str,
        fold_case: bool = True,
        strip_punctuation: bool = True,
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
            # Turkish/Azeri case pairs differ from Unicode's default folding.
            fold_input = key.replace("I", "ı").replace("İ", "i") if lang in ("tr", "az") else key
            folded = fold_input.casefold()
            if folded != key:
                rules.append("CASE_FOLD")
            key = folded

        if lang == "de":
            # Only German keys get conventional umlaut expansion.
            next_key = key.translate(str.maketrans({"ä": "ae", "ö": "oe", "ü": "ue"}))
            if next_key != key:
                rules.append("GERMAN_UMLAUT_SEARCH_ALIAS")
            key = next_key
        elif lang == "ar":
            next_key = self._ARABIC_TATWEEL.sub("", key)
            if next_key != key:
                rules.append("AR_STRIP_TATWEEL")
                key = next_key
            next_key = self._ARABIC_TASHKEEL.sub("", key)
            if next_key != key:
                rules.append("AR_STRIP_TASHKEEL")
                key = next_key
            next_key = self._ARABIC_ALIF.sub("ا", key)
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
        return NormalizationResult(
            original=text, nfc_display=unicodedata.normalize("NFC", text), search_key=key, language_code=language_code,
            applied_rules=tuple(rules)
        )
