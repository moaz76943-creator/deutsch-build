from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]

GRAMMAR_UI = (
    "lib/ui_v35/grammar/grammar_hub_page.dart",
    "lib/ui_v35/grammar/grammar_topic_detail_page.dart",
    "lib/ui_v35/grammar/grammar_quiz_page.dart",
    "lib/ui_v35/grammar/grammar_microscope_page.dart",
    "lib/ui_v35/grammar/grammar_microscope_sections.dart",
    "lib/features/grammar/presentation/screens/grammar_drill_screen.dart",
    "lib/features/grammar/presentation/widgets/interactive_sentence_builder_widget.dart",
    "lib/features/grammar/presentation/widgets/explain_why_feedback_card.dart",
)


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def grammar_ui_source() -> str:
    return "\n".join(read(path) for path in GRAMMAR_UI)


def test_grammar_surfaces_use_canonical_adaptive_glass_only():
    source = grammar_ui_source()

    assert source.count("AppGlassCard(") >= 10
    assert re.search(r"(?<![A-Za-z])Card\(", source) is None
    for path in GRAMMAR_UI:
        assert len(read(path).splitlines()) < 1000, path


def test_grammar_audio_uses_canonical_button_and_existing_runtime_boundary():
    source = grammar_ui_source()
    hub = read("lib/ui_v35/grammar/grammar_hub_page.dart")
    detail = read("lib/ui_v35/grammar/grammar_topic_detail_page.dart")
    microscope = read("lib/ui_v35/grammar/grammar_microscope_page.dart")
    drill = read(
        "lib/features/grammar/presentation/screens/grammar_drill_screen.dart"
    )

    assert source.count("AppAudioButton(") >= 3
    assert re.search(r"audioRuntime\s*\.play\(", hub)
    assert re.search(r"audioRuntime\s*\.play\(", detail)
    assert re.search(r"audioRuntime\s*\.play\(", microscope)
    assert "onSpeakGerman:" in hub
    assert "onSpeakGerman" in drill

    forbidden = (
        "package:flutter_tts/",
        "package:speech_to_text/",
        "package:audioplayers/",
        "FlutterTts(",
        "SpeechToText(",
        "AudioPlayer(",
    )
    for token in forbidden:
        assert token not in source


def test_grammar_copy_uses_cairo_and_explicit_language_direction():
    source = grammar_ui_source()

    assert source.count("AppDirectionalText(") >= 12
    assert source.count("AppTypography.") >= 20
    assert "languageCode: 'ar'" in source
    assert "languageCode: 'de'" in source
    assert "TextDirection.rtl" in source
    assert "fontFamily: 'Inter'" not in source
    assert "fontFamily: 'Tajawal'" not in source


def test_grammar_ui_remains_offline_and_does_not_request_permissions():
    source = grammar_ui_source()
    manifest = read("android/app/src/main/AndroidManifest.xml")

    assert "http://" not in source
    assert "https://" not in source
    assert "android.permission.INTERNET" not in manifest
