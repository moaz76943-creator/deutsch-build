#!/usr/bin/env python3
"""Deterministic, offline Unicode sort keys for SQLite TEXT COLLATE BINARY.

Keys are lowercase ASCII hexadecimal, with one fixed-width six-digit weight
per normalized code point. Compare the returned strings with SQLite's BINARY
collation (not NOCASE). Keep a stable lexical ID as a secondary ORDER BY key
when two spellings intentionally normalize to the same primary sort key.

Tailorings cover German, Swedish, Arabic, Russian and other specified alphabets;
other locales receive a deterministic Unicode-codepoint fallback. This is NOT
an implementation of the full Unicode Collation Algorithm/CLDR for 100 locales:
accurate locale-specific ordering outside the mapped alphabets requires a
versioned, locally bundled collation dataset. Sort keys are an ingestion format;
regenerate all keys together when changing these rules.

No network, system locale, operating-system collation, or third-party packages.
"""
from __future__ import annotations

import unicodedata
from collections.abc import Iterable, Iterator

# Explicit alphabetical orders, not Python/SQLite code point ordering.
_LATIN = "abcdefghijklmnopqrstuvwxyz"
_ALPHABETS = {
    "ar": "ءابتثجحخدذرزسشصضطظعغفقكلمنهوي",
    "ru": "абвгдеёжзийклмнопрстуфхцчшщъыьэюя",
    "uk": "абвгґдеєжзиіїйклмнопрстуфхцчшщьюя",
    "be": "абвгдеёжзійклмнопрстуўфхцчшыьэюя",
    "bg": "абвгдежзийклмнопрстуфхцчшщъьюя",
    "sr": "абвгдђежзијклљмнњопрстћуфхцчџш",
    "mk": "абвгдѓеёжзијклљмнњопрстќуфхцчџш",
    "el": "αβγδεζηθικλμνξοπρστυφχψω",
    "hi": "अआइईउऊऋॠऌॡएऐओऔकखगघङचछजझञटठडढणतथदधनपफबभमयरलवशषसह",
    "sv": _LATIN + "åäö",
    "da": _LATIN + "æøå",
    "no": _LATIN + "æøå",
    "es": "abcdefghijklmnñopqrstuvwxyz",
    "tr": "abcçdefgğhıijklmnoöprsştuüvyz",
}
for _devanagari_locale in ("mr", "ne", "sa"):
    _ALPHABETS[_devanagari_locale] = _ALPHABETS["hi"]

_WEIGHTS = {
    locale: {char: position + 1 for position, char in enumerate(alphabet)}
    for locale, alphabet in _ALPHABETS.items()
}
_LATIN_WEIGHTS = {char: position + 1 for position, char in enumerate(_LATIN)}
# 0x200000+codepoint is less than 0x310000 and fits in six hex digits.
_UNMAPPED_WEIGHT = 0x200000
_ALEF_VARIANTS = dict.fromkeys("أإآٱٲٳٵ", "ا")
_LATIN_SUBSTITUTIONS = {
    "æ": "ae", "œ": "oe", "ø": "o", "ł": "l", "đ": "d",
    "ð": "d", "þ": "th", "ħ": "h",
}
_GERMAN_EXPANSIONS = {"ä": "ae", "ö": "oe", "ü": "ue"}
_ARABIC_TATWEEL = "\u0640"


def _strip_latin_accents(text: str, *, preserve: frozenset[str] = frozenset()) -> str:
    """Fold Latin diacritics but leave non-Latin combining signs alone."""
    output: list[str] = []
    previous_latin = False
    for char in text:
        if char in preserve:
            output.append(char)
            previous_latin = True
        elif char in _LATIN_SUBSTITUTIONS:
            output.append(_LATIN_SUBSTITUTIONS[char])
            previous_latin = True
        elif "LATIN" in unicodedata.name(char, ""):
            decomposition = unicodedata.normalize("NFKD", char)
            output.append("".join(
                part for part in decomposition
                if not unicodedata.category(part).startswith("M")
            ))
            previous_latin = True
        elif unicodedata.category(char).startswith("M") and previous_latin:
            # E.g. the remaining combining dot from lowercasing LATIN İ.
            continue
        else:
            output.append(char)
            previous_latin = False
    return "".join(output)


def _normalize(word: str, language: str) -> str:
    # NFKC canonicalizes compatibility/presentation forms and NFC combines
    # decomposed letter+accent pairs before locale-specific processing.
    word = unicodedata.normalize("NFKC", word)
    if language == "tr":
        # Unicode default casefold maps both I and İ to i-like sequences;
        # Turkish instead distinguishes dotless ı from dotted i.
        word = word.replace("I", "ı").replace("İ", "i")
    word = unicodedata.normalize("NFC", word.casefold())

    if language == "ar":
        return "".join(
            _ALEF_VARIANTS.get(char, char)
            for char in word
            if char != _ARABIC_TATWEEL
            and not (
                0x0600 <= ord(char) <= 0x08FF
                and unicodedata.category(char).startswith("M")
            )
        )

    if language in _CYRILLIC_LOCALES:
        # Stress accents are not alphabetic; keep ё and й DISTINCT from е/и.
        return word.replace("\u0301", "").replace("\u0341", "")

    if language == "el":
        # Greek accents/diaeresis are secondary here; ς and σ share a key.
        decomposed = unicodedata.normalize("NFD", word)
        return "".join(
            "σ" if char == "ς" else char
            for char in decomposed
            if not unicodedata.category(char).startswith("M")
        )

    if language in _DEVANAGARI_LOCALES:
        # Vowel signs, virama and nukta are meaningful combining characters.
        return word

    if language == "de":
        for accented, replacement in _GERMAN_EXPANSIONS.items():
            word = word.replace(accented, replacement)
        return _strip_latin_accents(word)
    if language == "sv":
        return _strip_latin_accents(word, preserve=frozenset("åäö"))
    if language in ("da", "no"):
        return _strip_latin_accents(word, preserve=frozenset("æøå"))
    if language == "es":
        return _strip_latin_accents(word, preserve=frozenset("ñ"))
    if language == "tr":
        return _strip_latin_accents(word, preserve=frozenset("çğıöşü"))

    # Cross-language fallback: deterministic but not CLDR-tailored. Preserve
    # non-Latin combining signs to avoid deleting script-dependent vowels.
    return _strip_latin_accents(word)


_CYRILLIC_LOCALES = frozenset(("ru", "uk", "be", "bg", "sr", "mk"))
_DEVANAGARI_LOCALES = frozenset(("hi", "mr", "ne", "sa"))


def generate_sort_key(word: str, lang_code: str) -> str:
    """Return a deterministic ASCII key for ORDER BY sort_key COLLATE BINARY.

    lang_code accepts language subtags and BCP-47-style tags (e.g. de-DE,
    ar-SA), case-insensitively. Primary-equivalent forms deliberately share
    a key; use ORDER BY sort_key, stable_id for deterministic tie-breaking.
    """
    if not isinstance(word, str):
        raise TypeError("word must be a string")
    if not isinstance(lang_code, str):
        raise TypeError("lang_code must be a string")
    language = lang_code.strip().replace("_", "-").split("-", 1)[0].lower()
    if not language or not language.isalpha():
        raise ValueError("lang_code must contain a language subtag")

    alphabet = _WEIGHTS.get(language, _LATIN_WEIGHTS)
    normalized = _normalize(word, language)
    return "".join(
        f"{alphabet.get(char, _UNMAPPED_WEIGHT + ord(char)):06x}"
        for char in normalized
    )


def generate_sort_keys(entries: Iterable[tuple[str, str]]) -> Iterator[str]:
    """Lazily generate keys for (word, lang_code) pairs in O(1) extra space.

    Consume in batches or write directly into an ingestion cursor. This does
    not modify SQLite schemas or existing packs.
    """
    for word, lang_code in entries:
        yield generate_sort_key(word, lang_code)
