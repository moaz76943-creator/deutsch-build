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
    fenced_dispatch_allowed,
    renew,
    reconcile_expired,
    refresh_main,
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


def test_same_task_duplicate_is_rejected_even_for_same_owner():
    ledger = acquire_one()
    with pytest.raises(ClaimConflict, match="same task"):
        acquire(
            ledger,
            req(branch="other/branch", paths=["tool/other.py"]),
            now=NOW + timedelta(minutes=1),
            observed_main_sha=MAIN,
            observed_branch_head=HEAD,
            expected_generation=1,
        )


def test_same_branch_duplicate_is_rejected_even_for_same_owner_and_disjoint_files():
    ledger = acquire_one()
    with pytest.raises(ClaimConflict, match="same branch"):
        acquire(
            ledger,
            req(task_id="OTHER-TASK", paths=["tool/disjoint.py"]),
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
    # TTL alone is insufficient even when expiry is already observed.
    with pytest.raises(ClaimConflict, match="quiescence"):
        reconcile_expired(
            ledger, claim_id=claim["claim_id"], expected_epoch=1,
            reconciler_role="CENTRAL-RECONCILER", now=later, expected_generation=1,
        )
    evidence = {"claim_id": claim["claim_id"], "epoch": 1, "head_sha": HEAD,
                "verified_stop_receipt": "external-authenticated-owner-stop"}
    closed = reconcile_expired(
        ledger, claim_id=claim["claim_id"], expected_epoch=1,
        reconciler_role="CENTRAL-RECONCILER", now=later, expected_generation=1,
        evidence=evidence,
        verify_quiescence=lambda current, receipt:
            receipt["verified_stop_receipt"] == "external-authenticated-owner-stop",
    )
    assert closed["generation"] == 2
    assert closed["claims"][0]["state"] == "RELEASED"
    assert closed["claims"][0]["reconciled_by"] == "CENTRAL-RECONCILER"
    assert validate_ledger(closed, now=later)["claims"][0]["effective_state"] == "RELEASED"


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
        assert dispatch_allowed(status, claim=claim, branch_head=HEAD, now=NOW) is False


def test_dispatch_requires_active_exact_head_claim():
    claim = acquire_one()["claims"][0]
    assert dispatch_allowed("CLAIM_GRANTED", claim=claim, branch_head=HEAD, now=NOW) is True
    assert dispatch_allowed("CLAIM_GRANTED", claim=claim, branch_head=OTHER_HEAD, now=NOW) is False
    assert dispatch_allowed(
        "CLAIM_GRANTED", claim=claim, branch_head=HEAD, now=NOW + timedelta(minutes=91)
    ) is False
    released = deepcopy(claim)
    released["state"] = "RELEASED"
    assert dispatch_allowed("CLAIM_GRANTED", claim=released, branch_head=HEAD, now=NOW) is False


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


def test_refresh_main_requires_zero_unresolved_claims_and_monotonic_generation():
    active = acquire_one()
    with pytest.raises(ClaimConflict, match="unresolved"):
        refresh_main(
            active, expected_old_main_sha=MAIN, new_main_sha=OTHER_HEAD,
            now=NOW + timedelta(minutes=1), expected_generation=1,
        )
    claim = active["claims"][0]
    released = release(
        active, claim_id=claim["claim_id"], owner_role="CENTRAL", epoch=1,
        now=NOW + timedelta(minutes=1), expected_generation=1,
    )
    advanced = refresh_main(
        released, expected_old_main_sha=MAIN, new_main_sha=OTHER_HEAD,
        now=NOW + timedelta(minutes=2), expected_generation=2,
    )
    assert advanced["generation"] == 3
    assert advanced["main_sha"] == OTHER_HEAD


def test_refresh_main_rejects_stale_old_baseline():
    ledger = empty_ledger(MAIN)
    with pytest.raises(LedgerError, match="stale main baseline"):
        refresh_main(
            ledger, expected_old_main_sha=OTHER_HEAD, new_main_sha="d" * 40,
            now=NOW, expected_generation=0,
        )


def test_repeat_release_is_rejected_without_corrupting_timestamp_invariants():
    ledger = acquire_one()
    claim = ledger["claims"][0]
    released = release(
        ledger, claim_id=claim["claim_id"], owner_role="CENTRAL", epoch=1,
        now=NOW + timedelta(minutes=1), expected_generation=1,
    )
    with pytest.raises(ClaimConflict, match="already released"):
        release(
            released, claim_id=claim["claim_id"], owner_role="CENTRAL", epoch=1,
            now=NOW + timedelta(minutes=2), expected_generation=2,
        )
    assert validate_ledger(released, now=NOW + timedelta(minutes=120))["claims"][0]["effective_state"] == "RELEASED"


def test_maximum_length_task_id_generates_valid_roundtrip_claim_id():
    long_task = "T" * 128
    ledger = acquire(
        empty_ledger(MAIN),
        req(task_id=long_task),
        now=NOW,
        observed_main_sha=MAIN,
        observed_branch_head=HEAD,
        expected_generation=0,
    )
    claim = ledger["claims"][0]
    assert len(claim["claim_id"]) <= 128
    assert validate_ledger(ledger, now=NOW)["claims"][0]["task_id"] == long_task


def test_directory_and_child_file_claims_conflict_in_both_directions():
    for owned, requested in (("tool", "tool/x.py"), ("tool/x.py", "tool")):
        current = acquire_one(paths=[owned])
        with pytest.raises(ClaimConflict, match="overlap"):
            acquire(
                current,
                req(task_id="OTHER", owner_role="OTHER", branch="other/branch",
                    paths=[requested]),
                now=NOW + timedelta(minutes=1),
                observed_main_sha=MAIN,
                observed_branch_head=HEAD,
                expected_generation=1,
            )


@pytest.mark.parametrize("collision", ["task_id", "branch", "paths"])
def test_persisted_conflicting_unresolved_claims_fail_closed(collision):
    first = acquire_one()
    second = deepcopy(first["claims"][0])
    second.update({"claim_id": "other/2", "epoch": 2, "task_id": "OTHER",
                   "branch": "other/branch", "paths": ["docs/other.py"]})
    if collision == "task_id":
        second["task_id"] = first["claims"][0]["task_id"]
    elif collision == "branch":
        second["branch"] = first["claims"][0]["branch"]
    else:
        second["paths"] = ["tool"]
    first["claims"].append(second)
    with pytest.raises(LedgerError, match="conflicting unresolved"):
        validate_ledger(first, now=NOW)


def test_persisted_released_claim_does_not_poison_nonoverlapping_new_owner():
    original = acquire_one()
    claim = original["claims"][0]
    released = release(
        original, claim_id=claim["claim_id"], owner_role="CENTRAL", epoch=1,
        now=NOW + timedelta(minutes=1), expected_generation=1,
    )
    next_state = acquire(
        released, req(task_id="OTHER", owner_role="OTHER"),
        now=NOW + timedelta(minutes=2),
        observed_main_sha=MAIN,
        observed_branch_head=HEAD,
        expected_generation=2,
    )
    assert len(validate_ledger(next_state, now=NOW + timedelta(minutes=2))["claims"]) == 2


def test_release_rejects_clock_regression_within_allowed_read_skew():
    original = acquire_one()
    claim = original["claims"][0]
    with pytest.raises(LedgerError, match="regressing"):
        release(
            original, claim_id=claim["claim_id"], owner_role="CENTRAL", epoch=1,
            now=NOW - timedelta(seconds=10), expected_generation=1,
        )
    assert validate_ledger(original, now=NOW)["claims"][0]["state"] == "ACTIVE"


def test_renew_validates_exact_token_branch_and_extends_heartbeat_without_new_epoch():
    original = acquire_one()
    claim = original["claims"][0]
    later = NOW + timedelta(minutes=40)
    for owner, epoch, head in (("OTHER", 1, HEAD), ("CENTRAL", 2, HEAD),
                               ("CENTRAL", 1, OTHER_HEAD)):
        with pytest.raises((ClaimConflict, LedgerError)):
            renew(
                original, claim_id=claim["claim_id"], owner_role=owner, epoch=epoch,
                now=later, observed_main_sha=MAIN, observed_branch_head=head,
                expected_generation=1,
            )
    renewed = renew(
        original, claim_id=claim["claim_id"], owner_role="CENTRAL", epoch=1,
        now=later, observed_main_sha=MAIN, observed_branch_head=HEAD,
        expected_generation=1,
    )
    refreshed = validate_ledger(renewed, now=later)
    assert refreshed["generation"] == 2
    assert refreshed["claims"][0]["epoch"] == 1
    assert refreshed["claims"][0]["effective_state"] == "ACTIVE"
    assert refreshed["claims"][0]["expires_at"] == (later + timedelta(minutes=90)).isoformat().replace("+00:00", "Z")
    with pytest.raises(ClaimConflict, match="expired"):
        renew(
            original, claim_id=claim["claim_id"], owner_role="CENTRAL", epoch=1,
            now=NOW + timedelta(minutes=91), observed_main_sha=MAIN,
            observed_branch_head=HEAD, expected_generation=1,
        )


def test_reconcile_rejects_unverified_or_mismatched_expired_worker_evidence():
    original = acquire_one()
    claim = original["claims"][0]
    later = NOW + timedelta(minutes=91)
    for evidence, verifier in (
        (None, None),
        ({"claim_id": claim["claim_id"], "epoch": 1, "head_sha": HEAD}, None),
        ({"claim_id": claim["claim_id"], "epoch": 2, "head_sha": HEAD},
         lambda c, e: True),
        ({"claim_id": claim["claim_id"], "epoch": 1, "head_sha": HEAD},
         lambda c, e: False),
    ):
        with pytest.raises(ClaimConflict, match="quiescence"):
            reconcile_expired(
                original, claim_id=claim["claim_id"], expected_epoch=1,
                reconciler_role="CENTRAL-RECONCILER", now=later,
                expected_generation=1, evidence=evidence,
                verify_quiescence=verifier,
            )
    assert original["claims"][0]["state"] == "ACTIVE"


def test_old_fencing_token_cannot_pass_against_newly_persisted_generation():
    first = acquire_one()
    old = first["claims"][0]
    released = release(
        first, claim_id=old["claim_id"], owner_role="CENTRAL", epoch=1,
        now=NOW + timedelta(minutes=1), expected_generation=1,
    )
    assert fenced_dispatch_allowed(
        "CLAIM_GRANTED", ledger=first, claim_id=old["claim_id"],
        owner_role="CENTRAL", epoch=1, expected_generation=2,
        observed_main_sha=MAIN, branch_head=HEAD, now=NOW + timedelta(minutes=2),
    ) is False
    assert fenced_dispatch_allowed(
        "CLAIM_GRANTED", ledger=released, claim_id=old["claim_id"],
        owner_role="CENTRAL", epoch=1, expected_generation=2,
        observed_main_sha=MAIN, branch_head=HEAD, now=NOW + timedelta(minutes=2),
    ) is False
    successor = acquire(
        released, req(owner_role="OTHER"), now=NOW + timedelta(minutes=2),
        observed_main_sha=MAIN, observed_branch_head=HEAD,
        expected_generation=2,
    )
    latest = successor["claims"][-1]
    assert fenced_dispatch_allowed(
        "CLAIM_GRANTED", ledger=successor, claim_id=old["claim_id"],
        owner_role="CENTRAL", epoch=1, expected_generation=3,
        observed_main_sha=MAIN, branch_head=HEAD, now=NOW + timedelta(minutes=2),
    ) is False
    assert fenced_dispatch_allowed(
        "CLAIM_GRANTED", ledger=successor, claim_id=latest["claim_id"],
        owner_role="OTHER", epoch=2, expected_generation=3,
        observed_main_sha=MAIN, branch_head=HEAD, now=NOW + timedelta(minutes=2),
    ) is True


def test_time_arguments_must_be_aware_for_sensitive_transitions():
    with pytest.raises(LedgerError, match="timezone-aware"):
        validate_ledger(empty_ledger(MAIN), now=datetime(2026, 9, 28, 6, 0))
