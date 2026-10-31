from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SEARCH = ROOT / "lib/services/search_index.dart"


def test_search_index_has_no_global_content_or_verb_singletons():
    text = SEARCH.read_text(encoding="utf-8")
    assert "content_engine.dart" not in text
    assert "ContentEngine.instance" not in text
    assert "VerbIndex.instance" not in text


def test_search_index_requires_explicit_dependencies():
    text = SEARCH.read_text(encoding="utf-8")
    assert "SearchIndex(this._items, this._verbIndex, this._textNormalizer)" in text
    assert "final VerbIndex _verbIndex;" in text
