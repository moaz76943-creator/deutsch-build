from pathlib import Path

ROOT = Path(__file__).parents[1]


def test_android_plugins_have_one_canonical_version_source():
    root = (ROOT / "android/build.gradle").read_text()
    settings = (ROOT / "android/settings.gradle").read_text()
    assert 'com.android.application" version "8.13.2"' in settings
    assert 'org.jetbrains.kotlin.android" version "2.3.0"' in settings
    assert 'com.android.application" version' not in root
    assert 'org.jetbrains.kotlin.android" version' not in root


def test_ci_keeps_toolchain_pins_without_rewriting_gradle_configuration():
    for workflow in [".github/workflows/build-apk.yml", ".github/workflows/quality.yml"]:
        text = (ROOT / workflow).read_text()
        assert 'toolchain.lock' in text
        if workflow.endswith("build-apk.yml"):
            assert 'python3 tool/gradle_wrapper_integrity.py' in text
        else:
            assert 'python3 tool/gradle_wrapper_integrity.py' not in text
        assert 'gradle-version: "${{ steps.toolchain.outputs.gradle }}"' in text
        assert 'flutter-version: "${{ steps.toolchain.outputs.flutter }}"' in text


def test_checked_in_gradle_wrapper_scripts_are_present_and_pinned():
    assert (ROOT / "android/gradlew").exists()
    assert (ROOT / "android/gradlew.bat").exists()
    wrapper = (ROOT / "android/gradle/wrapper/gradle-wrapper.properties").read_text()
    assert "gradle-8.14.5-all.zip" in wrapper
