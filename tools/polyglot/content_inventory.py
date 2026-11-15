#!/usr/bin/env python3
"""Measured, provenance-backed content inventory for the 100-language app.

Counts ONLY content units that exist as files in this repository. It does
not certify production readiness and does not infer content completeness;
the readiness report stays the authority for readiness states.

Usage:
    python3 tools/polyglot/content_inventory.py --report   # print summary
    python3 tools/polyglot/content_inventory.py --write    # regenerate artifact
    python3 tools/polyglot/content_inventory.py --check    # verify artifact matches

Output (--write): assets/registry/content_inventory.json
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
ARTIFACT = REPO_ROOT / "assets/registry/content_inventory.json"

CORRIDORS_DIR = REPO_ROOT / "assets/lexicon/100_languages"
SENTENCE_CORPUS_DIR = REPO_ROOT / "assets/lexicon/languages_corpus"
OFFLINE_DICT_DIR = REPO_ROOT / "assets/lexicon/offline_dictionaries"
AUTHENTIC_VERBS_DIR = REPO_ROOT / "assets/lexicon/authentic_verbs"
BITEXT_DIR = REPO_ROOT / "lib/src/content"

# Offline-dict files attributed to a single head language.
OFFLINE_DICT_HEAD = {
    "daily_dialogue_master_pack.json": "de",
    "medical_communication_master_pack.json": "de",
    "professional_career_master_pack.json": "de",
    "technology_engineering_master_pack.json": "de",
    "german_arabic_core_lexicon.json": "de",
    "english_arabic_professional_lexicon.json": "en",
    "french_arabic_diplomatic_lexicon.json": "fr",
}
# Corridor-file naming: <code>_arabic_verified.json
_CORRIDOR_RE = re.compile(r"^([a-z]{2,3})_arabic_verified\.json$")
# Bitext naming: a1_a2_german_<lang>_bitext_corpus.dart (German is always the head)
_BITEXT_RE = re.compile(r"^a1_a2_german_([a-z]+)_bitext_corpus\.dart$")

EXCLUDED_PRODUCT_LANGUAGES = ("he", "iw", "syc", "ber", "zgh")


def _count_list_json(path: Path) -> int:
    data = json.loads(path.read_text(encoding="utf-8"))
    return len(data) if isinstance(data, list) else 0


def build_inventory() -> dict:
    per_language: dict[str, dict] = {}
    totals = {"files": 0, "entries": 0}
    sources: list[dict] = []

    def add(language: str, source_name: str, entries: int, files: int = 1) -> None:
        lang = per_language.setdefault(language, {"entries": 0, "sources": {}})
        lang["entries"] += entries
        lang["sources"][source_name] = (
            lang["sources"].get(source_name, 0) + entries
        )
        totals["files"] += files
        totals["entries"] += entries

    # 1) Verified corridor starters (<code>_arabic_verified.json)
    n, files = 0, 0
    if CORRIDORS_DIR.is_dir():
        for path in sorted(CORRIDORS_DIR.glob("*_arabic_verified.json")):
            match = _CORRIDOR_RE.match(path.name)
            if not match:
                continue
            code = match.group(1)
            entries = _count_list_json(path)
            add(code, "verified_corridors", entries)
            n += entries
            files += 1
    sources.append(
        {"name": "verified_corridors", "count": n, "files": files,
         "path": "assets/lexicon/100_languages"}
    )

    # 2) English/German/French/Turkish sentence + verb waves with Arabic glosses
    #    (<head>_<sentences|verbs>_r<round>.json)
    head_codes = {"english": "en", "german": "de", "french": "fr", "turkish": "tr"}
    if SENTENCE_CORPUS_DIR.is_dir():
        for head, code in sorted(head_codes.items()):
            for kind in ("sentences", "verbs"):
                n, files = 0, 0
                for path in sorted(
                    SENTENCE_CORPUS_DIR.glob(f"{head}_{kind}_r*.json")
                ):
                    entries = _count_list_json(path)
                    add(code, f"{head}_{kind}", entries)
                    n += entries
                    files += 1
                if files:
                    sources.append(
                        {"name": f"{head}_{kind}", "count": n, "files": files,
                         "path": "assets/lexicon/languages_corpus"}
                    )

    # 3) Offline dictionaries and master packs (head-language attributed)
    n, files = 0, 0
    if OFFLINE_DICT_DIR.is_dir():
        for path in sorted(OFFLINE_DICT_DIR.glob("*.json")):
            head = OFFLINE_DICT_HEAD.get(path.name)
            if head is None:
                continue  # not attributed: honest gap, not guessed
            entries = _count_list_json(path)
            add(head, "offline_dictionaries", entries)
            n += entries
            files += 1
    sources.append(
        {"name": "offline_dictionaries", "count": n, "files": files,
         "path": "assets/lexicon/offline_dictionaries"}
    )

    # 4) Authentic German verbs with Arabic glosses
    n, files = 0, 0
    if AUTHENTIC_VERBS_DIR.is_dir():
        for path in sorted(AUTHENTIC_VERBS_DIR.glob("*.json")):
            entries = _count_list_json(path)
            add("de", "authentic_verbs", entries)
            n += entries
            files += 1
    sources.append(
        {"name": "authentic_verbs", "count": n, "files": files,
         "path": "assets/lexicon/authentic_verbs"}
    )

    # 5) German bitext corpora (heritage-framed; head language is German/de)
    n, files = 0, 0
    if BITEXT_DIR.is_dir():
        for path in sorted(BITEXT_DIR.glob("a1_a2_german_*_bitext_corpus.dart")):
            match = _BITEXT_RE.match(path.name)
            if not match:
                continue
            count = path.read_text(encoding="utf-8").count("pairId:")
            # Always attributes to German: Syriac corpus is heritage-framed
            # German content, not a supported syc product.
            add("de", f"bitext_{match.group(1)}", count)
            n += count
            files += 1
    sources.append(
        {"name": "german_bitext_corpora", "count": n, "files": files,
         "path": "lib/src/content"}
    )

    for code in EXCLUDED_PRODUCT_LANGUAGES:
        per_language.pop(code, None)  # belt-and-braces: never report excluded

    inventory = {
        "schemaVersion": 1,
        "reportId": "polyglot-content-inventory",
        "derivedFrom": [source["path"] for source in sources],
        "note": (
            "Measured count of provenance-backed content units bundled in "
            "this repository. NOT a production-readiness or content-"
            "completeness certification; excluded product languages "
            "(he/iw/syc/ber/zgh) are not reported. The readiness report "
            "remains the authority for readiness states."
        ),
        "excludedProductLanguages": list(EXCLUDED_PRODUCT_LANGUAGES),
        "sources": sources,
        "languages": dict(
            sorted(per_language.items(), key=lambda kv: kv[0])
        ),
        "totals": totals,
    }
    canonical = json.dumps(inventory, ensure_ascii=False, sort_keys=True,
                           separators=(",", ":"))
    inventory["checksum"] = {
        "algorithm": "sha256",
        "scope": "payload-without-checksum",
        "value": hashlib.sha256(canonical.encode("utf-8")).hexdigest(),
    }
    return inventory


def _serialized(inventory: dict) -> str:
    return json.dumps(inventory, ensure_ascii=False, indent=2, sort_keys=True) + "\n"


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("--report", action="store_true")
    group.add_argument("--write", action="store_true")
    group.add_argument("--check", action="store_true")
    args = parser.parse_args(argv)

    inventory = build_inventory()
    serialized = _serialized(inventory)

    if args.report:
        print(
            f"inventory: files={inventory['totals']['files']}"
            f" entries={inventory['totals']['entries']}"
            f" languages_with_content={len(inventory['languages'])}"
        )
        for code, data in inventory["languages"].items():
            print(f"  {code}: {data['entries']} units")
        return 0

    if args.write:
        ARTIFACT.parent.mkdir(parents=True, exist_ok=True)
        ARTIFACT.write_text(serialized, encoding="utf-8")
        print(f"WROTE {ARTIFACT}")
        return 0

    if not ARTIFACT.exists():
        print(f"FAIL: missing generated artifact {ARTIFACT.name}; run --write")
        return 1
    if ARTIFACT.read_text(encoding="utf-8") != serialized:
        print(
            f"FAIL: {ARTIFACT.name} is out of sync with the bundled content;"
            " run python3 tools/polyglot/content_inventory.py --write"
        )
        return 1
    print(
        f"OK: inventory in sync (entries={inventory['totals']['entries']},"
        f" languages_with_content={len(inventory['languages'])})"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
