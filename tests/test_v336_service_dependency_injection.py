from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SERVICE = ROOT / "lib/services/word_profile_service.dart"
CORE_PAGE = ROOT / "lib/ui_v35/pages/core_pages.dart"
PROGRESS_PAGE = ROOT / "lib/ui_v35/progress_pages.dart"


def test_word_profile_service_requires_explicit_catalog_dependencies():
    text = SERVICE.read_text(encoding="utf-8")
    assert "required SearchIndex<T> searchIndex" in text
    assert "required VerbIndex verbIndex" in text
    assert "SearchIndex.instance" not in text
    assert "VerbIndex.instance" not in text


def test_current_callers_pass_explicit_catalog_dependencies():
    core_pages = CORE_PAGE.read_text(encoding="utf-8")
    progress_pages = PROGRESS_PAGE.read_text(encoding="utf-8")
    assert "searchIndex: widget.searchIndex" in core_pages
    assert "verbIndex: widget.verbIndex" in core_pages
    assert "searchIndex: searchIndex" in progress_pages
    assert "verbIndex: verbIndex" in progress_pages
