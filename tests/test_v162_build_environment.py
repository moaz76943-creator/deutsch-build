from pathlib import Path

ROOT = Path(__file__).parents[1]


def test_pubspec_requires_flutter_324_compatible_dart():
    text = (ROOT / "pubspec.yaml").read_text()
    assert 'sdk: ">=3.5.0 <4.0.0"' in text


def test_gradle_wrapper_is_pinned_to_814():
    p = ROOT / "android/gradle/wrapper/gradle-wrapper.properties"
    assert p.exists()
    text = p.read_text()
    assert "gradle-8.14-all.zip" in text
    assert "distributionSha256Sum=efe9a3d147d948d7528a9887fa35abcf24ca1a43ad06439996490f77569b02d1" in text


def test_ci_reads_pinned_toolchain_without_repairing_pub_cache():
    for workflow in [".github/workflows/build-apk.yml", ".github/workflows/quality.yml"]:
        text = (ROOT / workflow).read_text()
        assert 'toolchain.lock' in text
        assert "flutter pub cache repair" not in text
        assert 'gradle-version: "${{ steps.toolchain.outputs.gradle }}"' in text
        assert 'flutter-version: "${{ steps.toolchain.outputs.flutter }}"' in text
        if workflow.endswith("build-apk.yml"):
            assert 'python3 tool/gradle_wrapper_integrity.py' in text
        else:
            assert 'python3 tool/gradle_wrapper_integrity.py' not in text
