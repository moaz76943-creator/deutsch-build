from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def test_language_pack_exposes_a_language_owned_content_pack():
    contract = read("lib/language/language_pack.dart")
    german = read("lib/language/german/german_language_pack.dart")
    assert "LanguageContentPack get contentPack;" in contract
    assert "LanguageContentPack get contentPack" in german


def test_production_composition_resolves_indexed_corpus_from_selected_pack():
    main = read("lib/main.dart")
    assert "const activeLanguagePack = GermanLanguagePack();" in main
    assert "await _resolveActiveCorpusSession(prefs)" in main
    assert "ActivePackRuntimeProvider(" in main
    assert "languagePack: languagePack" in main
    assert "resolvedCorpusSession.initialCorpus" in main
    assert "contentPack.items.toList(growable: false)" not in main


def test_german_content_pack_remains_the_legacy_content_binding_boundary():
    german = read("lib/language/german/german_content_pack.dart")
    assert "ContentEngine<ContentItem>" in german
    assert "VerbIndex(textNormalizer:" in german

    main = read("lib/main.dart")
    assert "ContentEngine.instance" not in main
    assert "VerbIndex.instance" not in main
