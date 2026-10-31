from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FEATURE = ROOT / "lib" / "features" / "cognitive_load_agent"
DOMAIN = FEATURE / "domain"
PRESENTATION = FEATURE / "presentation"


def test_cognitive_load_feature_files_stay_below_strict_ceiling():
    for path in FEATURE.rglob("*.dart"):
        assert len(path.read_text(encoding="utf-8").splitlines()) < 1000, path


def test_load_math_stays_out_of_presentation():
    presentation = "\n".join(
        path.read_text(encoding="utf-8")
        for path in PRESENTATION.rglob("*.dart")
    )
    assert "CognitiveLoadEngine" not in presentation
    assert "responseTimeMs" not in presentation
    assert "hesitationCount" not in presentation
    assert "consecutiveErrors" not in presentation


def test_domain_contains_pure_cognitive_load_engine_without_flutter_ui():
    text = "\n".join(
        path.read_text(encoding="utf-8")
        for path in DOMAIN.rglob("*.dart")
    )
    assert "CognitiveLoadEngine" in text
    assert "PacingRecommendation" in text
    assert "package:flutter/material.dart" not in text


def test_presentation_uses_canonical_glass_tokens():
    text = "\n".join(
        path.read_text(encoding="utf-8")
        for path in PRESENTATION.rglob("*.dart")
    )
    for token in ("AppGlassCard", "AppColors", "AppTypography"):
        assert token in text


def test_feature_has_no_network_or_audio_dependencies():
    text = "\n".join(
        path.read_text(encoding="utf-8")
        for path in FEATURE.rglob("*.dart")
    )
    forbidden = (
        "package:http/",
        "dart:io",
        "flutter_tts",
        "speech_to_text",
        "audioplayers",
    )
    for token in forbidden:
        assert token not in text
