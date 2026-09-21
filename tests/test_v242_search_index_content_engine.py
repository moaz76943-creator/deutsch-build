from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_search_index_isolated_from_runtime_content_and_legacy_facade_owns_source_composition():
    text = (ROOT / 'lib/services/search_index.dart').read_text(encoding='utf-8')
    legacy = (ROOT / 'lib/services/search_index_legacy.dart').read_text(encoding='utf-8')
    assert 'content_engine.dart' not in text
    assert 'ContentEngine.instance' not in text
    assert 'VerbIndex.instance' not in text
    assert 'GermanContentPack' in legacy
    assert 'VerbIndex.instance' not in legacy
    assert 'VerbIndex(textNormalizer: const GermanTextNormalizer())' in legacy
    assert "import '../data/content_a1.dart';" not in text
    assert 'SearchIndex._(a1)' not in text
