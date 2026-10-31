from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from tool.privacy_audit import audit_project

ROOT = Path(__file__).resolve().parents[1]

def test_privacy_gate_passes_for_current_app():
    report = audit_project(ROOT)
    assert report.ok, report.errors
    assert report.direct_shared_preferences_imports == ()
    assert report.sensitive_terms == ()

def test_release_workflow_runs_privacy_gate():
    workflow = (ROOT / '.github/workflows/build-apk.yml').read_text(encoding='utf-8')
    gate = (ROOT / 'scripts/local_quality_gate.sh').read_text(encoding='utf-8')
    assert 'bash scripts/local_quality_gate.sh' in workflow
    assert 'python3 tool/privacy_audit.py' in gate
