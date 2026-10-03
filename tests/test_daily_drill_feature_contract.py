from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FEATURE = ROOT / "lib" / "features" / "daily_drill"
PRESENTATION = FEATURE / "presentation"


def test_daily_drill_files_stay_strictly_below_line_ceiling():
    for path in FEATURE.rglob("*.dart"):
        assert len(path.read_text(encoding="utf-8").splitlines()) < 1000, path


def test_daily_drill_presentation_uses_canonical_glass_and_article_colors():
    text = "\n".join(
        path.read_text(encoding="utf-8")
        for path in PRESENTATION.rglob("*.dart")
    )
    for token in (
        "AppGlassCard",
        "AppColors",
        "AppTypography",
        "AppColors.articleDer",
        "AppColors.articleDie",
        "AppColors.articleDas",
    ):
        assert token in text


def test_daily_drill_presentation_has_no_device_audio_imports():
    forbidden = (
        "package:flutter_tts/",
        "package:audioplayers/",
        "package:speech_to_text/",
        "package:record/",
        "FlutterTts",
        "SpeechToText",
        "AudioPlayer(",
    )
    for path in PRESENTATION.rglob("*.dart"):
        text = path.read_text(encoding="utf-8")
        for token in forbidden:
            assert token not in text, f"{path}: {token}"


def test_daily_drill_reuses_canonical_srs_and_session_persistence():
    repository = (
        FEATURE / "data" / "srs_daily_drill_repository.dart"
    ).read_text(encoding="utf-8")
    sink = (
        FEATURE / "data" / "universal_session_drill_review_sink.dart"
    ).read_text(encoding="utf-8")

    assert "MemoryQueue.rank" in repository
    assert "state.meaningReviewCards" in repository
    assert "UniversalSessionOrchestrator" in sink
    assert "SessionReviewInput" in sink
    assert "LearnerRepository" in sink
    assert "unifiedSrsScheduler.schedule" not in repository + sink


def test_daily_drill_required_layers_exist():
    expected = (
        FEATURE / "domain" / "daily_drill_models.dart",
        FEATURE / "domain" / "daily_drill_repository.dart",
        FEATURE / "data" / "srs_daily_drill_repository.dart",
        FEATURE / "data" / "universal_session_drill_review_sink.dart",
        FEATURE / "application" / "daily_drill_controller.dart",
        FEATURE / "presentation" / "widgets" / "quick_card_flip_widget.dart",
        FEATURE / "presentation" / "widgets" / "drill_completion_summary_widget.dart",
        FEATURE / "presentation" / "screens" / "daily_drill_screen.dart",
    )
    for path in expected:
        assert path.exists(), path
