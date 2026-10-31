from pathlib import Path
import subprocess, sys

ROOT = Path(__file__).resolve().parents[1]


def test_architecture_audit_includes_dependency_boundary_gate(tmp_path):
    (tmp_path / 'lib/core').mkdir(parents=True)
    (tmp_path / 'lib/core/bad.dart').write_text("import '../services/repository.dart';\n", encoding='utf-8')
    proc = subprocess.run([sys.executable, str(ROOT / 'tool/architecture_audit.py'), str(tmp_path)], cwd=tmp_path, text=True, capture_output=True)
    assert proc.returncode != 0
    assert 'core/model depends on services' in proc.stdout
