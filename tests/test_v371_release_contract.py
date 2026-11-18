from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_v371_core_boundary_contract():
    pubspec = (ROOT / "pubspec.yaml").read_text(encoding="utf-8")
    gradle = (ROOT / "android/app/build.gradle").read_text(encoding="utf-8")
    normalizer = (ROOT / "lib/services/text_normalizer.dart").read_text(encoding="utf-8")
    quality = (ROOT / "lib/services/quality.dart").read_text(encoding="utf-8")
    assert "version:" in pubspec
    assert "versionCode " in gradle
    assert "versionName " in gradle
    assert "GermanTextNormalizer" in normalizer
    assert "GermanContentQuality" in quality
    assert not (ROOT / "lib/core/text_normalizer.dart").exists()
    assert not (ROOT / "lib/core/content_quality.dart").exists()
