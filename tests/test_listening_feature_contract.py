from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FEATURE = ROOT / "lib" / "features" / "listening"
PRESENTATION = FEATURE / "presentation"


def test_listening_feature_files_stay_below_hard_line_ceiling():
    for path in FEATURE.rglob("*.dart"):
        assert len(path.read_text(encoding="utf-8").splitlines()) < 1000, path


def test_presentation_uses_canonical_glass_and_tokens():
    text = "\n".join(
        path.read_text(encoding="utf-8")
        for path in PRESENTATION.rglob("*.dart")
    )
    assert "AppGlassCard" in text
    assert "AppColors" in text
    assert "AppTypography" in text


def test_presentation_has_no_device_audio_or_recording_imports():
    forbidden = (
        "package:flutter_tts/",
        "package:audioplayers/",
        "package:speech_to_text/",
        "package:record/",
    )
    for path in PRESENTATION.rglob("*.dart"):
        text = path.read_text(encoding="utf-8")
        for package in forbidden:
            assert package not in text, f"{path}: {package}"


def test_domain_defines_feature_audio_boundaries_without_duplicate_audio_service():
    text = (FEATURE / "domain" / "audio_services.dart").read_text(encoding="utf-8")
    for contract in (
        "abstract interface class AudioPlayerService",
        "abstract interface class AudioRecorderService",
        "abstract interface class AudioPlayerFacade",
    ):
        assert contract in text
    assert "abstract interface class AudioService" not in text

    canonical = (
        ROOT / "lib" / "core" / "infrastructure" / "audio" / "audio_service.dart"
    ).read_text(encoding="utf-8")
    assert "abstract interface class AudioService" in canonical


def test_infrastructure_reuses_canonical_audio_and_pronunciation_boundaries():
    text = (
        FEATURE / "infrastructure" / "listening_audio_adapters.dart"
    ).read_text(encoding="utf-8")
    assert "IAudioRuntime" in text
    assert "PronunciationSignalProbe" in text
    assert "package:flutter_tts/" not in text
    assert "package:speech_to_text/" not in text
