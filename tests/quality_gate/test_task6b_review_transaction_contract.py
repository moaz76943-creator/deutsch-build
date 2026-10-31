from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def test_task6b_repository_routes_reviews_through_envelope():
    repository = read("lib/services/repository.dart")
    assert "ReviewTransactionEnvelope(" in repository
    assert "persistReviewEnvelope(" in repository
    assert "applyReviewAttemptOnce(" in repository
    assert "reviewEventId:" in repository
    assert "persistScheduledReview(" not in repository


def test_task6b_pair_progress_is_the_atomic_acceptance_point():
    store = read("lib/core/storage/local_db/pair_progress_database.dart")
    assert "static const int schemaVersion = 3" in store
    assert "review_transaction_journal" in store
    assert "review_event_id TEXT PRIMARY KEY" in store
    assert "recordScheduledReviewEnvelope" in store
    assert "review_event_payload_mismatch" in store
    assert "loadPendingReviewTransactions" in store
    assert "acknowledgeReviewTransaction" in store


def test_task6b_reconciler_is_bounded_and_has_no_unbounded_loop():
    reconciler = read("lib/services/review_transaction_reconciler.dart")
    assert "maxBatchSize = 128" in reconciler
    assert "reconcilePendingReviewTransactions" in reconciler
    assert "loadPendingReviewTransactions(" in reconciler
    assert "applyReviewAttemptOnce(" in reconciler
    assert "ReviewTransactionSink.attempt" in reconciler
    assert "ReviewTransactionSink.gamification" in reconciler
    assert "while (true)" not in reconciler
    assert "while(true)" not in reconciler


def test_task6b_bootstrap_recovers_immediately_after_pair_binding():
    bootstrap = read("lib/bootstrap/production_bootstrap.dart")
    bind = bootstrap.index(
        "LocalLearningRecoveryPairProgressLease.bind("
    )
    reconciler = bootstrap.index(
        "ReviewTransactionReconciler(", bind
    )
    recover = bootstrap.index(
        "await reconciler.reconcilePendingReviewTransactions(limit: 128);",
        reconciler,
    )
    reload_state = bootstrap.index(
        "final durableState = await learnerRepository.reloadPersisted();",
        recover,
    )
    assert bind < reconciler < recover < reload_state


def test_task6b_gamification_duplicate_payload_is_fail_closed():
    store = read(
        "lib/features/gamification/sqlite_gamification_repository.dart"
    )
    for field in (
        "facet_type",
        "correct",
        "hinted",
        "requested_xp",
        "reviewed_at_utc",
        "timezone_offset_minutes",
    ):
        assert field in store
    assert "gamification_event_payload_mismatch" in store
    assert "_matchesImmutableReviewPayload" in store
