from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
GERMAN = ROOT / 'content' / 'german'
RUNTIME = ROOT / 'lib' / 'data'


def test_german_content_namespace_contains_canonical_dart_sources():
    assert GERMAN.exists()
    content = sorted(GERMAN.glob('content_a1*.dart')) + sorted(GERMAN.glob('content_expansion*.dart'))
    verbs = sorted(GERMAN.glob('verb_conjugations*.dart'))
    assert len(content) >= 16
    assert len(verbs) >= 16
    assert (GERMAN / 'content_a1.dart').exists()
    assert (GERMAN / 'verb_conjugations.dart').exists()


def test_runtime_data_facades_are_not_canonical_tables():
    text = (RUNTIME / 'content_a1.dart').read_text(encoding='utf-8')
    verb_text = (RUNTIME / 'verb_conjugations.dart').read_text(encoding='utf-8')
    assert 'generated/content_items_generated.dart' in text
    assert 'generated/verb_conjugations_generated.dart' in verb_text
    assert not re.search(r'ContentItem\(id\s*:', text)
    assert not re.search(r'VerbConjugation\(infinitive\s*:', verb_text)


def _content_ids(path: Path):
    return re.findall(r"ContentItem\(id:'([^']+)'", path.read_text(encoding='utf-8'))


def test_canonical_german_content_preserves_entry_identity_and_corpus_cardinality():
    parts = sorted(GERMAN.glob('content*.dart'))
    ids = [value for path in parts for value in _content_ids(path)]
    assert len(ids) == 14813
    assert len(ids) == len(set(ids))
    assert ids[0] == 'w0001'
    assert 'w15776' in ids


def test_runtime_facades_keep_authoring_and_flutter_runtime_separate():
    content_facade = (RUNTIME / 'content_a1.dart').read_text(encoding='utf-8')
    verb_facade = (RUNTIME / 'verb_conjugations.dart').read_text(encoding='utf-8')
    assert '../../content/german/' not in content_facade
    assert '../../content/german/' not in verb_facade
    assert 'generated/content_items_generated.dart' in content_facade
    assert 'generated/verb_conjugations_generated.dart' in verb_facade
    assert (GERMAN / 'content_a1.dart').exists()
    assert (GERMAN / 'verb_conjugations.dart').exists()
