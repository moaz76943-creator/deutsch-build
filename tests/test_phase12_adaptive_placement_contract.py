from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def test_phase12_placement_is_modular_and_adaptive():
    app = read("lib/ui_v35/app.dart")
    page = read("lib/ui_v35/placement/adaptive_placement_page.dart")
    engine = read("lib/services/adaptive_placement_engine.dart")
    assert "AdaptivePlacementEngine.nextQuestion" in page
    assert "AdaptivePlacementEngine.score" in page
    assert "corpus: widget.dependencies.corpus" in app
    assert "exerciseStrategy:" in app
    assert "audioRuntime:" in app
    assert "maxQuestions" in engine


def test_phase12_diagnostic_does_not_write_mastery_or_xp():
    page = read("lib/ui_v35/placement/adaptive_placement_page.dart")
    service = read("lib/services/adaptive_placement_service.dart")
    assert ".record(" not in page
    assert "recordFacet" not in page
    assert "recordPlacementDiagnostic" in service
    assert "recordAssessment" not in service
    assert "xp" not in service
    assert "reviewCards" not in service


def test_phase12_runtime_pack_content_is_used_not_static_question_bank():
    page = read("lib/ui_v35/placement/adaptive_placement_page.dart")
    app = read("lib/ui_v35/app.dart")
    assert "List<ContentItem> corpus" in page
    assert "widget.dependencies.corpus" in app
    assert "placement.questions" not in page


def test_phase12_is_not_cefr_certification():
    model = read("lib/models/diagnostic_placement.dart")
    page = read("lib/ui_v35/placement/placement_result_panel.dart")
    assert "isCefrCertification => false" in model
    assert "ليست شهادة CEFR" in page


def test_phase12_ui_files_respect_limit():
    for path in (ROOT / "lib/ui_v35").rglob("*.dart"):
        assert len(path.read_text(encoding="utf-8").splitlines()) <= 1000, path


def test_phase12_uses_facet_srs_as_prior_without_mutating_it():
    engine = read("lib/services/adaptive_placement_engine.dart")
    repository = read("lib/services/repository.dart")
    assert "state.reviewCards.values" in engine
    assert "ReviewFacetType.gender" in engine
    assert "card.failures * 2 + card.lapses" in engine
    assert "recordPlacementDiagnostic" in repository
    assert "placementHistory" in repository


def test_phase12_uses_bidi_safe_rendering_and_defers_open_production_scoring():
    page = read("lib/ui_v35/placement/adaptive_placement_page.dart")
    engine = read("lib/services/adaptive_placement_engine.dart")
    assert "BidiText" in page
    assert "DirectionalText.forLanguage" in page
    order = engine.split("_dimensionOrder", 1)[1].split("];", 1)[0]
    assert "DiagnosticDimension.production" not in order
