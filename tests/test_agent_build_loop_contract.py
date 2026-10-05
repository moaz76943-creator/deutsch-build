from pathlib import Path
import importlib.util
import json
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]


def load_classifier():
    path = ROOT / "tool" / "error_classifier.py"
    spec = importlib.util.spec_from_file_location("error_classifier", path)
    module = importlib.util.module_from_spec(spec)
    assert spec and spec.loader
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module


def test_agent_files_exist():
    for rel in (
        "scripts/agent_build_loop.sh",
        "scripts/runtime_probe.sh",
        "tool/error_classifier.py",
    ):
        assert (ROOT / rel).is_file(), rel


def test_loop_is_bounded_and_requires_clean_tree():
    text = (ROOT / "scripts/agent_build_loop.sh").read_text(encoding="utf-8")
    assert "MAX_ATTEMPTS=${MAX_ATTEMPTS:-4}" in text
    assert "MAX_ATTEMPTS" in text and "-gt 5" in text
    assert "git status --porcelain" in text
    assert "while true" not in text
    assert "AUTO_FIX_CMD" in text
    assert ".github/" in text
    assert "tests/" in text


def test_runtime_probe_is_optional_and_uses_adb_without_networking_app():
    text = (ROOT / "scripts/runtime_probe.sh").read_text(encoding="utf-8")
    for marker in ("adb", "install -r", "logcat", "am start", "com.deutschbilarabi.app"):
        assert marker in text
    assert "curl " not in text
    assert "wget " not in text


def test_classifier_detects_dart_compile_and_redacts_secrets():
    module = load_classifier()
    report = module.classify_text(
        "lib/main.dart:10:3: error • Undefined name 'foo'\n"
        "token=super-secret-value\n"
        "Target kernel_snapshot failed: Exception\n"
    )
    assert report["category"] == "dart_compile"
    assert report["allowed_scopes"] == ["lib/"]
    evidence = "\n".join(report["evidence"])
    assert "super-secret-value" not in evidence


def test_classifier_keeps_dependency_resolution_manual():
    module = load_classifier()
    report = module.classify_text("Because pkg_a depends on pkg_b ^9.0.0, version solving failed.")
    assert report["category"] == "dependency_resolution"
    assert report["allowed_scopes"] == []
    assert report["auto_retry"] is False


def test_classifier_marks_transient_transport_retryable():
    module = load_classifier()
    report = module.classify_text("Connection reset by peer while downloading Gradle distribution")
    assert report["category"] == "transient_io"
    assert report["auto_retry"] is True


def test_shell_scripts_parse():
    for rel in ("scripts/agent_build_loop.sh", "scripts/runtime_probe.sh"):
        proc = subprocess.run(["bash", "-n", str(ROOT / rel)], capture_output=True, text=True)
        assert proc.returncode == 0, proc.stderr


def test_fast_termux_build_profile_preserves_full_gate():
    build = (ROOT / "scripts/build.sh").read_text(encoding="utf-8")
    wrapper = (ROOT / "build_deutsch.sh").read_text(encoding="utf-8")
    assert 'PROFILE="${2:-full}"' in build
    assert "termux-fast" in build
    assert 'dart analyze lib/' in build
    assert 'grep "error •"' in build
    assert "flutter test" in build
    assert "python -m pytest -q tests" in build
    assert '"$ROOT/scripts/build.sh" debug termux-fast' in wrapper
