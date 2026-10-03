from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FEATURE = ROOT / "lib" / "features" / "search"
PRESENTATION = FEATURE / "presentation"


def test_search_feature_files_respect_line_limit():
    for path in FEATURE.rglob("*.dart"):
        assert len(path.read_text(encoding="utf-8").splitlines()) <= 1000, path


def test_presentation_uses_canonical_glass_and_design_tokens():
    text = "\n".join(
        path.read_text(encoding="utf-8")
        for path in PRESENTATION.rglob("*.dart")
    )
    assert "AppGlassCard" in text
    assert "AppColors" in text
    assert "AppTypography" in text


def test_local_persistence_is_isolated_behind_infrastructure():
    infrastructure = (
        FEATURE / "infrastructure" / "local_bookmarks_repository.dart"
    ).read_text(encoding="utf-8")
    assert "FavoritesRepository" in infrastructure
    assert "PreferencesService" in infrastructure
    assert "package:shared_preferences" not in infrastructure

    for directory in (FEATURE / "domain", PRESENTATION):
        for path in directory.rglob("*.dart"):
            text = path.read_text(encoding="utf-8")
            assert "FavoritesRepository" not in text, path
            assert "PreferencesService" not in text, path


def test_required_domain_contracts_and_models_exist():
    models = (FEATURE / "domain" / "search_models.dart").read_text(encoding="utf-8")
    repos = (FEATURE / "domain" / "search_repositories.dart").read_text(encoding="utf-8")
    for token in (
        "class SearchQuery",
        "class SearchResultItem",
        "class UserBookmark",
        "class CustomWordNote",
    ):
        assert token in models
    assert "abstract interface class SearchRepository" in repos
    assert "abstract interface class BookmarksRepository" in repos


def test_search_adapter_reuses_canonical_index_and_umlaut_aliases():
    repository = (
        FEATURE / "data" / "lexicon_search_repository.dart"
    ).read_text(encoding="utf-8")
    normalizer = (
        FEATURE / "data" / "search_text_normalizer.dart"
    ).read_text(encoding="utf-8")
    assert "SearchIndex<T>" in repository
    for token in (
        "replaceAll('ä', 'ae')",
        "replaceAll('ü', 'ue')",
        "replaceAll('ue', 'u')",
    ):
        assert token in normalizer
