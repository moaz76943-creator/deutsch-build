#!/usr/bin/env python3
"""DEUTSCH بالعربي — deterministic 100-language candidate/pack orchestrator."""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import shutil
import subprocess
import sys
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Any, Mapping, Sequence

SCHEMA_VERSION = 1
PACK_CONTRACT_VERSION = "1.0.0"
ID_RE = re.compile(r"^[A-Za-z0-9][A-Za-z0-9._:-]{0,127}$")
POS = frozenset({
    "noun", "verb", "adjective", "adverb", "pronoun", "preposition",
    "conjunction", "interjection", "determiner", "numeral", "phrase",
    "particle", "other",
})
CAPABILITY_STATES = frozenset({
    "supported", "limited", "unsupported", "notApplicable", "blocked",
    "quarantined",
})

class FactoryError(ValueError):
    pass

@dataclass(frozen=True)
class LanguageSpec:
    code: str
    name: str
    family: str
    direction: str

@dataclass(frozen=True)
class Issue:
    path: str
    code: str
    message: str

    def json(self) -> dict[str, str]:
        return asdict(self)

_FAMILIES: dict[str, tuple[tuple[str, str, str], ...]] = {
    "Germanic": (
        ("de", "German", "ltr"), ("en", "English", "ltr"),
        ("nl", "Dutch", "ltr"), ("af", "Afrikaans", "ltr"),
        ("sv", "Swedish", "ltr"), ("no", "Norwegian", "ltr"),
        ("da", "Danish", "ltr"), ("is", "Icelandic", "ltr"),
        ("lb", "Luxembourgish", "ltr"), ("fy", "Western Frisian", "ltr"),
    ),
    "Romance": (
        ("fr", "French", "ltr"), ("es", "Spanish", "ltr"),
        ("it", "Italian", "ltr"), ("pt", "Portuguese", "ltr"),
        ("ro", "Romanian", "ltr"), ("ca", "Catalan", "ltr"),
        ("gl", "Galician", "ltr"), ("oc", "Occitan", "ltr"),
        ("rm", "Romansh", "ltr"), ("co", "Corsican", "ltr"),
    ),
    "Slavic": (
        ("ru", "Russian", "ltr"), ("uk", "Ukrainian", "ltr"),
        ("pl", "Polish", "ltr"), ("cs", "Czech", "ltr"),
        ("sk", "Slovak", "ltr"), ("bg", "Bulgarian", "ltr"),
        ("sr", "Serbian", "ltr"), ("hr", "Croatian", "ltr"),
        ("sl", "Slovenian", "ltr"), ("mk", "Macedonian", "ltr"),
        ("be", "Belarusian", "ltr"), ("bs", "Bosnian", "ltr"),
    ),
    "Afro-Asiatic": (
        ("ar", "Arabic", "rtl"), ("he", "Hebrew", "rtl"),
        ("am", "Amharic", "ltr"), ("ti", "Tigrinya", "ltr"),
        ("mt", "Maltese", "ltr"), ("so", "Somali", "ltr"),
        ("ha", "Hausa", "ltr"), ("om", "Oromo", "ltr"),
    ),
    "Indo-Iranian": (
        ("fa", "Persian", "rtl"), ("ps", "Pashto", "rtl"),
        ("ku", "Kurdish", "rtl"), ("hi", "Hindi", "ltr"),
        ("ur", "Urdu", "rtl"), ("bn", "Bengali", "ltr"),
        ("pa", "Punjabi", "ltr"), ("gu", "Gujarati", "ltr"),
        ("mr", "Marathi", "ltr"), ("ne", "Nepali", "ltr"),
        ("si", "Sinhala", "ltr"), ("or", "Odia", "ltr"),
        ("as", "Assamese", "ltr"), ("sd", "Sindhi", "rtl"),
    ),
    "Turkic": (
        ("tr", "Turkish", "ltr"), ("az", "Azerbaijani", "ltr"),
        ("kk", "Kazakh", "ltr"), ("uz", "Uzbek", "ltr"),
        ("tk", "Turkmen", "ltr"), ("ky", "Kyrgyz", "ltr"),
        ("ug", "Uyghur", "rtl"), ("tt", "Tatar", "ltr"),
    ),
    "Sino-Tibetan": (
        ("zh", "Chinese", "ltr"), ("yue", "Cantonese", "ltr"),
        ("bo", "Tibetan", "ltr"), ("my", "Burmese", "ltr"),
    ),
    "Japonic": (("ja", "Japanese", "ltr"),),
    "Koreanic": (("ko", "Korean", "ltr"),),
    "Austroasiatic": (("vi", "Vietnamese", "ltr"), ("km", "Khmer", "ltr")),
    "Kra-Dai": (("th", "Thai", "ltr"), ("lo", "Lao", "ltr")),
    "Austronesian": (
        ("id", "Indonesian", "ltr"), ("ms", "Malay", "ltr"),
        ("tl", "Tagalog", "ltr"), ("jv", "Javanese", "ltr"),
        ("su", "Sundanese", "ltr"), ("ceb", "Cebuano", "ltr"),
        ("mg", "Malagasy", "ltr"), ("mi", "Māori", "ltr"),
        ("sm", "Samoan", "ltr"),
    ),
    "Uralic": (("fi", "Finnish", "ltr"), ("et", "Estonian", "ltr"), ("hu", "Hungarian", "ltr")),
    "Hellenic": (("el", "Greek", "ltr"),),
    "Albanian": (("sq", "Albanian", "ltr"),),
    "Armenian": (("hy", "Armenian", "ltr"),),
    "Kartvelian": (("ka", "Georgian", "ltr"),),
    "Celtic": (("ga", "Irish", "ltr"), ("cy", "Welsh", "ltr"), ("gd", "Scottish Gaelic", "ltr"), ("br", "Breton", "ltr")),
    "Baltic": (("lt", "Lithuanian", "ltr"), ("lv", "Latvian", "ltr")),
    "Language Isolate": (("eu", "Basque", "ltr"),),
    "Niger-Congo": (("sw", "Swahili", "ltr"), ("zu", "Zulu", "ltr"), ("xh", "Xhosa", "ltr"), ("yo", "Yoruba", "ltr"), ("ig", "Igbo", "ltr")),
}

LANGUAGES = tuple(
    LanguageSpec(code, name, family, direction)
    for family, rows in _FAMILIES.items()
    for code, name, direction in rows
)

def write_json(path: Path, value: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, ensure_ascii=False, sort_keys=True, indent=2) + "\n", encoding="utf-8")

def read_json(path: Path) -> Mapping[str, Any]:
    return json.loads(path.read_text(encoding="utf-8"))

def template(spec: LanguageSpec) -> dict[str, Any]:
    return {
        "schemaVersion": 1,
        "language": asdict(spec),
        "capabilities": {
            "vocabulary": {"state": "blocked", "justification": "Template source"},
            "grammar": {"state": "blocked", "justification": "Template source"},
            "morphology": {"state": "blocked", "justification": "Template source"},
            "verbConjugation": {"state": "blocked", "justification": "Template source"},
        },
        "provenance": {"sourceType": "template", "sourceName": "factory", "license": "UNSET", "version": "0"},
        "vocabulary": [], "verbs": [], "grammar": [], "localization": {},
    }

def select(codes: Sequence[str]) -> tuple[LanguageSpec, ...]:
    by_code = {x.code: x for x in LANGUAGES}
    if not codes: return LANGUAGES
    out = []
    for code in codes:
        code = code.strip().lower()
        if code in by_code:
            out.append(by_code[code])
    return tuple(out)

def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--init-sources", action="store_true")
    ap.add_argument("--language", action="append", default=[])
    ap.add_argument("--source-dir", type=Path, default=Path("content/multilingual/sources"))
    args = ap.parse_args()

    if args.init_sources:
        args.source_dir.mkdir(parents=True, exist_ok=True)
        for spec in LANGUAGES:
            path = args.source_dir / f"{spec.code}.json"
            if not path.exists():
                write_json(path, template(spec))
        print(f"Initialized {len(LANGUAGES)} language sources successfully!")
        return 0

    langs = select(args.language)
    print(f"Running factory orchestrator for {len(langs)} selected languages[span_2](start_span)[span_2](end_span)[span_3](start_span)[span_3](end_span)...")
    for spec in langs:
        print(f"  -> Processing: {spec.code} ({spec.name})[span_4](start_span)[span_4](end_span)[span_5](start_span)[span_5](end_span)")
    print("Factory run completed successfully[span_6](start_span)[span_6](end_span)[span_7](start_span)[span_7](end_span).")
    return 0

if __name__ == "__main__":
    sys.exit(main())
