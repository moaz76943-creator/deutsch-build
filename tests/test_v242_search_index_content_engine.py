from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_search_index_isolated_from_runtime_content_and_language_specific_composition():
    text = (ROOT / 'lib/services/search_index.dart').read_text(encoding='utf-8')
    assert 'content_engine.dart' not in text
    assert 'ContentEngine.instance' not in text
    assert 'VerbIndex.instance' not in text
    assert 'GermanContentPack' not in text
    assert 'GermanTextNormalizer' not in text
    assert "import '../data/content_a1.dart';" not in text
    assert 'SearchIndex._(a1)' not in text
    assert 'SearchIndex(this._items, this._verbIndex, this._textNormalizer)' in text
