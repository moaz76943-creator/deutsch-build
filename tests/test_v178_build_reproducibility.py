from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
SCRIPTS = ROOT / "scripts"


def read(rel):
    return (ROOT / rel).read_text(encoding="utf-8")


def test_single_toolchain_contract_exists_and_matches_reference():
    lock = ROOT / "toolchain.lock"
    assert lock.exists()
    text = lock.read_text(encoding="utf-8")
    expected = {
        "FLUTTER_VERSION": "3.44.9",
        "DART_VERSION": "3.12.2",
        "JAVA_MAJOR": "17",
        "GRADLE_VERSION": "8.14.5",
        "AGP_VERSION": "8.13.2",
        "KOTLIN_VERSION": "2.3.0",
        "ANDROID_COMPILE_SDK": "36",
        "ANDROID_TARGET_SDK": "36",
        "ANDROID_MIN_SDK": "24",
        "ANDROID_BUILD_TOOLS_VERSION": "36.0.0",
        "APK_ABI": "arm64-v8a",
    }
    for key, value in expected.items():
        assert re.search(rf"^{re.escape(key)}={re.escape(value)}$", text, re.M), key


def test_build_and_test_scripts_guard_pubspec_lock_mutation():
    for name in ("build.sh", "test.sh"):
        text = read(f"scripts/{name}")
        assert "pubspec.lock" in text or "scripts/common.sh" in text
        assert "sha256sum" in text or "sha256sum" in read("scripts/common.sh")
        common = read("scripts/common.sh")
        assert "LOCK_BEFORE" in text or "LOCK_BEFORE" in common
        assert "LOCK_AFTER" in text or "LOCK_AFTER" in common
    assert "pub upgrade" not in read("scripts/build.sh")
    assert "pub upgrade" not in read("scripts/test.sh")


def test_ci_does_not_repair_or_upgrade_dependency_cache_automatically():
    for rel in (".github/workflows/build-apk.yml", ".github/workflows/quality.yml"):
        text = read(rel)
        assert "flutter pub cache repair" not in text
        assert "pub upgrade --major-versions" not in text
        assert "toolchain.lock" in text


def test_build_scripts_use_portable_bash_and_source_toolchain_contract():
    for name in ("build_guard.sh", "doctor.sh", "test.sh", "build.sh", "build_deutsch.sh"):
        text = read(name if name == "build_deutsch.sh" else f"scripts/{name}")
        assert text.startswith("#!/usr/bin/env bash"), name
        assert "toolchain.lock" in text or "scripts/common.sh" in text


def test_build_guard_checks_required_environment_without_hardcoded_toolchain_values():
    text = read("scripts/build_guard.sh")
    assert "source" in text or ". \"$ROOT/toolchain.lock\"" in text
    for value in ("3.47.2", "8.13.2", "2.3.0", "36.0.0"):
        assert value not in text
    for marker in ("flutter", "dart", "java", "ANDROID_SDK", "build-tools", "gradle", "NDK", "uname -m", "pubspec.lock"):
        assert marker.lower() in text.lower()


def test_apk_verifier_contract_exists():
    text = read("scripts/apk_verify.sh")
    assert "com.deutschbilarabi.app" in text
    assert "arm64-v8a" in text
    assert "AndroidManifest.xml" in text
    assert "resources.arsc" in text
    assert "apksigner" in text
    assert "sha256sum" in text


def test_build_runs_content_security_and_apk_verification_before_success():
    text = read("scripts/build.sh")
    for marker in (
        "build_guard.sh",
        "quality_audit.py",
        "security_audit.py",
        "flutter analyze",
        "flutter test",
        "python -m pytest -q tests",
        "apk_verify.sh",
        "build-info",
        "sha256sum",
    ):
        assert marker in text
    assert "BUILD SUCCESS" in text


def test_non_destructive_policy_covers_all_maintained_build_scripts():
    paths = [ROOT / "install_flutter.sh", ROOT / "build_deutsch.sh", *SCRIPTS.glob("*.sh")]
    forbidden = re.compile(r"(^|\s)(?:rm\s+-rf|rm\s+-f|git\s+reset\s+--hard|git\s+branch\s+-D|git\s+tag\s+-d)(?:\s|$)")
    for path in paths:
        for line in path.read_text(encoding="utf-8").splitlines():
            if line.lstrip().startswith("#"):
                continue
            assert not forbidden.search(line), f"forbidden destructive command in {path}: {line}"


def test_provenance_contract_mentions_required_fields():
    text = read("scripts/build.sh")
    for marker in ("App Version", "Build Number", "Flutter Version", "Dart Version", "Android Target", "Build Mode", "Git Commit"):
        assert marker in text


def test_termux_build_does_not_point_at_old_v176_project():
    text = read("build_deutsch.sh")
    assert "Deutsch_belarabi_v176_build" not in text


def test_maintained_shell_scripts_have_valid_bash_syntax():
    import subprocess
    paths = [ROOT / "install_flutter.sh", ROOT / "build_deutsch.sh", ROOT / "tool/bootstrap_flutter_android.sh", *SCRIPTS.glob("*.sh")]
    for path in paths:
        result = subprocess.run(["bash", "-n", str(path)], capture_output=True, text=True)
        assert result.returncode == 0, f"bash syntax failure in {path}: {result.stderr}"


def test_security_audit_tracks_central_build_obfuscation_contract():
    audit = read("tool/security_audit.py")
    assert "scripts/build.sh" in audit
    assert "--obfuscate" in audit


def test_guard_and_doctor_report_path_agp_and_kotlin_contracts():
    guard = read("scripts/build_guard.sh")
    doctor = read("scripts/doctor.sh")
    assert "PATH" in guard
    assert "AGP" in doctor
    assert "Kotlin" in doctor


def test_ui_does_not_depend_directly_on_tts_or_speech_plugin_apis():
    ui_files = list((ROOT / "lib/ui_v35").rglob("*.dart"))
    for path in ui_files:
        text = path.read_text(encoding="utf-8")
        if path.name != "safe_ui.dart":
            assert "package:flutter_tts/" not in text, path
            assert "package:speech_to_text/" not in text, path


def test_ui_and_app_entrypoints_use_preferences_adapter():
    for rel in ("lib/main.dart", "lib/ui/app.dart", "lib/ui_v35/verb_pages.dart"):
        text = read(rel)
        assert "package:shared_preferences/" not in text, rel
    adapter = read("lib/services/preferences_service.dart")
    assert "package:shared_preferences/" in adapter


def test_build_uses_enforced_pub_lockfile_resolution():
    text = read("scripts/build.sh")
    assert "flutter pub get --enforce-lockfile" in text


def test_content_quality_audit_uses_dynamic_integrity_invariants():
    audit = read("tool/quality_audit.py")
    assert "content_baseline.lock" not in audit
    assert "duplicate content IDs" in audit
    assert "content catalog is empty" in audit
