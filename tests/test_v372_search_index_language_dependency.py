from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_search_index_accepts_injected_language_normalizer():
    text = (ROOT / "lib/services/search_index.dart").read_text()
    assert "LanguageTextNormalizer" in text
    assert "SearchIndex(this._items, this._verbIndex, this._textNormalizer);" in text


def test_search_index_does_not_import_legacy_text_normalizer():
    text = (ROOT / "lib/services/search_index.dart").read_text()
    assert "import 'text_normalizer.dart';" not in text


def test_phase3_production_uses_indexed_corpus_instead_of_legacy_search_composition():
    text = (ROOT / "lib/main.dart").read_text()
    assert "ActivePackRuntimeProvider(" in text
    assert "resolution.corpusRepository" in text
    assert "SearchIndex(" not in text
    assert "VerbIndex.instance" not in text
