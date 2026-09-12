from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
GERMAN = ROOT / 'content' / 'german'
LEGACY = ROOT / 'lib' / 'data'


def test_german_content_namespace_contains_canonical_dart_sources():
    assert GERMAN.exists()
    content = sorted(GERMAN.glob('content_a1*.dart')) + sorted(GERMAN.glob('content_expansion*.dart'))
    verbs = sorted(GERMAN.glob('verb_conjugations*.dart'))
    assert len(content) >= 16
    assert len(verbs) >= 16
    assert (GERMAN / 'content_a1.dart').exists()
    assert (GERMAN / 'verb_conjugations.dart').exists()


def test_legacy_data_files_are_compatibility_exports_not_canonical_tables():
    text = (LEGACY / 'content_a1.dart').read_text(encoding='utf-8')
    verb_text = (LEGACY / 'verb_conjugations.dart').read_text(encoding='utf-8')
    assert 'export ' in text or 'part of ' in text
    assert 'export ' in verb_text or 'part of ' in verb_text
    assert not re.search(r'ContentItem\(id\s*:', text)
    assert not re.search(r'VerbConjugation\(', verb_text)


def _content_ids(path: Path):
    return re.findall(r"ContentItem\(id:'([^']+)'", path.read_text(encoding='utf-8'))


def test_canonical_german_content_preserves_entry_identity_and_corpus_cardinality():
    parts = sorted(GERMAN.glob('content*.dart'))
    ids = [value for path in parts for value in _content_ids(path)]
    assert len(ids) == 14813
    assert len(ids) == len(set(ids))
    assert ids[0] == 'w0001'
    assert 'w15776' in ids


def test_legacy_import_surface_points_to_german_namespace():
    for name in ('content_a1.dart', 'verb_conjugations.dart'):
        text = (LEGACY / name).read_text(encoding='utf-8')
        assert '../../content/german/' in text
