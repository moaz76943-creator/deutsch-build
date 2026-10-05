from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FIRST_BUILD = ROOT / "termux_first_build.sh"


def test_first_build_orchestrator_is_non_destructive_and_uses_canonical_pipeline():
    text = FIRST_BUILD.read_text(encoding="utf-8")

    assert text.startswith("#!/usr/bin/env bash")
    assert "set -Eeuo pipefail" in text
    assert 'source "$ROOT/toolchain.lock"' in text
    assert '"$ROOT/install_flutter.sh"' in text
    assert '"$ROOT/scripts/doctor.sh"' in text
    assert '"$ROOT/build_deutsch.sh"' in text

    forbidden = (
        "rm -rf",
        "git reset --hard",
        "git clean -fd",
        "flutter pub upgrade",
        "flutter clean",
    )
    for marker in forbidden:
        assert marker not in text


def test_first_build_rehydrates_installed_environment_before_doctor_and_build():
    text = FIRST_BUILD.read_text(encoding="utf-8")

    assert "hydrate_environment()" in text
    assert 'FLUTTER_ROOT="${FLUTTER_ROOT:-$PREFIX/opt/flutter}"' in text
    assert "discover_android_sdk()" in text
    assert 'export ANDROID_HOME="$ANDROID_SDK_ROOT"' in text
    assert 'export ANDROID_SDK_ROOT="$ANDROID_SDK_ROOT"' in text
    assert 'export PATH="$FLUTTER_ROOT/bin:$FLUTTER_ROOT/bin/cache/dart-sdk/bin:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$PATH"' in text


def test_first_build_fails_closed_outside_termux_and_requires_real_apk():
    text = FIRST_BUILD.read_text(encoding="utf-8")

    assert "require_termux()" in text
    assert "/data/data/*/files/usr" in text
    assert 'APK="$ROOT/build/app/outputs/flutter-apk/app-debug.apk"' in text
    assert '[[ -s "$APK" ]]' in text
    assert 'sha256sum "$APK"' in text

def test_termux_flutter_host_is_pinned_to_bionic_release_with_digest_verification():
    lock = (ROOT / "toolchain.lock").read_text(encoding="utf-8")
    install = (ROOT / "install_flutter.sh").read_text(encoding="utf-8")

    assert "TERMUX_FLUTTER_REPOSITORY=ImL1s/termux-flutter-wsl" in lock
    assert "TERMUX_FLUTTER_RELEASE_TAG=v3.44.9-termux-1" in lock
    assert "TERMUX_FLUTTER_DEB=flutter_3.44.9-1_aarch64.deb" in lock

    assert "flutter_linux_arm64_" not in install
    assert "TERMUX_FLUTTER_RELEASE_TAG" in install
    assert "TERMUX_FLUTTER_DEB" in install
    assert "api.github.com/repos/" in install
    assert "digest" in install
    assert "sha256:" in install
    assert "sha256sum -c -" in install
    assert "Verified cached Termux Flutter package" in install
    assert "dpkg -i" in install
    assert "post_install.sh" in install


def test_first_build_prefers_termux_packaged_flutter_root():
    text = FIRST_BUILD.read_text(encoding="utf-8")

    assert 'FLUTTER_ROOT="${FLUTTER_ROOT:-$PREFIX/opt/flutter}"' in text

def test_termux_android_packaging_uses_real_package_and_api36_preflight():
    install = (ROOT / "install_flutter.sh").read_text(encoding="utf-8")

    assert 'pkg install -y aapt' in install
    assert 'pkg install -y aapt2' not in install
    assert 'verify_aapt2_platform()' in install
    assert 'aapt2 link' in install
    assert 'platforms/android-${ANDROID_API}/android.jar' in install
    assert 'AAPT2 API ${ANDROID_API} preflight: PASS' in install
