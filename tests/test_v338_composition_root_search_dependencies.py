from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MAIN = ROOT / "lib/main.dart"
APP = ROOT / "lib/ui_v35/app.dart"
CORE = ROOT / "lib/ui_v35/pages/core_pages.dart"
PROGRESS = ROOT / "lib/ui_v35/progress_pages.dart"


def test_main_owns_explicit_search_composition():
    text = MAIN.read_text(encoding="utf-8")
    assert "SearchIndex(" in text
    assert "contentPack.verbIndex" in text
    assert "SearchIndex.instance" not in text
    assert "final dependencies = AppDependencies<ContentItem>(" in text
    assert "runApp(DeutschAppV35(repo, auth: auth, dependencies: dependencies))" in text


def test_app_receives_search_dependencies_instead_of_legacy_facade():
    text = APP.read_text(encoding="utf-8")
    assert "AppDependencies<ContentItem> dependencies;" in text
    assert "required this.dependencies" in text
    assert "search_index_legacy.dart" not in text
    assert "LegacySearchIndex" not in text


def test_core_pages_receive_explicit_search_dependencies():
    text = CORE.read_text(encoding="utf-8")
    assert "search_index_legacy.dart" not in text
    assert "LegacySearchIndex" not in text
    assert "final SearchIndex searchIndex;" in text
    assert "final VerbIndex verbIndex;" in text


def test_progress_pages_receive_explicit_search_dependencies():
    text = PROGRESS.read_text(encoding="utf-8")
    assert "search_index_legacy.dart" not in text
    assert "LegacySearchIndex" not in text
    assert "final SearchIndex searchIndex;" in text
    assert "final VerbIndex verbIndex;" in text
