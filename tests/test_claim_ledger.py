from copy import deepcopy
from datetime import datetime, timedelta, timezone
import json
import pytest

from tool.claim_ledger import (
    ClaimConflict,
    LedgerError,
    acquire,
    dispatch_allowed,
    empty_ledger,
    reconcile_expired,
    release,
    validate_ledger,
)

NOW = datetime(2026, 9, 28, 6, 0, tzinfo=timezone.utc)
MAIN = "a" * 40
HEAD = "b" * 40
OTHER_HEAD = "c" * 40


def req(**overrides):
    value = {
        "task_id": "ATOMIC-CLAIM-LEDGER-CORE-V1-001",
        "owner_role": "CENTRAL",
        "branch": "control/atomic-claim-ledger-v1",
        "expected_head_sha": HEAD,
        "paths": ["tool/claim_ledger.py"],
    }
    value.update(overrides)
    return value


def acquire_one(**request_overrides):
    return acquire(
        empty_ledger(MAIN),
        req(**request_overrides),
        now=NOW,
        observed_main_sha=MAIN,
        observed_branch_head=HEAD,
        expected_generation=0,
    )


def test_acquire_creates_monotonic_fenced_active_claim():
    out = acquire_one()
    claim = out["claims"][0]
    assert out["generation"] == 1
    assert claim["epoch"] == 1
    assert claim["state"] == "ACTIVE"
    assert claim["head_sha"] == HEAD


def test_same_task_different_owner_is_rejected():
    ledger = acquire_one()
    with pytest.raises(ClaimConflict, match="same task"):
        acquire(
            ledger,
            req(owner_role="OTHER", branch="other/branch", paths=["tool/other.py"]),
            now=NOW + timedelta(minutes=1),
            observed_main_sha=MAIN,
            observed_branch_head=HEAD,
            expected_generation=1,
        )


def test_same_branch_different_writer_is_rejected_even_for_disjoint_files():
    ledger = acquire_one()
    with pytest.raises(ClaimConflict, match="same branch"):
        acquire(
            ledger,
            req(task_id="OTHER-TASK", owner_role="OTHER", paths=["tool/disjoint.py"]),
            now=NOW + timedelta(minutes=1),
            observed_main_sha=MAIN,
            observed_branch_head=HEAD,
            expected_generation=1,
        )


def test_overlapping_file_rejected_across_other_task_and_branch():
    ledger = acquire_one()
    with pytest.raises(ClaimConflict, match="overlap"):
        acquire(
            ledger,
            req(task_id="OTHER-TASK", owner_role="OTHER", branch="other/branch"),
            now=NOW + timedelta(minutes=1),
            observed_main_sha=MAIN,
            observed_branch_head=HEAD,
            expected_generation=1,
        )


def test_future_heartbeat_fails_closed():
    ledger = acquire_one()
    ledger["claims"][0]["heartbeat_at"] = (NOW + timedelta(minutes=5)).isoformat()
    with pytest.raises(LedgerError, match="future heartbeat"):
        validate_ledger(ledger, now=NOW)


def test_expired_claim_requires_reconciliation_and_cannot_be_stolen():
    ledger = acquire_one()
    later = NOW + timedelta(minutes=91)
    with pytest.raises(ClaimConflict, match="reconciliation"):
        acquire(
            ledger,
            req(owner_role="OTHER"),
            now=later,
            observed_main_sha=MAIN,
            observed_branch_head=HEAD,
            expected_generation=1,
        )


def test_expired_claim_cannot_be_normal_release_then_reconcile_closes_it():
    ledger = acquire_one()
    claim = ledger["claims"][0]
    later = NOW + timedelta(minutes=91)
    with pytest.raises(ClaimConflict, match="reconciliation"):
        release(
            ledger, claim_id=claim["claim_id"], owner_role="CENTRAL", epoch=1,
            now=later, expected_generation=1,
        )
    closed = reconcile_expired(
        ledger, claim_id=claim["claim_id"], expected_epoch=1,
        reconciler_role="CENTRAL-RECONCILER", now=later, expected_generation=1,
    )
    assert closed["generation"] == 2
    assert closed["claims"][0]["state"] == "RELEASED"
    assert closed["claims"][0]["reconciled_by"] == "CENTRAL-RECONCILER"


def test_stale_main_branch_and_generation_all_fail_closed():
    ledger = empty_ledger(MAIN)
    cases = [
        dict(observed_main_sha="d" * 40, observed_branch_head=HEAD, expected_generation=0),
        dict(observed_main_sha=MAIN, observed_branch_head=OTHER_HEAD, expected_generation=0),
        dict(observed_main_sha=MAIN, observed_branch_head=HEAD, expected_generation=1),
    ]
    for kwargs in cases:
        with pytest.raises(LedgerError):
            acquire(ledger, req(), now=NOW, **kwargs)


def test_release_requires_exact_owner_and_fencing_epoch():
    ledger = acquire_one()
    claim = ledger["claims"][0]
    for owner, epoch in (("OTHER", 1), ("CENTRAL", 2)):
        with pytest.raises(ClaimConflict):
            release(
                ledger, claim_id=claim["claim_id"], owner_role=owner, epoch=epoch,
                now=NOW + timedelta(minutes=1), expected_generation=1,
            )
    out = release(
        ledger, claim_id=claim["claim_id"], owner_role="CENTRAL", epoch=1,
        now=NOW + timedelta(minutes=1), expected_generation=1,
    )
    assert out["claims"][0]["state"] == "RELEASED"


def test_next_claim_epoch_never_reuses_released_fencing_token():
    ledger = acquire_one()
    claim = ledger["claims"][0]
    ledger = release(
        ledger, claim_id=claim["claim_id"], owner_role="CENTRAL", epoch=1,
        now=NOW + timedelta(minutes=1), expected_generation=1,
    )
    out = acquire(
        ledger,
        req(task_id="NEXT-TASK", branch="control/next", paths=["tool/next.py"]),
        now=NOW + timedelta(minutes=2),
        observed_main_sha=MAIN,
        observed_branch_head=HEAD,
        expected_generation=2,
    )
    assert out["claims"][-1]["epoch"] == 2


def test_dispatch_fails_closed_for_all_known_non_granted_statuses():
    claim = acquire_one()["claims"][0]
    for status in (
        "BLOCKED_ACTIVE_CLAIM",
        "UNKNOWN_CLAIM_COVERAGE",
        "STALE_GIT_SNAPSHOT",
        "RECONCILIATION_REQUIRED",
        "CONFLICTING_LEDGER",
        "PREFLIGHT_CLEAR_NOT_A_LOCK",
    ):
        assert dispatch_allowed(status, claim=claim, branch_head=HEAD) is False


def test_dispatch_requires_active_exact_head_claim():
    claim = acquire_one()["claims"][0]
    assert dispatch_allowed("CLAIM_GRANTED", claim=claim, branch_head=HEAD) is True
    assert dispatch_allowed("CLAIM_GRANTED", claim=claim, branch_head=OTHER_HEAD) is False
    released = deepcopy(claim)
    released["state"] = "RELEASED"
    assert dispatch_allowed("CLAIM_GRANTED", claim=released, branch_head=HEAD) is False


def test_invalid_paths_duplicate_epochs_and_incomplete_inventory_fail_closed():
    ledger = acquire_one()
    bad = deepcopy(ledger)
    bad["claims_complete"] = False
    with pytest.raises(LedgerError, match="incomplete"):
        validate_ledger(bad, now=NOW)
    bad = deepcopy(ledger)
    bad["claims"].append(deepcopy(bad["claims"][0]))
    bad["claims"][1]["claim_id"] = "OTHER/1/id"
    with pytest.raises(LedgerError, match="epochs"):
        validate_ledger(bad, now=NOW)
    with pytest.raises(LedgerError, match="canonical"):
        acquire(
            empty_ledger(MAIN), req(paths=["../escape"]), now=NOW,
            observed_main_sha=MAIN, observed_branch_head=HEAD, expected_generation=0,
        )


def test_ledger_is_json_roundtrip_machine_readable():
    value = acquire_one()
    assert json.loads(json.dumps(value, sort_keys=True))["claims"][0]["task_id"] == req()["task_id"]
