from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_quality_workflow_skips_external_pull_request_code():
    text = (ROOT / '.github' / 'workflows' / 'quality.yml').read_text(encoding='utf-8')
    assert 'github.event.pull_request.head.repo.full_name == github.repository' in text


def test_security_audit_enforces_external_pr_boundary():
    text = (ROOT / 'tool' / 'security_audit.py').read_text(encoding='utf-8')
    assert 'pull_request.head.repo.full_name == github.repository' in text
