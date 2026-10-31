from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def test_phase9_runtime_uses_explicit_canonical_repository():
    provider = read("lib/services/active_pack_runtime_provider.dart")
    repository = read("lib/services/pack_german_word_family_repository.dart")
    assert "PackGermanWordFamilyRepository" in provider
    assert "CanonicalLinguisticStore" in repository
    assert "readGermanWordFamily" in repository


def test_phase9_grid_does_not_consume_legacy_word_family_heuristic():
    page = read("lib/ui_v35/word_families/word_families_page.dart")
    card = read("lib/ui_v35/word_families/word_family_card.dart")
    joined = page + card
    assert "contentIntelligence" not in joined
    assert "_wordFamily" not in joined
    assert "stem" not in joined.lower()
    assert "BidiText" in card
    assert "DirectionalText.german" in card
    assert "DirectionalText.arabic" in card


def test_phase9_is_german_language_intelligence_not_shared_core():
    model = read("lib/models/linguistics/german_word_family.dart")
    contract = read("lib/language/german/german_word_family_repository.dart")
    assert "GermanWordFamily" in model
    assert "GermanWordFamilyRepository" in contract
    assert not (ROOT / "lib/core/german_word_family.dart").exists()
