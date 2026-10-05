from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def test_manifest_keeps_only_currently_used_release_permissions():
    manifest = read("android/app/src/main/AndroidManifest.xml")
    native_probe = read(
        "android/app/src/main/kotlin/com/deutschbilarabi/app/"
        "AndroidPronunciationSignalProbe.kt"
    )
    main_activity = read(
        "android/app/src/main/kotlin/com/deutschbilarabi/app/MainActivity.kt"
    )

    assert "android.permission.INTERNET" not in manifest
    assert "android.permission.POST_NOTIFICATIONS" not in manifest
    assert "android.permission.RECORD_AUDIO" in manifest
    assert "Manifest.permission.RECORD_AUDIO" in native_probe
    assert "AndroidPronunciationSignalProbe.CHANNEL_NAME" in main_activity
    assert "android.intent.action.TTS_SERVICE" in manifest
    assert 'android:allowBackup="false"' in manifest
    assert 'android:usesCleartextTraffic="false"' in manifest


def test_security_audit_matches_offline_first_permission_contract():
    audit = read("tool/security_audit.py")

    assert "'android.permission.INTERNET' not in manifest" in audit
    assert "'android.permission.RECORD_AUDIO' in manifest" in audit
    assert "'android.permission.POST_NOTIFICATIONS' not in manifest" in audit


def test_required_pr_ci_contexts_checkout_the_exact_head():
    engineering = read(".github/workflows/engineering-ci.yml")
    quality = read(".github/workflows/quality.yml")
    exact_head = "ref: ${{ github.event.pull_request.head.sha }}"

    assert engineering.count(exact_head) == 2
    assert quality.count(exact_head) == 1
    assert "name: Python engineering gates" in engineering
    assert "name: Flutter Android readiness" in engineering
    assert "name: Quality Gates" in quality


def test_quality_pr_gate_uses_isolated_dependency_caches():
    quality = read(".github/workflows/quality.yml")

    assert "cache: false" in quality
    assert "pub-cache: false" in quality
    assert "cache-disabled: true" in quality


def test_release_signing_paths_are_absolute_in_ci_and_codemagic():
    workflow = read(".github/workflows/build-apk.yml")
    aab = read(".github/workflows/build_aab.yml")
    codemagic = read("codemagic.yaml")

    assert (
        "ORG_GRADLE_PROJECT_releaseStoreFile: "
        "${{ github.workspace }}/android/app/upload-keystore.jks"
    ) in workflow
    assert (
        "ORG_GRADLE_PROJECT_releaseStoreFile: "
        "${{ github.workspace }}/android/app/upload-keystore.jks"
    ) in aab
    assert 'KEYSTORE_PATH="$CM_BUILD_DIR/android/app/codemagic-upload-keystore.jks"' in codemagic


def test_codemagic_test_build_does_not_require_release_signing():
    codemagic = read("codemagic.yaml")

    test_block = codemagic.split("signed-android-aab:", 1)[0]
    assert "flutter: 3.44.9" in test_block
    assert "java: 17" in test_block
    assert "flutter build apk --debug" in test_block
    assert "flutter build apk --release" not in test_block


def test_signed_aab_contract_is_exact_and_artifacts_are_preserved():
    codemagic = read("codemagic.yaml")
    gradle = read("android/app/build.gradle")
    pubspec = read("pubspec.yaml")

    for variable in (
        "CM_KEYSTORE_BASE64",
        "CM_KEYSTORE_PASSWORD",
        "CM_KEY_ALIAS",
        "CM_KEY_PASSWORD",
    ):
        assert variable in codemagic

    assert (
        "flutter build appbundle --release --obfuscate "
        "--split-debug-info=symbols/ --build-name=3.3.10 --build-number=133"
    ) in codemagic
    assert "build/app/outputs/bundle/release/*.aab" in codemagic
    assert "symbols/**" in codemagic
    assert "release-metadata/SHA256SUMS.txt" in codemagic
    assert "version: 3.3.10+133" in pubspec
    assert "versionCode 133" in gradle
    assert 'versionName "3.3.10"' in gradle


def test_release_apk_verifier_enforces_merged_permission_contract():
    verifier = read("scripts/apk_verify.sh")

    assert "android.permission.RECORD_AUDIO" in verifier
    assert "android.permission.INTERNET" in verifier
    assert "android.permission.POST_NOTIFICATIONS" in verifier
    assert "Unexpected release permission" in verifier


def test_manual_preview_build_cannot_delete_release_tags():
    preview = read(".github/workflows/build_apk.yml")

    assert "delete-older-releases" not in preview
    assert "delete_tags: true" not in preview
    assert "if: github.ref_name == 'main'" in preview


def test_local_quality_gate_uses_active_contracts_with_legacy_opt_in():
    gate = read("scripts/local_quality_gate.sh")

    assert "ACTIVE_PYTHON_TESTS=(" in gate
    assert 'find "$ROOT/tests"' in gate
    assert "-name 'test_*_adaptive_glass_contract.py'" in gate
    assert "ACTIVE_PYTHON_TESTS[@]" in gate
    assert "dart analyze lib/" in gate
    assert "flutter test" in gate
    assert "RUN_LEGACY_TEXT_REGRESSIONS=" in gate
    assert "python3 -m pytest -q tests --ignore=tests/quality_gate" in gate
