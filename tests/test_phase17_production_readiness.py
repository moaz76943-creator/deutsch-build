from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def test_phase17_release_signing_never_falls_back_to_debug():
    gradle = read("android/app/build.gradle")
    guard = read("scripts/signing_guard.sh")
    assert "signingConfig signingConfigs.secureRelease" in gradle
    assert "signingConfigs.debug" not in gradle
    assert "releaseTaskRequested" in gradle
    assert "Release signing is mandatory" in gradle
    assert "iOS signing check: NOT_APPLICABLE" in guard


def test_phase17_r8_preserves_native_boundaries_and_strips_logs():
    rules = read("android/app/proguard-rules.pro")
    assert "native <methods>" in rules
    assert "net.sqlcipher.**" in rules
    assert "net.zetetic.database.**" in rules
    assert "AndroidRecordedAudioPlayer" in rules
    assert "AndroidPronunciationSignalProbe" in rules
    assert "AndroidPackDatabaseKeyStore" in rules
    assert "AndroidSecureSessionStorage" in rules
    assert "-assumenosideeffects class android.util.Log" in rules


def test_phase17_release_flutter_errors_do_not_print_details():
    bootstrap = read("lib/bootstrap/production_bootstrap.dart")
    reporter = read("lib/services/runtime_failure_reporter.dart")
    migration = read("lib/services/database_migration_helper.dart")
    assert "NoopRuntimeFailureReporter" in bootstrap
    assert "if (!kReleaseMode)" in bootstrap
    assert "runtimeFailureReporter.record" in bootstrap
    assert "print(" not in reporter
    assert "debugPrint(" not in reporter
    assert "print(" not in migration


def test_phase17_test_mock_is_not_in_production_lib():
    assert not (
        ROOT
        / "lib/features/progress/domain/repositories/"
        "in_memory_learner_progress_repository.dart"
    ).exists()
    support = (
        ROOT
        / "test/features/progress/domain/support/"
        "in_memory_learner_progress_repository.dart"
    )
    assert support.exists()


def test_phase17_production_aab_is_obfuscated_and_signature_checked():
    script = read("scripts/build-aab.sh")
    assert "flutter build appbundle --release" in script
    assert "--obfuscate" in script
    assert "--split-debug-info" in script
    assert "jarsigner -verify -strict" in script
    assert "signing_guard.sh" in script


def test_phase17_gate_is_wired_to_release_paths():
    build = read("scripts/build.sh")
    check_release = read("scripts/check-release.sh")
    gate = read("scripts/local_quality_gate.sh")
    assert "phase17_production_gate.py" in build
    assert "local_quality_gate.sh" in check_release
    assert "python3 tool/phase17_production_gate.py" in gate


def test_phase17_zero_new_dependencies_and_file_size_contract():
    pubspec = read("pubspec.yaml")
    for forbidden in ("firebase_crashlytics:", "sentry_flutter:", "datadog_flutter_plugin:"):
        assert forbidden not in pubspec

    generated = ROOT / "lib/data/generated"
    for path in (ROOT / "lib").rglob("*.dart"):
        try:
            path.relative_to(generated)
            continue
        except ValueError:
            pass
        assert len(path.read_text(encoding="utf-8").splitlines()) <= 1000, path
