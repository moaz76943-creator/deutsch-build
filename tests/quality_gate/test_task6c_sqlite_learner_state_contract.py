from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def test_task6c_has_dedicated_versioned_learner_sqlite_store():
    store = read("lib/core/storage/local_db/learner_state_database.dart")
    assert "databaseFileName = 'learner_state.sqlite'" in store
    assert "static const int schemaVersion = 1" in store
    for table in (
        "learner_store_meta",
        "learner_attempts",
        "learner_assessment_history",
        "learner_placement_history",
        "learner_favorite_verbs",
        "learner_migration_state",
    ):
        assert table in store
    assert "revision INTEGER NOT NULL DEFAULT 0" in store
    assert "cutover_revision INTEGER NOT NULL" in store
    assert "total_xp" not in store
    assert "current_streak" not in store


def test_task6c_legacy_reader_is_strict_bounded_and_hashes_canonical_snapshot():
    reader = read("lib/services/legacy_learner_snapshot_reader.dart")
    assert "maxPayloadBytes = 4 * 1024 * 1024" in reader
    assert "duplicate_attempt_id" in reader
    assert "duplicate_assessment_id" in reader
    assert "duplicate_placement_id" in reader
    assert "canonicalSnapshotSha256" in reader
    assert "Sha256().hash" in reader
    assert "prefs.remove(" not in reader


def test_task6c_migration_is_transactional_and_marks_verified_last():
    migration = read("lib/services/learner_state_migration.dart")
    assert "database.transaction" in migration
    import_pos = migration.index("await database.importSnapshot")
    readback_pos = migration.index(
        "await database.readSnapshot(executor: txn)", import_pos
    )
    verify_pos = migration.index("_verifyImportedSnapshot(", readback_pos)
    marker_pos = migration.index(
        "await database.insertVerifiedMigrationRecord", verify_pos
    )
    assert import_pos < readback_pos < verify_pos < marker_pos
    assert "canFallbackToLegacy" in migration
    assert "if (revision != 0) return false" in migration


def test_task6c_verified_cutover_routes_four_domains_to_sqlite():
    persistence = read("lib/services/learner_persistence.dart")
    repository = read("lib/services/repository.dart")
    assert "bindVerifiedSqliteAuthority" in persistence
    assert "database.applyAttemptOnce" in persistence
    assert "database.recordAssessmentOnce" in persistence
    assert "database.recordPlacementOnce" in persistence
    assert "database.setFavoriteMembership" in persistence
    assert "stale_legacy_fallback_forbidden" in persistence
    assert "persistence.recordAssessmentOnce" in repository
    assert "persistence.recordPlacementOnce" in repository
    assert "persistence.setFavoriteMembership" in repository
    assert "persistence.applyReviewAttemptOnce" in repository


def test_task6c_bootstrap_migrates_and_hydrates_before_repository_load():
    bootstrap = read("lib/bootstrap/production_bootstrap.dart")
    open_db = bootstrap.index("await LearnerStateDatabase.open()")
    migrate = bootstrap.index(
        "await learnerMigration.migrateAndVerify()", open_db
    )
    bind = bootstrap.index(
        "bindVerifiedSqliteAuthority(", migrate
    )
    repository = bootstrap.index(
        "final learnerRepository = LearnerRepository(", bind
    )
    load_state = bootstrap.index(
        "final state = learnerRepository.load();", repository
    )
    assert open_db < migrate < bind < repository < load_state
    assert "await learnerMigration.canFallbackToLegacy()" in bootstrap


def test_task6c_migration_does_not_delete_legacy_preferences():
    migration = read("lib/services/learner_state_migration.dart")
    reader = read("lib/services/legacy_learner_snapshot_reader.dart")
    assert "prefs.remove(" not in migration
    assert "prefs.remove(" not in reader
