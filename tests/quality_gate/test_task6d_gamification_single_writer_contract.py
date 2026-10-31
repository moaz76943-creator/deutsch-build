from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[2]


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def method_block(text: str, start: str, end: str) -> str:
    begin = text.index(start)
    finish = text.index(end, begin)
    return text[begin:finish]


def test_task6d_gamification_store_is_revisioned_exclusive_authority():
    store = read(
        "lib/features/gamification/sqlite_gamification_repository.dart"
    )
    assert "static const int schemaVersion = 4" in store
    assert "gamification_store_meta" in store
    assert "revision INTEGER NOT NULL" in store
    assert "if (revision != 0) return false;" in store
    assert "SqliteGamificationRepository._bumpRevision(txn)" in store
    assert "gamification_event_payload_mismatch" in store


def test_task6d_attempt_sink_is_history_only():
    persistence = read("lib/services/learner_persistence.dart")
    block = method_block(
        persistence,
        "Future<ReviewAttemptApplyResult> applyReviewAttemptOnce",
        "Future<LearnerState> recordAssessmentOnce",
    )
    assert "compatibilityXpDelta" not in block
    assert "compatibilityStreakTarget" not in block
    assert "copyWith(\n        xp:" not in block
    assert "copyWith(\n        streak:" not in block
    assert "current.xp +" not in block
    assert "current.streak" not in block


def test_task6d_legacy_buffer_values_are_preserved_not_awarded():
    persistence = read("lib/services/learner_persistence.dart")
    save = method_block(
        persistence,
        "Future<void> save(LearnerState state)",
        "Future<void> _writeLegacy",
    )
    assert "xp: rollback.xp" in save
    assert "streak: rollback.streak" in save
    assert "normalized.xp" not in save
    assert "normalized.streak" not in save


def test_task6d_review_and_conversation_rewards_use_canonical_gamification():
    repository = read("lib/services/repository.dart")
    assert "Future<GamificationSnapshot> loadGamificationSnapshot()" in repository
    assert "persistReviewDeliveryEnvelope(" in repository
    assert "kind: 'conversation'" in repository
    assert "facetType: ReviewFacetType.production" in repository
    assert "requestedXp: correct ? 10 : 2" in repository
    assert "compatibilityXpDelta" not in repository
    assert "compatibilityStreakTarget" not in repository
    record = method_block(
        repository,
        "Future<void> record({",
        "Future<void> recordConversationAttempt({",
    )
    assert "state.streak" not in record
    assert "nextStreak" not in record


def test_task6d_sync_never_promotes_legacy_learner_xp_or_streak():
    mapper = read(
        "lib/features/sync/data/canonical_sync_snapshot_mapper.dart"
    )
    assert "learner.xp" not in mapper
    assert "learner.streak" not in mapper
    assert "totalXp: profile.totalXp" in mapper
    assert "currentStreak: profile.currentStreak" in mapper
    apply_block = mapper[mapper.index("static LearnerState applyToLearnerState"):]
    assert re.search(r"\bxp\s*:", apply_block) is None
    assert re.search(r"\bstreak\s*:", apply_block) is None


def test_task6d_runtime_readers_have_no_learner_xp_streak_fallbacks():
    app = read("lib/ui_v35/app.dart")
    progress = read("lib/ui_v35/progress_pages_detail.dart")
    session = read(
        "lib/features/session/universal_session_orchestrator.dart"
    )
    daily = read(
        "lib/features/daily_drill/application/daily_drill_controller.dart"
    )
    runtime = read("lib/bootstrap/production_runtime.dart")

    assert "state.xp" not in app
    assert "state.streak" not in app
    assert "state.streak" not in progress
    assert "_repository.load().xp" not in session
    assert "learnerState.streak" not in daily
    assert "state.xp" not in runtime


def test_task6d_bootstrap_legacy_values_are_seed_inputs_only():
    bootstrap = read("lib/bootstrap/production_bootstrap.dart")
    persistence = read("lib/services/learner_persistence.dart")
    assert "state.xp" not in bootstrap
    assert "state.streak" not in bootstrap
    assert "loadLegacyGamificationSeed()" in bootstrap
    seed = method_block(
        bootstrap,
        "await openedGamificationRepository.migrateLegacyProfileIfPristine(",
        "final canonicalGamification",
    )
    assert "totalXp: legacyGamificationSeed.xp" in seed
    assert "currentStreak: legacyGamificationSeed.streak" in seed
    load = method_block(
        persistence,
        "LearnerState load()",
        "LearnerState _loadLegacy()",
    )
    assert "xp: 0" in load
    assert "streak: 0" in load


def test_task6d_conversation_uses_same_bounded_recovery_journal():
    pair_store = read(
        "lib/core/storage/local_db/pair_progress_database.dart"
    )
    engine = read(
        "lib/core/progress/offline_pair_progress_engine.dart"
    )
    assert "recordReviewDeliveryEnvelope" in pair_store
    assert "review_event_payload_mismatch" in pair_store
    assert "persistReviewDeliveryEnvelope" in engine
    assert "while (true)" not in pair_store
    assert "while(true)" not in pair_store



def test_task6d_pair_legacy_migration_uses_canonical_gamification_xp():
    lease = read(
        "lib/features/learning/data/local_learning_recovery_pair_progress_lease.dart"
    )
    bootstrap = read("lib/bootstrap/production_bootstrap.dart")
    assert "migratedAchievementPoints: legacy.xp" not in lease
    assert "required int migratedAchievementPoints" in lease
    assert "canonicalGamification.profile.totalXp" in bootstrap
