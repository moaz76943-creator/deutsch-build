from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FEATURE = ROOT / "lib" / "features" / "dialogues"
PRESENTATION = FEATURE / "presentation" / "dialogue_chat_view.dart"


def test_dialogue_feature_files_stay_below_hard_line_ceiling():
    for path in FEATURE.rglob("*.dart"):
        assert len(path.read_text(encoding="utf-8").splitlines()) <= 1000, path


def test_dialogue_presentation_uses_canonical_glass_and_design_tokens():
    text = PRESENTATION.read_text(encoding="utf-8")
    assert "AppGlassCard" in text
    assert "AppColors" in text
    assert "AppTypography" in text


def test_dialogue_presentation_has_no_device_audio_package_imports():
    text = PRESENTATION.read_text(encoding="utf-8")
    assert "package:flutter_tts" not in text
    assert "package:speech_to_text" not in text
    assert "IAudioRuntime" not in text
    assert "DialogueAudioPort" in text


def test_dialogue_audio_adapter_uses_abstract_runtime_contract_only():
    text = (FEATURE / "data" / "dialogue_repository.dart").read_text(encoding="utf-8")
    assert "IAudioRuntime" in text
    assert "AudioRequest" in text
    assert "package:flutter_tts" not in text
    assert "package:speech_to_text" not in text


def test_required_real_life_scenarios_are_present():
    text = (FEATURE / "data" / "dialogue_repository.dart").read_text(encoding="utf-8")
    assert "Beim Bäcker" in text
    assert "Am Bahnhof" in text
    assert "Bei der Ausländerbehörde" in text
