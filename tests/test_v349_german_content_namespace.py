from pathlib import Path
import json
import re

ROOT = Path(__file__).resolve().parents[1]
GERMAN = ROOT / 'content' / 'german'
RUNTIME = ROOT / 'lib' / 'data'
GENERATED = RUNTIME / 'generated'
CONTENT_JSON = ROOT / 'content' / 'content_items.json'
VERB_JSON = ROOT / 'content' / 'verb_conjugations.json'


def test_german_content_namespace_points_to_canonical_json_sources():
    manifest = json.loads((GERMAN / 'content_manifest.json').read_text(encoding='utf-8'))
    assert manifest['languageCode'] == 'de'
    assert manifest['contentItems'] == '../content_items.json'
    assert manifest['verbConjugations'] == '../verb_conjugations.json'
    assert CONTENT_JSON.exists()
    assert VERB_JSON.exists()


def test_runtime_data_facades_are_not_canonical_tables():
    text = (RUNTIME / 'content_a1.dart').read_text(encoding='utf-8')
    verb_text = (RUNTIME / 'verb_conjugations.dart').read_text(encoding='utf-8')
    assert 'generated/content_items_generated.dart' in text
    assert 'generated/verb_conjugations_generated.dart' in verb_text
    assert not re.search(r'ContentItem\(id\s*:', text)
    assert not re.search(r'VerbConjugation\(infinitive\s*:', verb_text)


def test_canonical_german_content_uses_unique_nonempty_ids():
    content = json.loads(CONTENT_JSON.read_text(encoding='utf-8'))
    ids = [row['id'] for row in content]
    assert content
    assert len(ids) == len(set(ids))
    assert all(isinstance(value, str) and value for value in ids)


def test_runtime_facades_keep_authoring_and_flutter_runtime_separate():
    content_facade = (RUNTIME / 'content_a1.dart').read_text(encoding='utf-8')
    verb_facade = (RUNTIME / 'verb_conjugations.dart').read_text(encoding='utf-8')
    assert '../../content/german/' not in content_facade
    assert '../../content/german/' not in verb_facade
    assert 'generated/content_items_generated.dart' in content_facade
    assert 'generated/verb_conjugations_generated.dart' in verb_facade
    assert sorted(GENERATED.glob('content_items_chunk_*.dart'))
    assert sorted(GENERATED.glob('verb_conjugations_chunk_*.dart'))
