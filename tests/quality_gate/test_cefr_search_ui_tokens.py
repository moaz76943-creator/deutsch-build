from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
QUICK_SEARCH = ROOT / "lib/features/lexicon_search/presentation/quick_search_modal.dart"
CARD = ROOT / "lib/features/lexicon_search/presentation/widgets/lexicon_result_card.dart"
REPOSITORY = ROOT / "lib/features/lexicon_search/data/offline_lexicon_search_repository.dart"


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def test_search_ui_uses_canonical_design_tokens():
    quick = read(QUICK_SEARCH)
    card = read(CARD)

    assert "AppDesignTokens.spaceS" in quick
    assert "AppDesignTokens.spaceM" in quick
    assert "AppDesignTokens.radiusM" in card
    assert "AppDesignTokens.spaceS" in card
    assert "blur: 24" not in quick
    assert "opacity: dark ? .22 : .86" not in quick


def test_cefr_result_path_has_no_fake_resolver_or_dash_fallback():
    repository = read(REPOSITORY)
    card = read(CARD)

    assert "IndexedSrsCorpusRepository" in repository
    assert "CefrLevelResolver" not in repository
    assert "_unknownLevel" not in repository
    assert "?? '—'" not in repository
    assert "item.hasCefrLevel" in card
    assert "item.cefrLevel != '—'" not in card
