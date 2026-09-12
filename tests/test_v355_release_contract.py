from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_release_version_advances_for_v355():
    pubspec = (ROOT / "pubspec.yaml").read_text(encoding="utf-8")
    gradle = (ROOT / "android/app/build.gradle").read_text(encoding="utf-8")
    assert "version:" in pubspec
    assert "versionCode " in gradle
    assert 'versionName "' in gradle


def test_ci_validates_language_owned_ingestion_manifest():
    for rel in (".github/workflows/build-apk.yml", ".github/workflows/quality.yml"):
        text = (ROOT / rel).read_text(encoding="utf-8")
        assert "python3 tool/content_ingestion.py validate" in text
