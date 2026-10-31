from copy import deepcopy
from datetime import datetime, timedelta, timezone
import json
import multiprocessing
import os
import sqlite3
import pytest

from tool.claim_ledger import (
    ClaimConflict,
    LedgerError,
    acquire,
    dispatch_allowed,
    empty_ledger,
    fenced_dispatch_allowed,
    persist_expiry_observation,
    require_blob_cas_match,
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
    # Keep the synthetic ledger's new epoch/generation internally coherent;
    # otherwise the integrity guard rightly reports truncated lineage first.
    first["last_epoch"] = 2
    first["generation"] = 2
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



def test_truncated_persisted_history_never_reuses_original_epoch():
    original = acquire_one()
    broken = deepcopy(original)
    broken["claims"] = []
    with pytest.raises(LedgerError, match="truncated claim history"):
        validate_ledger(broken, now=NOW)
    claim = original["claims"][0]
    released = release(original, claim_id=claim["claim_id"], owner_role="CENTRAL",
                       epoch=1, now=NOW + timedelta(minutes=1), expected_generation=1)
    broken = deepcopy(released)
    broken["claims"] = []
    with pytest.raises(LedgerError, match="truncated claim history"):
        validate_ledger(broken, now=NOW + timedelta(minutes=2))
    next_ledger = acquire(
        released, req(task_id="SECOND", branch="other/branch", paths=["other/file.py"]),
        now=NOW + timedelta(minutes=2), observed_main_sha=MAIN,
        observed_branch_head=HEAD, expected_generation=2)
    assert next_ledger["last_epoch"] == next_ledger["claims"][-1]["epoch"] == 2


def test_highwater_must_be_integral_complete_and_durable():
    ledger = acquire_one()
    for value in (None, -1, 0, 2, True, "1"):
        bad = deepcopy(ledger)
        bad["last_epoch"] = value
        with pytest.raises(LedgerError):
            validate_ledger(bad, now=NOW)
    genesis = empty_ledger(MAIN)
    del genesis["last_epoch"]
    assert validate_ledger(genesis, now=NOW)["last_epoch"] == 0
    first = acquire(genesis, req(), now=NOW, observed_main_sha=MAIN,
                    observed_branch_head=HEAD, expected_generation=0)
    assert first["last_epoch"] == 1
    del first["last_epoch"]
    with pytest.raises(LedgerError, match="missing fencing epoch"):
        validate_ledger(first, now=NOW)


def _separate_process_acquirer(path, ready, go, results, role, crash=False):
    """Independent OS process; isolated SQLite test transport != GitHub CAS."""
    ready.put(os.getpid())
    if not go.wait(20):
        results.put(("BARRIER_TIMEOUT", os.getpid()))
        return
    connection = sqlite3.connect(path, timeout=15, isolation_level=None)
    try:
        connection.execute("BEGIN IMMEDIATE")
        ledger = json.loads(connection.execute("SELECT payload FROM state").fetchone()[0])
        try:
            next_state = acquire(ledger, req(owner_role=role), now=NOW,
                                 observed_main_sha=MAIN,
                                 observed_branch_head=HEAD,
                                 expected_generation=ledger["generation"])
        except ClaimConflict:
            connection.execute("ROLLBACK")
            results.put(("DENIED", os.getpid()))
            return
        connection.execute("UPDATE state SET payload=?", (json.dumps(next_state),))
        connection.execute("COMMIT")
        if crash:
            os._exit(71)
        results.put(("GRANTED", os.getpid()))
    finally:
        connection.close()


def _init_sqlite_transport(path):
    with sqlite3.connect(path) as connection:
        connection.execute("CREATE TABLE state(payload TEXT NOT NULL)")
        connection.execute("INSERT INTO state VALUES(?)", (json.dumps(empty_ledger(MAIN)),))


@pytest.mark.skipif(os.name != "posix", reason="fork-backed process isolation uses Linux CI")
def test_two_independent_os_processes_cannot_win_same_sqlite_durable_claim(tmp_path):
    path = str(tmp_path / "claim.db")
    _init_sqlite_transport(path)
    ctx = multiprocessing.get_context("fork")
    ready, go, results = ctx.Queue(), ctx.Event(), ctx.Queue()
    children = [ctx.Process(target=_separate_process_acquirer,
                            args=(path, ready, go, results, role))
                for role in ("WORKER-1", "WORKER-2")]
    try:
        for child in children:
            child.start()
        arrivals = [ready.get(timeout=15) for _ in children]
        assert len(set(arrivals)) == 2
        go.set()
        for child in children:
            child.join(timeout=30)
            assert child.exitcode == 0
        observed = [results.get(timeout=5) for _ in children]
        assert sorted(label for label, _ in observed) == ["DENIED", "GRANTED"]
        assert len({pid for _, pid in observed}) == 2
        with sqlite3.connect(path) as db:
            state = json.loads(db.execute("SELECT payload FROM state").fetchone()[0])
        assert validate_ledger(state, now=NOW)["last_epoch"] == 1
    finally:
        go.set()
        for child in children:
            if child.is_alive():
                child.terminate()
                child.join(timeout=5)


@pytest.mark.skipif(os.name != "posix", reason="fork-backed process isolation uses Linux CI")
def test_real_crashed_process_leaves_expired_claim_locked_until_verified_stop(tmp_path):
    path = str(tmp_path / "crash.db")
    _init_sqlite_transport(path)
    ctx = multiprocessing.get_context("fork")
    ready, go, results = ctx.Queue(), ctx.Event(), ctx.Queue()
    child = ctx.Process(target=_separate_process_acquirer,
                        args=(path, ready, go, results, "CRASHED", True))
    try:
        child.start()
        pid = ready.get(timeout=15)
        assert pid != os.getpid()
        go.set()
        child.join(timeout=30)
        assert child.exitcode == 71
        with sqlite3.connect(path) as db:
            state = json.loads(db.execute("SELECT payload FROM state").fetchone()[0])
        claim = state["claims"][0]
        later = NOW + timedelta(minutes=91)
        with pytest.raises(ClaimConflict, match="reconciliation"):
            acquire(state, req(owner_role="NEW"), now=later,
                    observed_main_sha=MAIN, observed_branch_head=HEAD,
                    expected_generation=1)
        with pytest.raises(ClaimConflict, match="quiescence"):
            reconcile_expired(state, claim_id=claim["claim_id"], expected_epoch=1,
                              reconciler_role="LAB-RECONCILER", now=later,
                              expected_generation=1)
        receipt = {"claim_id": claim["claim_id"], "epoch": 1,
                   "head_sha": HEAD, "pid": pid, "exitcode": 71}
        reconciled = reconcile_expired(
            state, claim_id=claim["claim_id"], expected_epoch=1,
            reconciler_role="LAB-RECONCILER", now=later,
            expected_generation=1, evidence=receipt,
            verify_quiescence=lambda existing, evidence:
                evidence["pid"] == pid and child.exitcode == evidence["exitcode"])
        assert validate_ledger(reconciled, now=later)["claims"][0]["state"] == "RELEASED"
    finally:
        go.set()
        if child.is_alive():
            child.terminate()
            child.join(timeout=5)


def test_corrupt_extreme_highwater_fails_without_allocating_unbounded_epoch_range():
    bad = acquire_one()
    bad["generation"] = 1_000_000_000
    bad["last_epoch"] = 1_000_000_000
    with pytest.raises(LedgerError, match="truncated claim history"):
        validate_ledger(bad, now=NOW)


@pytest.mark.parametrize("reuse", ["task", "branch", "ancestor_path"])
def test_later_released_epoch_cannot_resurrect_earlier_claim(reuse):
    first = acquire_one()
    early = first["claims"][0]
    closed = release(first, claim_id=early["claim_id"], owner_role="CENTRAL",
                     epoch=1, now=NOW + timedelta(minutes=1), expected_generation=1)
    overrides = {"owner_role": "NEW"}
    if reuse == "branch":
        overrides.update(task_id="SECOND", paths=["docs/new.py"])
    elif reuse == "ancestor_path":
        overrides.update(task_id="SECOND", branch="another/branch", paths=["tool"])
    newer = acquire(
        closed, req(**overrides), now=NOW + timedelta(minutes=2),
        observed_main_sha=MAIN, observed_branch_head=HEAD,
        expected_generation=2)
    later = newer["claims"][1]
    finished = release(
        newer, claim_id=later["claim_id"], owner_role="NEW",
        epoch=2, now=NOW + timedelta(minutes=3), expected_generation=3)
    assert validate_ledger(finished, now=NOW + timedelta(minutes=4))["last_epoch"] == 2
    tampered = deepcopy(finished)
    tampered["claims"][0]["state"] = "ACTIVE"
    with pytest.raises(LedgerError, match="superseded"):
        validate_ledger(tampered, now=NOW + timedelta(minutes=4))
    assert not fenced_dispatch_allowed(
        "CLAIM_GRANTED", ledger=tampered, claim_id=early["claim_id"],
        owner_role="CENTRAL", epoch=1, expected_generation=4,
        observed_main_sha=MAIN, branch_head=HEAD, now=NOW + timedelta(minutes=4))

def test_persisted_exact_maximum_ttl_is_valid_at_180_minutes():
    ledger = acquire_one()
    ledger["claims"][0]["expires_at"] = (NOW + timedelta(minutes=180)).isoformat()
    valid = validate_ledger(ledger, now=NOW)
    assert valid["claims"][0]["effective_state"] == "ACTIVE"


def test_persisted_ttl_just_above_180_minutes_fails_closed():
    ledger = acquire_one()
    ledger["claims"][0]["expires_at"] = (
        NOW + timedelta(minutes=180, seconds=1)
    ).isoformat()
    with pytest.raises(LedgerError, match="TTL"):
        validate_ledger(ledger, now=NOW)


def test_persisted_far_future_expiry_does_not_authorize_stale_dispatch():
    ledger = acquire_one()
    claim = ledger["claims"][0]
    claim["expires_at"] = "2099-01-01T00:00:00Z"
    with pytest.raises(LedgerError, match="TTL"):
        validate_ledger(ledger, now=NOW + timedelta(days=1))
    assert not fenced_dispatch_allowed(
        "CLAIM_GRANTED", ledger=ledger, claim_id=claim["claim_id"],
        owner_role=claim["owner_role"], epoch=claim["epoch"],
        expected_generation=ledger["generation"], observed_main_sha=MAIN,
        branch_head=HEAD, now=NOW + timedelta(days=1),
    )


@pytest.mark.parametrize("bad", [True, 1.0])
def test_composed_wire_schema_version_rejects_noninteger(bad):
    data = empty_ledger(MAIN)
    data["schema_version"] = bad
    with pytest.raises(LedgerError, match="schema"):
        validate_ledger(data, now=NOW)


@pytest.mark.parametrize("bad", [True, 1.0])
def test_composed_fence_rejects_noninteger_epoch(bad):
    data = acquire_one()
    claim = data["claims"][0]
    assert not fenced_dispatch_allowed(
        "CLAIM_GRANTED", ledger=data, claim_id=claim["claim_id"],
        owner_role=claim["owner_role"], epoch=bad,
        expected_generation=data["generation"], observed_main_sha=MAIN,
        branch_head=HEAD, now=NOW)


@pytest.mark.parametrize("bad", [True, 1.0])
def test_composed_fence_rejects_noninteger_generation(bad):
    data = acquire_one()
    claim = data["claims"][0]
    assert not fenced_dispatch_allowed(
        "CLAIM_GRANTED", ledger=data, claim_id=claim["claim_id"],
        owner_role=claim["owner_role"], epoch=claim["epoch"],
        expected_generation=bad, observed_main_sha=MAIN,
        branch_head=HEAD, now=NOW)


def test_composed_valid_integer_fence_and_staged_ttl_boundary():
    data = acquire_one()
    claim = data["claims"][0]
    assert fenced_dispatch_allowed(
        "CLAIM_GRANTED", ledger=data, claim_id=claim["claim_id"],
        owner_role=claim["owner_role"], epoch=1,
        expected_generation=1, observed_main_sha=MAIN,
        branch_head=HEAD, now=NOW)
    claim["expires_at"] = (NOW + timedelta(minutes=180)).isoformat()
    assert validate_ledger(data, now=NOW)["claims"][0]["effective_state"] == "ACTIVE"


@pytest.mark.parametrize("bad", [True, 1.0])
def test_c2_transition_expected_generation_rejects_bool_float_all_mutators(bad):
    old = acquire_one()
    c = old["claims"][0]
    later = NOW + timedelta(minutes=91)
    tests = [
        lambda: acquire(old, req(task_id="OTHER-TASK", branch="other/pr94", paths=["tests/disjoint.py"]),
                        now=NOW+timedelta(minutes=1), observed_main_sha=MAIN,
                        observed_branch_head=HEAD, expected_generation=bad),
        lambda: release(old, claim_id=c["claim_id"], owner_role="CENTRAL", epoch=1,
                        now=NOW+timedelta(minutes=1), expected_generation=bad),
        lambda: renew(old, claim_id=c["claim_id"], owner_role="CENTRAL", epoch=1,
                      now=NOW+timedelta(minutes=1), observed_main_sha=MAIN,
                      observed_branch_head=HEAD, expected_generation=bad),
        lambda: reconcile_expired(old, claim_id=c["claim_id"], expected_epoch=1,
                      reconciler_role="CENTRAL-RECONCILER", now=later,
                      expected_generation=bad),
        lambda: refresh_main(old, expected_old_main_sha=MAIN, new_main_sha=OTHER_HEAD,
                      now=NOW+timedelta(minutes=1), expected_generation=bad),
    ]
    for transition in tests:
        with pytest.raises(LedgerError, match="expected_generation"):
            transition()

@pytest.mark.parametrize("bad", [True, 1.0])
def test_c2_reconciliation_receipt_epoch_requires_strict_int(bad):
    old = acquire_one()
    c = old["claims"][0]
    receipt = {"claim_id": c["claim_id"], "epoch": bad,
               "head_sha": HEAD, "verified_stop_receipt": "external-authenticated-owner-stop"}
    with pytest.raises(ClaimConflict, match="quiescence"):
        reconcile_expired(old, claim_id=c["claim_id"], expected_epoch=1,
             reconciler_role="CENTRAL-RECONCILER", now=NOW+timedelta(minutes=91),
             expected_generation=1, evidence=receipt,
             verify_quiescence=lambda current, evidence: True)

def test_c2_valid_integer_generations_and_receipts_still_work():
    old = acquire_one()
    c = old["claims"][0]
    renewed = renew(old, claim_id=c["claim_id"], owner_role="CENTRAL", epoch=1,
                    now=NOW+timedelta(minutes=1), observed_main_sha=MAIN,
                    observed_branch_head=HEAD, expected_generation=1)
    assert type(renewed["generation"]) is int and renewed["generation"] == 2
    receipt = {"claim_id": c["claim_id"], "epoch": 1, "head_sha": HEAD,
               "verified_stop_receipt": "external-authenticated-owner-stop"}
    closed = reconcile_expired(old, claim_id=c["claim_id"], expected_epoch=1,
             reconciler_role="CENTRAL-RECONCILER", now=NOW+timedelta(minutes=91),
             expected_generation=1, evidence=receipt,
             verify_quiescence=lambda current, evidence: True)
    assert type(closed["generation"]) is int and closed["claims"][0]["state"] == "RELEASED"


def test_p1_expiry_observation_is_durable_across_clock_rollback():
    ledger = acquire_one()
    claim = ledger["claims"][0]
    after_expiry = NOW + timedelta(minutes=91)

    observed = persist_expiry_observation(
        ledger,
        claim_id=claim["claim_id"],
        expected_epoch=claim["epoch"],
        now=after_expiry,
        expected_generation=ledger["generation"],
    )
    assert observed["generation"] == 2
    assert observed["claims"][0]["state"] == "RECONCILIATION_REQUIRED"
    assert observed["claims"][0]["expiry_observed_at"] == after_expiry.isoformat().replace("+00:00", "Z")

    rolled_back = NOW + timedelta(minutes=60)
    replay = validate_ledger(observed, now=rolled_back)
    assert replay["claims"][0]["effective_state"] == "RECONCILIATION_REQUIRED"
    assert dispatch_allowed(
        "CLAIM_GRANTED",
        claim=observed["claims"][0],
        branch_head=HEAD,
        now=rolled_back,
    ) is False
    assert fenced_dispatch_allowed(
        "CLAIM_GRANTED",
        ledger=observed,
        claim_id=claim["claim_id"],
        owner_role=claim["owner_role"],
        epoch=claim["epoch"],
        expected_generation=observed["generation"],
        observed_main_sha=MAIN,
        branch_head=HEAD,
        now=rolled_back,
    ) is False


def test_p1_expiry_observation_rejects_preexpiry_stale_epoch_and_stale_generation():
    ledger = acquire_one()
    claim = ledger["claims"][0]

    with pytest.raises(ClaimConflict, match="not expired"):
        persist_expiry_observation(
            ledger,
            claim_id=claim["claim_id"],
            expected_epoch=claim["epoch"],
            now=NOW + timedelta(minutes=89),
            expected_generation=ledger["generation"],
        )
    with pytest.raises(ClaimConflict, match="stale fencing epoch"):
        persist_expiry_observation(
            ledger,
            claim_id=claim["claim_id"],
            expected_epoch=claim["epoch"] + 1,
            now=NOW + timedelta(minutes=91),
            expected_generation=ledger["generation"],
        )
    with pytest.raises(LedgerError, match="stale ledger generation"):
        persist_expiry_observation(
            ledger,
            claim_id=claim["claim_id"],
            expected_epoch=claim["epoch"],
            now=NOW + timedelta(minutes=91),
            expected_generation=ledger["generation"] + 1,
        )


def test_blob_sha_cas_rejects_second_concurrent_writer():
    """Writer 2 must fail closed after writer 1 advances the durable blob."""
    original_blob = "d" * 40
    writer_1_new_blob = "e" * 40

    assert require_blob_cas_match(
        expected_blob_sha=original_blob,
        observed_blob_sha=original_blob,
    ) == original_blob

    with pytest.raises(ClaimConflict, match="stale ledger blob SHA"):
        require_blob_cas_match(
            expected_blob_sha=original_blob,
            observed_blob_sha=writer_1_new_blob,
        )
