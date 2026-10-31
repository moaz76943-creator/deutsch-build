from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
SCRIPTS = ROOT / "scripts"

def read(name):
    p = SCRIPTS / name
    assert p.exists(), f"missing {name}"
    return p.read_text()

def test_required_scripts_exist():
    for name in ("build_guard.sh", "doctor.sh", "test.sh", "build.sh"):
        assert (SCRIPTS / name).exists()

def test_build_guard_is_non_destructive():
    text = read("build_guard.sh")
    assert "rm -rf" not in text
    assert "rm -f" not in text
    assert "rm -d" not in text
    assert "pubspec.lock" in text or "scripts/common.sh" in text
    assert "uname -m" in text
    assert "flutter" in text
    assert "dart" in text
    assert "java" in text

def test_build_uses_guard_and_does_not_skip_tests():
    text = read("build.sh")
    assert "build_guard.sh" in text
    assert "flutter test" in text
    assert "--no-test" not in text
    assert "--skip-tests" not in text
    assert "flutter build apk" in text

def test_doctor_is_diagnostic_only():
    text = read("doctor.sh")
    assert "flutter build " not in text.lower()
    assert "flutter doctor" in text or "flutter --version" in text

def test_test_script_runs_project_tests():
    text = read("test.sh")
    gate = read("local_quality_gate.sh")
    assert "local_quality_gate.sh" in text
    assert "flutter test" in gate
    assert "pubspec.lock" in text or "scripts/common.sh" in text
