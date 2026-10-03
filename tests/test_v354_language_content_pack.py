from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding='utf-8')


def test_language_pack_exposes_a_language_owned_content_pack():
    contract = read('lib/language/language_pack.dart')
    assert 'LanguageContentPack get contentPack;' in contract

    german = read('lib/language/german/german_language_pack.dart')
    assert 'LanguageContentPack get contentPack' in german


def test_composition_root_builds_runtime_dependencies_from_selected_content_pack():
    main = read('lib/main.dart')
    assert 'final activeLanguagePack = runtime.languagePack;' in main
    assert 'final contentPack = activeLanguagePack.contentPack;' in main
    assert 'final corpus = contentPack.items;' in main
    assert 'final verbIndex = contentPack.verbIndex;' in main
    assert 'verbIndex: verbIndex,' in main


def test_german_content_pack_is_the_only_place_that_binds_current_german_runtime_sources():
    german = read('lib/language/german/german_content_pack.dart')
    assert 'ContentEngine<ContentItem>' in german
    assert 'VerbIndex(textNormalizer:' in german

    main = read('lib/main.dart')
    assert 'ContentEngine.instance' not in main
    assert 'VerbIndex.instance' not in main
