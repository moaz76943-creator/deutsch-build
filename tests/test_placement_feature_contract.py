from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FEATURE = ROOT / "lib" / "features" / "placement"
PRESENTATION = FEATURE / "presentation"
DOMAIN = FEATURE / "domain"


def test_placement_feature_files_respect_line_limit():
    for path in FEATURE.rglob("*.dart"):
        assert len(path.read_text(encoding="utf-8").splitlines()) <= 1000, path


def test_domain_owns_adaptive_scoring_without_flutter_dependency():
    domain_text = "\n".join(
        path.read_text(encoding="utf-8")
        for path in DOMAIN.rglob("*.dart")
    )
    for token in (
        "class PlacementQuestion",
        "class AssessmentSession",
        "class PlacementResult",
        "class AdaptivePlacementEngine",
        "PlacementLevel.a1",
        "PlacementLevel.a2",
        "PlacementLevel.b1",
        "PlacementLevel.b2",
        "PlacementLearningGoal",
    ):
        assert token in domain_text
    assert "package:flutter/" not in domain_text


def test_presentation_uses_glass_tokens_and_not_scoring_logic():
    text = "\n".join(
        path.read_text(encoding="utf-8")
        for path in PRESENTATION.rglob("*.dart")
    )
    assert "AppGlassCard" in text
    assert "AppColors" in text
    assert "AppTypography" in text
    assert "SmartOrb" in text
    assert "SmartOrbDomainState" in text
    assert "AdaptivePlacementEngine" not in text
    assert "flutter_tts" not in text
    assert "audioplayers" not in text
    assert "speech_to_text" not in text


def test_data_adapters_reuse_existing_profile_srs_and_audio_boundaries():
    profile = (
        FEATURE / "data" / "learner_placement_profile_repository.dart"
    ).read_text(encoding="utf-8")
    audio = (
        FEATURE / "data" / "placement_audio_runtime_adapter.dart"
    ).read_text(encoding="utf-8")
    assert "LearnerRepository" in profile
    assert "ReviewCard" in profile
    assert "reviewCards" in profile
    assert "IAudioRuntime" in audio
    assert "AudioRequest" in audio


def test_local_repository_contains_all_four_levels_and_audio_questions():
    text = (
        FEATURE / "data" / "local_placement_repository.dart"
    ).read_text(encoding="utf-8")
    for token in (
        "PlacementLevel.a1",
        "PlacementLevel.a2",
        "PlacementLevel.b1",
        "PlacementLevel.b2",
    ):
        assert text.count(token) >= 4
    assert "PlacementQuestionPattern.listening" in text
    assert "audioText:" in text


def test_local_gate_supports_explicit_flutter_sdk_skip():
    gate = (ROOT / "scripts" / "local_quality_gate.sh").read_text(
        encoding="utf-8"
    )
    assert 'SKIP_FLUTTER_CHECK="${SKIP_FLUTTER_CHECK:-0}"' in gate
    assert 'if [[ "$SKIP_FLUTTER_CHECK" == "1" ]]' in gate


def test_phase19_onboarding_renders_before_corpus_and_routes_progress():
    main = (ROOT / "lib" / "main.dart").read_text(encoding="utf-8")
    profile = (
        FEATURE / "data" / "learner_placement_profile_repository.dart"
    ).read_text(encoding="utf-8")
    shell = (
        ROOT / "lib" / "ui" / "phase3" / "phase3_production_shell.dart"
    ).read_text(encoding="utf-8")

    assert "_needsPlacementOnboarding(state)" in main
    onboarding = main.index("_PlacementBootstrapApp(")
    corpus = main.index("final corpus = await _resolveActiveCorpus(prefs);")
    assert onboarding < corpus
    assert "recommendedStartTaskOrder" in profile
    assert "curriculumStartLevel" in profile
    assert "task.order >= widget.startTaskOrder" in shell
    assert "_index = widget.startTaskOrder > 1 ? 1 : 0;" in shell
