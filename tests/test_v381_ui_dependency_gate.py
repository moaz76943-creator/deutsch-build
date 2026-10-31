from pathlib import Path
import importlib.util

ROOT = Path(__file__).resolve().parents[1]


def _gate():
    spec = importlib.util.spec_from_file_location('v381_ui_dependency_gate', ROOT / 'tool' / 'v381_ui_dependency_gate.py')
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def test_ui_dependency_gate_is_green():
    assert _gate().scan(ROOT) == []


def test_ui_dependency_gate_catches_legacy_quality_dependency(tmp_path):
    ui = tmp_path / 'lib' / 'ui_v35'
    ui.mkdir(parents=True)
    (ui / 'fake.dart').write_text("import '../services/quality.dart';", encoding='utf-8')
    assert _gate().scan(tmp_path) == ['lib/ui_v35/fake.dart: legacy dependency: services/quality.dart (legacy German content-quality facade)']


def test_architecture_audit_integration_enforces_ui_dependency_gate(tmp_path):
    ui = tmp_path / 'lib' / 'ui_v35'
    ui.mkdir(parents=True)
    (ui / 'fake.dart').write_text("import '../services/quality.dart';", encoding='utf-8')
    import subprocess, sys
    proc = subprocess.run(
        [sys.executable, str(ROOT / 'tool' / 'architecture_audit.py'), str(tmp_path)],
        cwd=tmp_path, text=True, capture_output=True,
    )
    assert proc.returncode != 0
    assert 'legacy dependency: services/quality.dart' in proc.stdout
