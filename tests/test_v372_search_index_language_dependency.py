from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_search_index_accepts_injected_language_normalizer():
    text = (ROOT / "lib/services/search_index.dart").read_text()
    assert "LanguageTextNormalizer" in text
    assert "SearchIndex(this._items, this._verbIndex, this._textNormalizer);" in text


def test_search_index_does_not_import_legacy_text_normalizer():
    text = (ROOT / "lib/services/search_index.dart").read_text()
    assert "import 'text_normalizer.dart';" not in text


def test_composition_root_injects_language_normalizer():
    text = (ROOT / "lib/main.dart").read_text()
    assert "final verbIndex = contentPack.verbIndex;" in text
    assert "SearchIndex(corpus, verbIndex, languagePack.textNormalizer)" in text
