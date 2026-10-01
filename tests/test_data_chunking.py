from pathlib import Path
import json
import math
import re

ROOT = Path(__file__).resolve().parents[1]
GENERATED = ROOT / 'lib/data/generated'
CONTENT_JSON = ROOT / 'content/content_items.json'
VERB_JSON = ROOT / 'content/verb_conjugations.json'
BASELINE = ROOT / 'tool/content_baseline.lock'
COMPILER = ROOT / 'tool/content_compiler.py'


def _baseline():
    values = {}
    for line in BASELINE.read_text(encoding='utf-8').splitlines():
        if '=' in line and not line.startswith('#'):
            key, value = line.split('=', 1)
            values[key] = value
    return values


def _chunk_size():
    text = COMPILER.read_text(encoding='utf-8')
    match = re.search(r'^CHUNK_SIZE\s*=\s*(\d+)$', text, re.MULTILINE)
    assert match is not None
    return int(match.group(1))


def test_large_data_tables_are_chunked_and_aggregators_are_small():
    content = json.loads(CONTENT_JSON.read_text(encoding='utf-8'))
    verbs = json.loads(VERB_JSON.read_text(encoding='utf-8'))
    chunk_size = _chunk_size()

    content_parts = sorted(GENERATED.glob('content_items_chunk_*.dart'))
    verb_parts = sorted(GENERATED.glob('verb_conjugations_chunk_*.dart'))
    assert len(content_parts) == math.ceil(len(content) / chunk_size)
    assert len(verb_parts) == math.ceil(len(verbs) / chunk_size)

    for path in (
        GENERATED / 'content_items_generated.dart',
        GENERATED / 'verb_conjugations_generated.dart',
    ):
        assert len(path.read_text(encoding='utf-8').splitlines()) < 300


def test_chunked_data_cardinality_and_ids_are_preserved():
    content = json.loads(CONTENT_JSON.read_text(encoding='utf-8'))
    verbs = json.loads(VERB_JSON.read_text(encoding='utf-8'))
    baseline = _baseline()

    ids = [row['id'] for row in content]
    assert len(content) == int(baseline['CONTENT_ENTRIES'])
    assert len(ids) == len(set(ids)) == int(baseline['UNIQUE_IDS'])
    assert ids[0] == 'w0001'
    assert 'w15776' in ids

    infinitives = {row['infinitive'] for row in verbs}
    assert 'vereinbaren' in infinitives
    assert 'vermeiden' in infinitives
