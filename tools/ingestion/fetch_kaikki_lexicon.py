#!/usr/bin/env python3
"""Harvest Kaikki/Wiktextract JSONL into language_pack_factory v1 source JSON.

The output is a *candidate* pack, not a release-approved CEFR lexicon.
Kaikki generally does not provide reliable CEFR or usage ranks: supply a
frequency CSV to prioritize real beginner vocabulary. No runtime network use.
"""
from __future__ import annotations

import argparse
import csv
import gzip
import hashlib
import heapq
import json
import os
import re
import shutil
import sys
import tempfile
import unicodedata
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Iterator
from urllib.parse import urlparse
from urllib.request import Request, urlopen

LANGUAGES = {'en': 'English', 'fr': 'Français', 'es': 'Español', 'tr': 'Türkçe'}
POS = {'noun': 'noun', 'verb': 'verb', 'adj': 'adjective', 'adjective': 'adjective',
       'adv': 'adverb', 'adverb': 'adverb'}
LEVELS = {'A1': 0, 'A2': 1, 'B1': 2}
ADVANCED = {'B2', 'C1', 'C2'}
UNSUITABLE_TAGS = {'archaic', 'obsolete', 'rare', 'misspelling', 'nonstandard',
                   'vulgar', 'offensive', 'slang', 'form-of', 'alt-of'}
VALID_LEVEL = re.compile(r'(?<![A-Z0-9])(A1|A2|B1|B2|C1|C2)(?![A-Z0-9])', re.I)


@dataclass
class Candidate:
    score: tuple[int, int, int, int]
    entry: dict[str, Any]


def clean_text(value: Any, max_length: int = 2000) -> str | None:
    if not isinstance(value, str):
        return None
    text = unicodedata.normalize('NFC', value).strip()
    if not text or len(text) > max_length:
        return None
    for char in text:
        number = ord(char)
        if (char == '\ufffd' or 0xD800 <= number <= 0xDFFF or
                number in (0xFFFE, 0xFFFF) or
                unicodedata.category(char) in {'Cc', 'Cs', 'Co', 'Cn'}):
            return None
    return text


def word_key(word: str) -> str:
    return unicodedata.normalize('NFC', word).casefold()


def valid_word(word: str) -> bool:
    return (len(word) <= 80 and len(word.split()) <= 3 and
            word[0].isalpha() and word[-1].isalpha() and
            all(char.isalpha() or char.isspace() or char in "-'’" for char in word))


def normalized_level(value: Any) -> str | None:
    if not isinstance(value, str):
        return None
    match = VALID_LEVEL.search(value.upper())
    return match.group(1).upper() if match else None


def entry_level(raw: dict[str, Any]) -> str | None:
    levels: list[str] = []
    for entry in [raw, *(s for s in raw.get('senses', []) if isinstance(s, dict))]:
        for field in ('cefr', 'level', 'cefr_level'):
            level = normalized_level(entry.get(field))
            if level:
                levels.append(level)
        for field in ('tags', 'raw_tags'):
            tags = entry.get(field, [])
            if isinstance(tags, list):
                for tag in tags:
                    level = normalized_level(tag)
                    if level:
                        levels.append(level)
    return min(levels, key=lambda x: LEVELS.get(x, 3)) if levels else None


def rank_value(value: Any) -> int | None:
    if isinstance(value, bool):
        return None
    try:
        rank = int(value)
        return rank if rank > 0 else None
    except (ValueError, TypeError, OverflowError):
        return None


def read_frequency(path: Path | None, lang: str) -> dict[str, tuple[int | None, str | None]]:
    if path is None:
        return {}
    result: dict[str, tuple[int | None, str | None]] = {}
    with path.open('r', encoding='utf-8-sig', newline='') as fh:
        reader = csv.DictReader(fh)
        if not reader.fieldnames or not {'word', 'rank'}.issubset(reader.fieldnames):
            raise ValueError('frequency CSV requires word,rank columns (optional cefr,lang)')
        for row in reader:
            if row.get('lang') and row['lang'] != lang:
                continue
            word = clean_text(row.get('word'), 80)
            if not word:
                continue
            rank = rank_value(row.get('rank'))
            level = normalized_level(row.get('cefr'))
            if rank is None and level is None:
                continue
            key = word_key(word)
            value = (rank, level)
            prev = result.get(key)
            if prev is None or (LEVELS.get(level or '', 3), rank or 10**12) < (LEVELS.get(prev[1] or '', 3), prev[0] or 10**12):
                result[key] = value
    return result


def iter_records(path: Path, stats: dict[str, int]) -> Iterator[dict[str, Any]]:
    suffixes = path.suffixes
    is_gzip = suffixes and suffixes[-1] == '.gz'
    kind = suffixes[-2] if is_gzip and len(suffixes) > 1 else (suffixes[-1] if suffixes else '')
    opener = gzip.open if is_gzip else open
    with opener(path, 'rt', encoding='utf-8-sig', errors='replace') as fh:
        if kind == '.json':
            # JSONL is preferred for large dumps; standard JSON is materialized.
            try:
                data = json.load(fh)
            except (ValueError, UnicodeError) as exc:
                raise ValueError(f'invalid JSON input: {exc}') from exc
            records = data if isinstance(data, list) else data.get('entries', data.get('data', [])) if isinstance(data, dict) else []
            if isinstance(data, dict) and 'word' in data:
                records = [data]
            if not isinstance(records, list):
                raise ValueError('JSON input must contain a list of entries')
            for raw in records:
                stats['seen'] += 1
                if isinstance(raw, dict):
                    yield raw
                else:
                    stats['malformed'] += 1
        else:
            for line in fh:
                stats['seen'] += 1
                if '\ufffd' in line:
                    stats['malformed'] += 1
                    continue
                try:
                    raw = json.loads(line)
                except json.JSONDecodeError:
                    stats['malformed'] += 1
                    continue
                if isinstance(raw, dict):
                    yield raw
                else:
                    stats['malformed'] += 1


def translated_text(raw: dict[str, Any], gloss_lang: str) -> dict[str, str] | None:
    translations: list[dict[str, Any]] = []
    for source in [raw, *(s for s in raw.get('senses', []) if isinstance(s, dict))]:
        value = source.get('translations', [])
        if isinstance(value, list):
            translations.extend(t for t in value if isinstance(t, dict))
    for code in ('ar', 'en'):
        for item in translations:
            lang_code = item.get('lang_code') or item.get('code')
            lang_name = item.get('lang') or ''
            if lang_code != code and str(lang_name).casefold() != ('arabic' if code == 'ar' else 'english'):
                continue
            word = clean_text(item.get('word') or item.get('text'))
            if word:
                return {'text': word, 'language': code, 'method': 'translation'}
    if gloss_lang != 'en':
        return None
    senses = raw.get('senses', [])
    for sense in senses if isinstance(senses, list) else []:
        if not isinstance(sense, dict):
            continue
        for field in ('glosses', 'raw_glosses'):
            values = sense.get(field, [])
            if isinstance(values, list):
                for value in values:
                    gloss = clean_text(value)
                    if gloss:
                        return {'text': gloss, 'language': 'en', 'method': 'gloss'}
    return None


def to_candidate(raw: dict[str, Any], lang: str, frequencies: dict[str, tuple[int | None, str | None]], gloss_lang: str) -> tuple[str, Candidate] | None:
    if raw.get('lang_code') != lang:
        return None
    part = POS.get(raw.get('pos'))
    word = clean_text(raw.get('word'), 80)
    if part is None or word is None or not valid_word(word):
        return None
    senses = raw.get('senses', [])
    if not isinstance(senses, list):
        return None
    tags = raw.get('tags', [])
    all_tags = tags if isinstance(tags, list) else []
    if all_tags and UNSUITABLE_TAGS.intersection(str(tag).casefold() for tag in all_tags):
        return None
    # Reject entries whose only senses are marked as obsolete/form-of, etc.
    if senses and all(isinstance(s, dict) and UNSUITABLE_TAGS.intersection(
            str(tag).casefold() for tag in (s.get('tags') if isinstance(s.get('tags'), list) else [])) for s in senses):
        return None
    translation = translated_text(raw, gloss_lang)
    if translation is None:
        return None
    key = word_key(word)
    f_rank, f_level = frequencies.get(key, (None, None))
    level = f_level or entry_level(raw)
    if level in ADVANCED:
        return None
    rank = f_rank or rank_value(raw.get('frequency_rank')) or rank_value(raw.get('rank'))
    tier = LEVELS[level] if level in LEVELS else (3 if rank is not None else 4)
    digest = hashlib.sha256(f'{lang}|{key}|{part}'.encode('utf-8')).hexdigest()
    score = (tier, rank if rank is not None else 10**12,
             0 if translation['language'] == 'ar' else 1, int(digest[:16], 16))
    entry = {
        'id': f'{lang}.{part}.{digest[:20]}',
        'surface': word,
        'partOfSpeech': part,
        'direction': 'ltr',
        'fields': {
            'translation': translation,
            'canonical': {'cefr': level or 'unknown', 'register': 'neutral', 'semanticTags': []},
            'source': {'name': 'Wiktionary', 'extractor': 'Kaikki/Wiktextract',
                       'attributionRequired': True},
        },
    }
    if rank is not None:
        entry['fields']['usageRank'] = rank
    return f'{key}|{part}', Candidate(score, entry)


def select_entries(records: Iterator[dict[str, Any]], lang: str,
                   frequencies: dict[str, tuple[int | None, str | None]],
                   limit: int, gloss_lang: str, stats: dict[str, int]) -> list[dict[str, Any]]:
    # Heap stores the worst retained entry at index 0; memory stays O(limit).
    chosen: dict[str, Candidate] = {}
    heap: list[tuple[tuple[int, ...], str, Candidate]] = []

    def discard_stale() -> None:
        while heap and chosen.get(heap[0][1]) is not heap[0][2]:
            heapq.heappop(heap)

    for raw in records:
        item = to_candidate(raw, lang, frequencies, gloss_lang)
        if item is None:
            stats['filtered'] += 1
            continue
        key, candidate = item
        existing = chosen.get(key)
        if existing is not None and existing.score <= candidate.score:
            stats['duplicates'] += 1
            continue
        if existing is None and len(chosen) >= limit:
            discard_stale()
            if heap and candidate.score >= chosen[heap[0][1]].score:
                stats['outside_limit'] += 1
                continue
            if heap:
                _, worst_key, _ = heapq.heappop(heap)
                del chosen[worst_key]
        elif existing is not None:
            stats['duplicates'] += 1
        chosen[key] = candidate
        heapq.heappush(heap, (tuple(-n for n in candidate.score), key, candidate))
        # Duplicates can create stale heap records: compact to bound memory.
        if len(heap) > max(16, 2 * limit):
            heap = [(tuple(-n for n in value.score), k, value)
                    for k, value in chosen.items()]
            heapq.heapify(heap)
    return sorted((v.entry for v in chosen.values()), key=lambda entry: entry['id'])


def write_canonical(output: Path, lang: str, entries: list[dict[str, Any]], batch_size: int) -> None:
    output.parent.mkdir(parents=True, exist_ok=True)
    pack = {'id': lang, 'languageCode': lang, 'displayName': LANGUAGES[lang],
            'version': '1.0.0', 'contractVersion': '1.0.0', 'textDirection': 'ltr'}
    localization = {'lexicon.title': {'text': LANGUAGES[lang], 'direction': 'ltr'}}
    prefix = {'schemaVersion': 1, 'pack': pack,
              'requiredLocalizationKeys': ['lexicon.title'], 'localization': localization}
    fd, temp_name = tempfile.mkstemp(prefix=f'.{lang}-', suffix='.tmp', dir=output.parent)
    try:
        with os.fdopen(fd, 'w', encoding='utf-8', newline='\n') as fh:
            header = json.dumps(prefix, ensure_ascii=False, separators=(',', ':'))
            fh.write(header[:-1] + ',"lexicon":[')
            first = True
            for offset in range(0, len(entries), batch_size):
                for item in entries[offset:offset + batch_size]:
                    if not first:
                        fh.write(',')
                    fh.write(json.dumps(item, ensure_ascii=False, separators=(',', ':'), sort_keys=True))
                    first = False
                fh.flush()
            fh.write('],"grammar":[]}\n')
            fh.flush()
            os.fsync(fh.fileno())
        os.replace(temp_name, output)
    finally:
        if os.path.exists(temp_name):
            os.unlink(temp_name)


def harvest(lang: str, input_path: Path, output_dir: Path, *, limit: int = 5000,
            frequency_file: Path | None = None, gloss_lang: str = 'en',
            batch_size: int = 250) -> dict[str, Any]:
    if lang not in LANGUAGES:
        raise ValueError('supported languages: en, fr, es, tr')
    if not 1 <= limit <= 100000 or batch_size < 1:
        raise ValueError('limit must be 1..100000 and batch_size must be positive')
    if gloss_lang not in {'en', 'none'}:
        raise ValueError('gloss_lang must be en or none')
    ranks = read_frequency(frequency_file, lang)
    stats = {'seen': 0, 'malformed': 0, 'filtered': 0, 'duplicates': 0, 'outside_limit': 0}
    entries = select_entries(iter_records(Path(input_path), stats), lang, ranks,
                             limit, gloss_lang, stats)
    if not entries:
        raise ValueError('zero usable entries: output left unchanged')
    dest = Path(output_dir) / lang / 'canonical' / f'{lang}-1.0.0.json'
    write_canonical(dest, lang, entries, batch_size)
    annotated = sum(e['fields']['canonical']['cefr'] in LEVELS for e in entries)
    stats.update({'language': lang, 'written': len(entries), 'cefr_a1_b1': annotated,
                  'frequency_file': str(frequency_file) if frequency_file else None,
                  'target_reached': len(entries) >= 3000, 'output': str(dest)})
    return stats


def download(url: str, destination: Path, max_mb: int) -> None:
    parsed = urlparse(url)
    if parsed.scheme != 'https' or not parsed.hostname:
        raise ValueError('only absolute HTTPS download URLs are supported')
    max_size = max_mb * 1024 * 1024
    request = Request(url, headers={'User-Agent': 'DeutschLexiconHarvester/1.0'})
    with urlopen(request, timeout=60) as response, destination.open('wb') as out:
        size = 0
        while True:
            chunk = response.read(1024 * 1024)
            if not chunk:
                break
            size += len(chunk)
            if size > max_size:
                raise ValueError(f'download exceeds {max_mb} MiB cap')
            out.write(chunk)


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--lang', required=True, choices=LANGUAGES.keys())
    parser.add_argument('--limit', type=int, default=5000)
    parser.add_argument('--output-dir', default='assets/content/packs', type=Path)
    source = parser.add_mutually_exclusive_group(required=True)
    source.add_argument('--input', type=Path, help='local .json, .jsonl or .gz Kaikki dump')
    source.add_argument('--url', help='HTTPS Kaikki dump URL (explicit download)')
    parser.add_argument('--frequency-file', type=Path, help='CSV: word,rank[,cefr,lang]')
    parser.add_argument('--gloss-lang', choices=['en', 'none'], default='en',
                        help='English Wiktionary glosses are valid English fallback')
    parser.add_argument('--batch-size', type=int, default=250)
    parser.add_argument('--max-download-mb', type=int, default=1024)
    args = parser.parse_args(argv)
    try:
        if args.max_download_mb < 1:
            raise ValueError('max-download-mb must be positive')
        if args.url:
            extension = '.jsonl.gz' if urlparse(args.url).path.endswith('.gz') else (
                '.json' if urlparse(args.url).path.endswith('.json') else '.jsonl')
            with tempfile.TemporaryDirectory(prefix='kaikki-') as directory:
                path = Path(directory) / ('download' + extension)
                download(args.url, path, args.max_download_mb)
                result = harvest(args.lang, path, args.output_dir, limit=args.limit,
                                 frequency_file=args.frequency_file,
                                 gloss_lang=args.gloss_lang, batch_size=args.batch_size)
        else:
            result = harvest(args.lang, args.input, args.output_dir, limit=args.limit,
                             frequency_file=args.frequency_file,
                             gloss_lang=args.gloss_lang, batch_size=args.batch_size)
        print(json.dumps(result, sort_keys=True, ensure_ascii=False))
        if result['cefr_a1_b1'] < result['written']:
            print('WARNING: unclassified terms are candidates; CEFR/usage cannot be inferred from Kaikki.', file=sys.stderr)
        if not result['target_reached'] and args.limit >= 3000:
            print('WARNING: fewer than 3,000 eligible entries; not production-volume ready.', file=sys.stderr)
        return 0
    except (OSError, ValueError, EOFError, gzip.BadGzipFile) as exc:
        print(f'ERROR: {exc}', file=sys.stderr)
        return 1


if __name__ == '__main__':
    raise SystemExit(main())
