import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def test_phase13_microscope_reads_canonical_runtime_grammar():
    service = read("lib/services/grammar_microscope_service.dart")
    hub = read("lib/services/grammar_hub_service.dart")
    pack = read("lib/services/pack_grammar_hub_repository.dart")
    assert "GrammarMicroscopeRepository" in hub
    assert "getRulesForTopic" in hub
    assert "getRulesForTopic" in pack
    assert "fallback is GrammarMicroscopeRepository" in pack
    assert "as GrammarMicroscopeRepository" in pack
    assert re.search(
        r"\.getRulesForTopic\(\s*safeTopicId\s*,?\s*\)",
        pack,
        re.DOTALL,
    )
    assert "CanonicalGrammarCatalog" not in service


def test_phase13_explains_with_facet_srs_without_mutating_learning_state():
    service = read("lib/services/grammar_microscope_service.dart")
    assert "state.reviewCards.values" in service
    assert "card.failures * 2 + card.lapses" in service
    assert "ReviewFacetType.caseForm" in service
    assert "ReviewFacetType.auxiliary" in service
    assert "recordFacet" not in service
    assert "record(" not in service
    assert "saveTopicMastery" not in service


def test_phase13_ui_is_bidi_safe_and_integrated_from_grammar_topic():
    page = read("lib/ui_v35/grammar/grammar_microscope_page.dart")
    sections = read("lib/ui_v35/grammar/grammar_microscope_sections.dart")
    detail = read("lib/ui_v35/grammar/grammar_topic_detail_page.dart")
    app = read("lib/ui_v35/app.dart")
    assert "BidiText" in page
    assert "DirectionalText.german" in page
    assert "DirectionalText.arabic" in page
    assert "BidiText" in sections
    assert "مجهر القواعد" in detail
    assert "learnerState: state" in app


def test_phase13_microscope_is_offline_and_non_causal_in_wording():
    page = read("lib/ui_v35/grammar/grammar_microscope_page.dart")
    sections = read("lib/ui_v35/grammar/grammar_microscope_sections.dart")
    combined = page + sections
    assert "http://" not in combined
    assert "https://" not in combined
    assert "ليست تشخيصًا" in sections
    assert "بدون افتراض وجود مشكلة لديك" in sections


def test_phase13_ui_files_respect_modularity_gate():
    for path in (ROOT / "lib/ui_v35").rglob("*.dart"):
        assert len(path.read_text(encoding="utf-8").splitlines()) <= 1000, path
