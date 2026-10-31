from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FEATURE = ROOT / "lib" / "features" / "grammar"


def test_grammar_feature_files_respect_line_limit():
    for path in FEATURE.rglob("*.dart"):
        assert len(path.read_text(encoding="utf-8").splitlines()) <= 1000, path


def test_grammar_presentation_uses_glass_design_without_audio_plugins():
    presentation = FEATURE / "presentation"
    texts = "\n".join(
        path.read_text(encoding="utf-8")
        for path in presentation.rglob("*.dart")
    )
    assert "AppGlassCard" in texts
    assert "AppColors" in texts
    forbidden = (
        "flutter_tts",
        "speech_to_text",
        "audioplayers",
        "AudioPlayer",
        "FlutterTts",
        "SpeechToText",
    )
    for token in forbidden:
        assert token not in texts


def test_grammar_layers_are_present():
    expected = (
        FEATURE / "domain" / "grammar_drill_models.dart",
        FEATURE / "domain" / "grammar_drill_evaluator.dart",
        FEATURE / "data" / "local_grammar_drill_repository.dart",
        FEATURE / "application" / "grammar_drill_notifier.dart",
        FEATURE / "application" / "sentence_token_bank.dart",
        FEATURE / "presentation" / "widgets" / "interactive_sentence_builder_widget.dart",
        FEATURE / "presentation" / "screens" / "grammar_drill_screen.dart",
    )
    for path in expected:
        assert path.exists(), path
