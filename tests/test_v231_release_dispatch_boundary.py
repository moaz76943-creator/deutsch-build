from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_release_workflow_restricts_manual_dispatch_to_protected_refs():
    text = (ROOT / '.github' / 'workflows' / 'build-apk.yml').read_text(encoding='utf-8')
    assert "github.event_name != 'workflow_dispatch' || github.ref_name == 'main' || github.ref_name == 'master'" in text


def test_security_audit_enforces_release_manual_dispatch_boundary():
    text = (ROOT / 'tool' / 'security_audit.py').read_text(encoding='utf-8')
    assert "github.event_name != 'workflow_dispatch' || github.ref_name == 'main' || github.ref_name == 'master'" in text
