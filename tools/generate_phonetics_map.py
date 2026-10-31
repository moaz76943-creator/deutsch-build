#!/usr/bin/env python3
"""Generate a deterministic offline German phonetics map for DEUTSCH بالعربي.

The generated map is intentionally small and dependency-free. IPA is display
metadata for Phonetik training; audio/TTS must speak the exact German
orthography from the ttsText field with the de-DE locale, never the IPA string.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Iterable, NamedTuple


SCHEMA_VERSION = 1
LANGUAGE = "de"
PLAYBACK_LOCALE = "de-DE"
ALLOWED_CEFR_LEVELS = frozenset({"A1", "A2", "B1", "B2"})


class PhoneticsMapError(ValueError):
    """Raised when a phonetics entry would produce unsafe or ambiguous data."""


class Highlight(NamedTuple):
    start: int
    end: int
    grapheme: str
    rule_id: str


class PhoneticEntry(NamedTuple):
    word: str
    cefr: str
    ipa: str
    highlights: tuple[Highlight, ...]


RULES = {
    "de.ch.ich": {
        "graphemes": ["ch"],
        "ipa": "/ç/",
        "learnerNoteAr": "ich-Laut: احتكاك حنكي رقيق، شائع بعد أصوات أمامية مثل i و e.",
    },
    "de.ch.ach": {
        "graphemes": ["ch"],
        "ipa": "/x/",
        "learnerNoteAr": "ach-Laut: احتكاك خلفي، شائع بعد a و o و u و au.",
    },
    "de.sch": {
        "graphemes": ["sch"],
        "ipa": "/ʃ/",
        "learnerNoteAr": "sch تُنطق غالباً مثل ش العربية.",
    },
    "de.eu": {
        "graphemes": ["eu"],
        "ipa": "/ɔʏ̯/",
        "learnerNoteAr": "eu صوت مزدوج واحد؛ لا يُنطق e ثم u منفصلين.",
    },
    "de.aeu": {
        "graphemes": ["äu"],
        "ipa": "/ɔʏ̯/",
        "learnerNoteAr": "äu يطابق غالباً صوت eu: /ɔʏ̯/.",
    },
    "de.st.onset": {
        "graphemes": ["st"],
        "ipa": "/ʃt/",
        "learnerNoteAr": "st في بداية المقطع تُنطق عادة /ʃt/.",
    },
    "de.sp.onset": {
        "graphemes": ["sp"],
        "ipa": "/ʃp/",
        "learnerNoteAr": "sp في بداية المقطع تُنطق عادة /ʃp/.",
    },
}


SEED_ENTRIES = (
    # A1 examples
    PhoneticEntry("ich", "A1", "/ɪç/", (Highlight(1, 3, "ch", "de.ch.ich"),)),
    PhoneticEntry("Buch", "A1", "/buːx/", (Highlight(2, 4, "ch", "de.ch.ach"),)),
    PhoneticEntry("Schule", "A1", "/ˈʃuːlə/", (Highlight(0, 3, "Sch", "de.sch"),)),
    PhoneticEntry(
        "sprechen",
        "A1",
        "/ˈʃpʁɛçn̩/",
        (
            Highlight(0, 2, "sp", "de.sp.onset"),
            Highlight(4, 6, "ch", "de.ch.ich"),
        ),
    ),
    PhoneticEntry("Straße", "A1", "/ˈʃtʁaːsə/", (Highlight(0, 2, "St", "de.st.onset"),)),
    PhoneticEntry("heute", "A1", "/ˈhɔʏ̯tə/", (Highlight(1, 3, "eu", "de.eu"),)),
    PhoneticEntry("Freund", "A1", "/fʁɔʏ̯nt/", (Highlight(2, 4, "eu", "de.eu"),)),
    PhoneticEntry("Sport", "A1", "/ʃpɔʁt/", (Highlight(0, 2, "Sp", "de.sp.onset"),)),
    # A2 examples
    PhoneticEntry("Häuser", "A2", "/ˈhɔʏ̯zɐ/", (Highlight(1, 3, "äu", "de.aeu"),)),
    PhoneticEntry("träumen", "A2", "/ˈtʁɔʏ̯mən/", (Highlight(2, 4, "äu", "de.aeu"),)),
    PhoneticEntry(
        "Geschichte",
        "A2",
        "/ɡəˈʃɪçtə/",
        (
            Highlight(2, 5, "sch", "de.sch"),
            Highlight(6, 8, "ch", "de.ch.ich"),
        ),
    ),
    PhoneticEntry("Frühstück", "A2", "/ˈfʁyːʃtʏk/", (Highlight(4, 6, "st", "de.st.onset"),)),
    PhoneticEntry("später", "A2", "/ˈʃpɛːtɐ/", (Highlight(0, 2, "sp", "de.sp.onset"),)),
    PhoneticEntry(
        "euch",
        "A2",
        "/ɔʏ̯ç/",
        (
            Highlight(0, 2, "eu", "de.eu"),
            Highlight(2, 4, "ch", "de.ch.ich"),
        ),
    ),
    PhoneticEntry("Deutsch", "A2", "/dɔʏ̯tʃ/", (Highlight(1, 3, "eu", "de.eu"),)),
)


def _validate_ipa(ipa: str, word: str) -> None:
    if not isinstance(ipa, str) or len(ipa) < 3 or not ipa.startswith("/") or not ipa.endswith("/"):
        raise PhoneticsMapError(f"IPA for {word!r} must be wrapped in /.../")
    if "\n" in ipa or "\r" in ipa:
        raise PhoneticsMapError(f"IPA for {word!r} must be a single line")


def _validate_entry(entry: PhoneticEntry) -> None:
    if not entry.word or not entry.word.strip():
        raise PhoneticsMapError("Word must be non-empty")
    if entry.word != entry.word.strip():
        raise PhoneticsMapError(f"Word {entry.word!r} must not have surrounding whitespace")
    if entry.cefr not in ALLOWED_CEFR_LEVELS:
        raise PhoneticsMapError(f"Unsupported CEFR level {entry.cefr!r} for {entry.word!r}")

    _validate_ipa(entry.ipa, entry.word)

    occupied: list[tuple[int, int]] = []
    for highlight in entry.highlights:
        if highlight.rule_id not in RULES:
            raise PhoneticsMapError(
                f"Unknown rule {highlight.rule_id!r} for {entry.word!r}"
            )
        if not (0 <= highlight.start < highlight.end <= len(entry.word)):
            raise PhoneticsMapError(f"Invalid highlight bounds for {entry.word!r}")

        actual = entry.word[highlight.start:highlight.end]
        if actual.casefold() != highlight.grapheme.casefold():
            raise PhoneticsMapError(
                f"Highlight {highlight.grapheme!r} does not match {actual!r} in {entry.word!r}"
            )

        allowed = {item.casefold() for item in RULES[highlight.rule_id]["graphemes"]}
        if highlight.grapheme.casefold() not in allowed:
            raise PhoneticsMapError(
                f"Grapheme {highlight.grapheme!r} is incompatible with {highlight.rule_id!r}"
            )

        for start, end in occupied:
            if max(start, highlight.start) < min(end, highlight.end):
                raise PhoneticsMapError(f"Overlapping highlights in {entry.word!r}")
        occupied.append((highlight.start, highlight.end))


def build_phonetics_map(
    entries: Iterable[PhoneticEntry] = SEED_ENTRIES,
) -> dict[str, object]:
    """Validate entries and build a deterministic O(N) lookup map keyed by word."""

    validated_entries = list(entries)
    seen: set[str] = set()
    output_entries: dict[str, object] = {}

    for entry in sorted(validated_entries, key=lambda item: item.word.casefold()):
        _validate_entry(entry)
        lookup_key = entry.word.casefold()
        if lookup_key in seen:
            raise PhoneticsMapError(f"Duplicate word: {entry.word!r}")
        seen.add(lookup_key)

        output_entries[entry.word] = {
            "cefr": entry.cefr,
            "ipa": entry.ipa,
            "ttsText": entry.word,
            "highlights": [
                {
                    "start": highlight.start,
                    "end": highlight.end,
                    "grapheme": highlight.grapheme,
                    "ruleId": highlight.rule_id,
                }
                for highlight in entry.highlights
            ],
        }

    return {
        "schemaVersion": SCHEMA_VERSION,
        "language": LANGUAGE,
        "playbackLocale": PLAYBACK_LOCALE,
        "audio": {
            "speakField": "ttsText",
            "ipaIsDisplayOnly": True,
            "networkRequired": False,
        },
        "rules": RULES,
        "entries": output_entries,
    }


def generate_phonetics_map(
    output_path: Path,
    entries: Iterable[PhoneticEntry] = SEED_ENTRIES,
) -> Path:
    """Validate and atomically write the phonetics map as UTF-8 JSON."""

    payload = build_phonetics_map(entries)
    serialized = json.dumps(
        payload,
        ensure_ascii=False,
        indent=2,
        sort_keys=True,
    ) + "\n"

    output_path = Path(output_path)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    temporary = output_path.with_name(f".{output_path.name}.tmp")
    temporary.write_text(serialized, encoding="utf-8")
    temporary.replace(output_path)
    return output_path


def _parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Generate the offline German IPA/Phonetik lookup map."
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=Path("build/phonetics/phonetics_map.de.json"),
        help="Output JSON path (default: build/phonetics/phonetics_map.de.json).",
    )
    parser.add_argument(
        "--check",
        action="store_true",
        help="Validate the built-in map without writing a file.",
    )
    return parser.parse_args()


def main() -> int:
    args = _parse_args()
    if args.check:
        payload = build_phonetics_map()
        print(f"phonetics map valid: {len(payload['entries'])} entries")
        return 0

    output = generate_phonetics_map(args.output)
    print(output)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
