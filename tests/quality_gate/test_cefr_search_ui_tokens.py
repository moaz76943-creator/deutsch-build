from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
QUICK_SEARCH = ROOT / "lib/features/lexicon_search/presentation/quick_search_modal.dart"
CARD = ROOT / "lib/features/lexicon_search/presentation/widgets/lexicon_result_card.dart"
REPOSITORY = ROOT / "lib/features/lexicon_search/data/offline_lexicon_search_repository.dart"
LEXICON_CEFR_TEST = ROOT / "test/quality_gate/lexicon_cefr_search_ui_test.dart"
SRS_CEFR_TEST = ROOT / "test/quality_gate/srs_corpus_cefr_repository_test.dart"


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


def test_termux_guard_prevents_cefr_ffi_execution_without_weakening_sqlite_tests():
    lexicon_test = read(LEXICON_CEFR_TEST)
    srs_test = read(SRS_CEFR_TEST)

    for test_source in (lexicon_test, srs_test):
        assert "import 'dart:io';" in test_source
        assert "Platform.environment.containsKey('TERMUX_VERSION')" in test_source
        assert "prefix.startsWith('/data/data/')" in test_source
        assert "prefix.endsWith('/files/usr')" in test_source
        assert "skip: _termuxFfiSkip" in test_source
        assert "sqfliteFfiInit();" in test_source
        assert "databaseFactoryFfi.openDatabase" in test_source

    assert "testWidgets('result card renders repository CEFR badge" in lexicon_test
    assert "testWidgets('CEFR filter UI exposes only runtime-supported" in lexicon_test
    assert "SrsCorpusSqliteMigrator().migrate" in srs_test
    assert "IndexedSrsCorpusRepository.open" in srs_test
