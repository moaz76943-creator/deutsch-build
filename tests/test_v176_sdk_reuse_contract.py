from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = (ROOT / 'install_flutter.sh').read_text()

def test_android_components_are_installed_only_when_missing():
    assert 'missing_components=()' in SCRIPT
    assert 'platform-tools' in SCRIPT
    assert 'platforms;android-${ANDROID_API}' in SCRIPT
    assert 'build-tools;${ANDROID_BUILD_TOOLS_VERSION}' in SCRIPT
    assert 'if ((${#missing_components[@]})); then' in SCRIPT

def test_existing_sdk_components_are_not_unconditionally_reinstalled():
    assert 'sdkmanager "platform-tools" "platforms;android-${ANDROID_API}" "build-tools;${ANDROID_BUILD_TOOLS_VERSION}"' not in SCRIPT
