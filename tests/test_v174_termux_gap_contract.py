from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
INSTALL = ROOT / 'install_flutter.sh'
BUILD = ROOT / 'build_deutsch.sh'


def test_sdk_discovery_and_component_reuse_contract():
    text = INSTALL.read_text()
    assert 'discover_android_sdk()' in text
    assert 'platform-tools' in text
    assert 'build-tools' in text
    assert 'sdkmanager --list' in text or 'sdkmanager --list_installed' in text
    assert 'ANDROID_HOME' in text and 'ANDROID_SDK_ROOT' in text


def test_resumable_download_handles_completed_files_and_http_range_failures():
    text = INSTALL.read_text()
    assert '416' in text
    assert 'curl -fL' in text
    assert 'sha256sum -c' in text


def test_repository_setup_repairs_without_destructive_reset():
    text = INSTALL.read_text()
    assert 'termux-change-repo' in text or 'sources.list' in text
    assert 'rm -rf "$HOME/flutter"' not in text
    assert 'rm -rf "$ANDROID_HOME"' not in text
    assert 'rm -rf ~/.gradle' not in text


def test_build_script_uses_wrapper_and_verifies_required_android_sdk():
    text = BUILD.read_text()
    assert 'scripts/build.sh' in text
    assert 'android.aapt2FromMavenOverride=' in text

def test_build_repairs_only_the_aapt2_override_without_resetting_gradle_state():
    text = BUILD.read_text()
    assert 'configure_aapt2_override()' in text
    assert 'android.aapt2FromMavenOverride=' in text
    assert 'python3 - "$gp" "$desired"' in text
    assert 'Existing ARM64 aapt2 override preserved' not in text
    assert 'rm -rf "$HOME/.gradle"' not in text
