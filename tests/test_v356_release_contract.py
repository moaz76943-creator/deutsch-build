from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_release_version_advances_for_v356():
    pubspec = (ROOT / 'pubspec.yaml').read_text(encoding='utf-8')
    gradle = (ROOT / 'android/app/build.gradle').read_text(encoding='utf-8')
    assert 'version:' in pubspec
    assert 'versionCode ' in gradle
    assert "versionName " in gradle
