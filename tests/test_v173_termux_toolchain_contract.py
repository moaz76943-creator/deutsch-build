from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
INSTALL = ROOT / 'install_flutter.sh'
BUILD = ROOT / 'build_deutsch.sh'
BOOTSTRAP = ROOT / 'tool' / 'bootstrap_flutter_android.sh'
SETTINGS = ROOT / 'android' / 'settings.gradle'
BUILD_GRADLE = ROOT / 'android' / 'build.gradle'
APP = ROOT / 'android' / 'app' / 'build.gradle'
WRAPPER = ROOT / 'android' / 'gradle' / 'wrapper' / 'gradle-wrapper.properties'
LOCK = ROOT / 'toolchain.lock'


def test_termux_install_script_exists_and_is_resumable():
    text = INSTALL.read_text()
    assert 'set -Eeuo pipefail' in text
    assert 'check_architecture()' in text
    assert 'check_space()' not in text
    assert 'MIN_FREE_KB' not in text
    assert 'check_network()' in text
    assert 'setup_java()' in text
    assert 'setup_flutter()' in text
    assert 'setup_android_sdk()' in text
    assert 'verify_flutter()' in text
    assert 'verify_android()' in text
    assert 'print_summary()' in text
    assert 'rm -rf "$HOME/flutter"' not in text
    assert 'rm -rf "$ANDROID_HOME"' not in text
    assert 'rm -rf ~/.gradle' not in text
    assert '-C -' in text


def test_termux_install_script_uses_locked_java_major_and_no_p7zip_requirement():
    text = INSTALL.read_text()
    assert 'openjdk-${JAVA_MAJOR}' in text
    assert 'p7zip' not in text
    assert 'TERMUX_FLUTTER_RELEASE_TAG' in text
    assert 'TERMUX_FLUTTER_DEB' in text
    assert 'api.github.com/repos/' in text
    assert 'flutter_linux_arm64_' not in text
    assert 'pkg install -y dart' not in text
    assert 'sudo' not in text
    assert 'readlink -f "$(command -v java)"' in text
    assert '17|21)' in text
    assert 'java -version' in text
    assert 'javac -version' in text


def test_build_script_is_separate_and_checks_apk_hash():
    text = BUILD.read_text()
    assert 'scripts/build.sh' in text
    assert 'toolchain.lock' in text
    assert 'android.aapt2FromMavenOverride=' in text


def test_v173_android_toolchain_is_pinned():
    assert '8.13.2' in SETTINGS.read_text()
    assert 'com.android.application" version' not in BUILD_GRADLE.read_text()
    assert 'compileSdk 36' in APP.read_text()
    assert 'targetSdk 36' in APP.read_text()
    assert 'gradle-8.14.5-all.zip' in WRAPPER.read_text()

    lock = LOCK.read_text()
    assert 'FLUTTER_VERSION=3.44.9' in lock
    assert 'DART_VERSION=3.12.2' in lock
    assert 'JAVA_MAJOR=17' in lock
    assert 'GRADLE_VERSION=8.14.5' in lock
    assert 'AGP_VERSION=8.13.2' in lock
    assert 'KOTLIN_VERSION=2.3.0' in lock
