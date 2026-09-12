from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
INSTALL = (ROOT / "install_flutter.sh").read_text()
BUILD = (ROOT / "build_deutsch.sh").read_text()

def test_install_script_does_not_reference_project_payload_files():
    for token in ("lib/main.dart", "android/app/", "tests/", "pubspec.yaml", "assets/", "docs/"):
        assert token not in INSTALL
    assert 'flutter pub get' not in INSTALL
    assert 'flutter build apk' not in INSTALL

def test_build_script_does_not_replace_gradle_properties():
    assert 'mv "$tmp" "$gp"' not in BUILD
