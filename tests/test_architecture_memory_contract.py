from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def test_architecture_memory_is_wired_into_existing_quality_gate():
    gate = (ROOT / "scripts" / "local_quality_gate.sh").read_text(encoding="utf-8")
    assert 'python3 tools/zero_drift_check.py --repo-root "$ROOT"' in gate


def test_post_merge_sync_workflow_is_fail_closed_for_billing():
    workflow = (ROOT / ".github" / "workflows" / "architectural_memory_sync.yml").read_text(
        encoding="utf-8"
    )
    assert "ARCHITECTURE_LEDGER_SYNC_ENABLED" in workflow
    assert "ARCHITECTURE_LEDGER_BILLING_APPROVED" in workflow
    assert "tools/post_merge_decision_sync.py" in workflow
    assert "permissions:" in workflow
    assert "contents: write" in workflow
