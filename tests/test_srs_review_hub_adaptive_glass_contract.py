from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]

SURFACES = (
    "lib/features/quick_review/presentation/srs_review_hub_screen.dart",
    "lib/features/quick_review/presentation/v11_quick_review_screen.dart",
)


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def review_surface_source() -> str:
    return "\n".join(read(path) for path in SURFACES)


def test_review_hub_uses_canonical_adaptive_glass_only():
    source = review_surface_source()

    assert source.count("AppGlassCard(") >= 8
    assert re.search(r"(?<![A-Za-z])Card\(", source) is None
    for path in SURFACES:
        assert len(read(path).splitlines()) < 1000, path


def test_review_audio_and_language_direction_use_canonical_components():
    source = review_surface_source()
    quick = read("lib/features/quick_review/presentation/v11_quick_review_screen.dart")

    assert "AppAudioButton(" in quick
    assert "Icons.volume_up" not in quick
    assert source.count("AppDirectionalText(") >= 18
    assert source.count("AppTypography.") >= 24
    assert "languageCode: widget.sourceLanguageCode" in quick
    assert "languageCode: widget.translationLanguageCode" in quick
    assert "TextDirection.rtl" in source

    forbidden = (
        "package:flutter_tts/",
        "package:speech_to_text/",
        "package:audioplayers/",
        "package:just_audio/",
        "FlutterTts(",
        "SpeechToText(",
        "AudioPlayer(",
    )
    for token in forbidden:
        assert token not in source


def test_review_write_path_stays_on_repository_and_unified_scheduler():
    hub = read("lib/features/quick_review/presentation/srs_review_hub_screen.dart")
    quick = read("lib/features/quick_review/presentation/v11_quick_review_screen.dart")
    sink = read(
        "lib/features/daily_drill/data/universal_session_drill_review_sink.dart"
    )
    orchestrator = read(
        "lib/features/session/universal_session_orchestrator.dart"
    )
    repository = read("lib/services/repository.dart")
    shell = read("lib/ui/phase3/phase3_production_shell.dart")

    assert "SrsReviewHubScreen(" in shell
    assert "V11QuickReviewScreen(" in hub
    assert "reviewSink.record(" in quick
    assert "_orchestrator.record(" in sink
    assert "await _repository.record(" in orchestrator
    assert "await _repository.recordFacet(" in orchestrator
    assert "await unifiedSrsScheduler.schedule(" in repository

    assert "UnifiedSrsScheduler(" not in hub
    assert "UnifiedSrsScheduler(" not in quick
    assert "ReviewCard(" not in hub
    assert "reviewCards =" not in hub
    assert "Map<String, ReviewCard>" not in hub


def test_review_surface_remains_offline_and_does_not_touch_manifest():
    source = review_surface_source()

    assert "http://" not in source
    assert "https://" not in source
    assert "android.permission." not in source
