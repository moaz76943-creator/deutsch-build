from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_v372_version_contract():
    pubspec = (ROOT / "pubspec.yaml").read_text()
    gradle = (ROOT / "android/app/build.gradle").read_text()
    assert "version:" in pubspec
    assert "versionCode " in gradle
    assert "versionName " in gradle
