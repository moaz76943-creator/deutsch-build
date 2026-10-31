from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]

def read(rel):
    return (ROOT / rel).read_text(encoding="utf-8")

def test_android_gradle_contract_is_repo_pinned():
    props = read("android/gradle/wrapper/gradle-wrapper.properties")
    assert "gradle-8.14.5-all.zip" in props
    assert "distributionUrl" in props

def test_android_app_declares_namespace_and_compile_sdk():
    build = read("android/app/build.gradle")
    assert re.search(r'namespace\s+["\']com\.deutschbilarabi\.app["\']', build)
    assert re.search(r'applicationId\s+["\']com\.deutschbilarabi\.app["\']', build)
    assert re.search(r'compileSdk(?:Version)?\s+36\b', build)

def test_ci_must_not_patch_gradle_files_transiently():
    ci = read(".github/workflows/build-apk.yml")
    assert "flutter pub cache repair" not in ci
    assert "gradle-version: \"${{ steps.toolchain.outputs.gradle }}\"" in ci
    assert "python3 tool/gradle_wrapper_integrity.py" in ci
    assert "sed -i" not in ci
    assert "perl -pi" not in ci


def test_android_gradle_files_are_semantically_normalized():
    root = read("android/build.gradle")
    app = read("android/app/build.gradle")
    props = read("android/gradle.properties")
    assert 'com.android.application" version' not in root
    assert app.count("dependencies {") == 1
    assert app.count("com.android.tools:desugar_jdk_libs:2.1.5") == 1
    assert props.count("org.gradle.jvmargs=") == 1
    assert "android.aapt2path=" not in props
