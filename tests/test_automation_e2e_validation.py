from tools.automation.e2e_harness import run_e2e_validation


def test_e2e_task_read_dispatch_and_ledger_update(tmp_path):
    report = run_e2e_validation(tmp_path)

    assert report["status"] == "PASS"
    assert report["dry_run_state"] == "DRY_RUN"
    assert report["dispatch_state"] == "DISPATCHED"
    assert report["task_id"] == "READY_TASK"
    assert report["claim_count"] == 1
    assert report["ledger_status"] == "COMPLETED"
    assert report["provider_calls_executed"] == 0
    assert report["billing_changes"] == 0
