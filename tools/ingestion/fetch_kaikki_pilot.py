#!/usr/bin/env python3
"""Collect bounded Kaikki/Wiktextract pilot candidates into inputs/<lang>.jsonl.

Python 3.10+ standard library only. This is a development-time, opt-in
network harvester, NOT a production corpus approval or CEFR classifier.
Without --source-dir it streams public Kaikki per-language JSONL over HTTPS;
it stops early to avoid downloading multi-gigabyte dictionary dumps.
"""
from __future__ import annotations

import argparse
import gzip
import json
import os
import tempfile
from contextlib import closing
from pathlib import Path
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen

LANGUAGE_NAMES = {"en": "English", "de": "German", "es": "Spanish",
                  "fr": "French", "tr": "Turkish"}
MAX_LINE = 1_048_576


def source_lines(lang: str, source_dir: Path | None, scan_lines: int,
                 max_bytes: int):
    """Stream bounded JSONL without loading a full dump into RAM."""
    if source_dir is None:
        name = LANGUAGE_NAMES[lang]
        url = (f"https://kaikki.org/dictionary/{name}/"
               f"kaikki.org-dictionary-{name}.jsonl")
        request = Request(url, headers={"User-Agent": "DeutschPilotHarvester/1.0"})
        stream = urlopen(request, timeout=60)
    else:
        candidate = next((p for p in
                          (source_dir / f"{lang}.jsonl.gz",
                           source_dir / f"{lang}.jsonl")
                          if p.is_file()), None)
        if candidate is None:
            raise FileNotFoundError(f"No {lang}.jsonl[.gz] in {source_dir}")
        stream = gzip.open(candidate, "rb") if candidate.suffix == ".gz" else candidate.open("rb")

    with closing(stream):
        total = 0
        for _ in range(scan_lines):
            line = stream.readline(MAX_LINE + 1)
            if not line:
                break
            total += len(line)
            if len(line) > MAX_LINE or total > max_bytes:
                raise ValueError("Source exceeds configured line/byte cap")
            yield line


def normalize(raw: object, lang: str) -> dict | None:
    """Preserve source-backed facts only; do not invent ranks or CEFR labels."""
    if not isinstance(raw, dict):
        return None
    if raw.get("lang_code", raw.get("languageCode")) != lang:
        return None
    word = raw.get("word")
    pos = raw.get("pos")
    if not isinstance(word, str) or not word.strip() or len(word) > 160:
        return None
    if not isinstance(pos, str) or not pos.strip() or len(pos) > 64:
        return None
    senses = raw.get("senses")
    glosses = []
    if isinstance(senses, list):
        for sense in senses[:5]:
            if isinstance(sense, dict):
                values = sense.get("glosses")
                if isinstance(values, list):
                    glosses.extend(v for v in values[:2]
                                   if isinstance(v, str) and v.strip() and len(v) <= 1000)
    translations = raw.get("translations")
    if not isinstance(translations, list):
        translations = []
    translations = [x for x in translations[:30] if isinstance(x, dict)
                    and (x.get("lang_code") in ("ar", "en")
                         or x.get("languageCode") in ("ar", "en"))]
    if not glosses and not translations:
        return None
    item = {"languageCode": lang, "word": word.strip(), "pos": pos.strip(),
            "senses": [{"glosses": glosses[:5]}],
            "translations": translations[:10],
            "sourceRef": "Wiktionary via Kaikki.org",
            "sourceLicense": "CC BY-SA / GFDL; verify source snapshot before release"}
    for key in ("frequency_rank", "cefr", "cefr_level"):
        value = raw.get(key)
        if key == "frequency_rank" and type(value) is int and value > 0:
            item[key] = value
        elif key != "frequency_rank" and value in ("A1", "A2", "B1", "B2", "C1", "C2"):
            item[key] = value
    return item


def fetch_one(lang: str, input_dir: Path, source_dir: Path | None,
              scan_lines: int, max_entries: int, max_mb: int) -> tuple[int, Path]:
    if lang not in LANGUAGE_NAMES or scan_lines < 1 or max_entries < 1 or max_mb < 1:
        raise ValueError("Invalid language or resource limit")
    input_dir.mkdir(parents=True, exist_ok=True)
    target = input_dir / f"{lang}.jsonl"
    seen: set[tuple[str, str]] = set()
    count = 0
    fd, temporary = tempfile.mkstemp(prefix=f".{lang}-", suffix=".tmp", dir=input_dir)
    try:
        with os.fdopen(fd, "w", encoding="utf-8", newline="\n") as output:
            for line in source_lines(lang, source_dir, scan_lines, max_mb * 1024 * 1024):
                try:
                    raw = json.loads(line.decode("utf-8"))
                except (UnicodeError, ValueError):
                    continue
                item = normalize(raw, lang)
                if item is None:
                    continue
                key = (item["word"].casefold(), item["pos"].casefold())
                if key in seen:
                    continue
                seen.add(key)
                output.write(json.dumps(item, ensure_ascii=False, sort_keys=True,
                                        separators=(",", ":")) + "\n")
                count += 1
                if count >= max_entries:
                    break
            output.flush()
            os.fsync(output.fileno())
        if count == 0:
            raise ValueError(f"{lang}: no usable candidates; no output published")
        candidate_bytes = Path(temporary).read_bytes()
        if target.exists():
            if target.read_bytes() != candidate_bytes:
                raise FileExistsError(f"Refusing to overwrite differing input: {target}")
        else:
            try:
                os.link(temporary, target)
            except FileExistsError:
                if target.read_bytes() != candidate_bytes:
                    raise FileExistsError(f"Conflicting concurrent input: {target}")
        return count, target
    finally:
        Path(temporary).unlink(missing_ok=True)


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--languages", default="en,de,es,fr,tr",
                        help="Comma-separated subset of en,de,es,fr,tr")
    parser.add_argument("--input-dir", type=Path, default=Path("inputs"))
    parser.add_argument("--source-dir", type=Path,
                        help="Optional local Kaikki <lang>.jsonl[.gz] files; no network")
    parser.add_argument("--scan-lines", type=int, default=100000)
    parser.add_argument("--max-entries", type=int, default=6000)
    parser.add_argument("--max-mb", type=int, default=256,
                        help="Maximum decompressed source bytes scanned per language")
    args = parser.parse_args(argv)
    languages = args.languages.split(",")
    if not languages or any(lang not in LANGUAGE_NAMES for lang in languages) or len(set(languages)) != len(languages):
        parser.error("--languages must be a unique comma-separated subset of en,de,es,fr,tr")
    try:
        for lang in languages:
            count, dest = fetch_one(lang, args.input_dir, args.source_dir,
                                    args.scan_lines, args.max_entries, args.max_mb)
            print(f"{lang}: {count} candidate rows -> {dest}")
    except (OSError, ValueError, HTTPError, URLError) as exc:
        parser.exit(1, f"Pilot fetch failed: {exc}\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
