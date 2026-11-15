"""Static fail-closed contracts for T69: transactional, idempotent,
recoverable learner-state migrations.

The Dart suite is not run locally (no Flutter SDK); these contracts pin the
migration machinery at source level.
"""
from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
JOURNAL = ROOT / "lib/core/storage/migration_journal.dart"
SAFE = ROOT / "lib/core/database/safe_learner_migration.dart"
PROGRESS = ROOT / "lib/core/storage/local_db/pair_progress_database.dart"


def _src(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def test_journal_records_stable_migration_id_not_timestamp() -> None:
    src = _src(JOURNAL)
    # Regression guard: the old code stored the timestamp string as the id,
    # which made hasMigrated() always false (no dedupe, double-apply risk).
    assert "MigrationRecord(id, epoch)" in src
    assert "DateTime.now().millisecondsSinceEpoch.toString()," not in src


def test_journal_is_idempotent_on_replay() -> None:
    src = _src(JOURNAL)
    assert "if (hasMigrated(id)) {" in src
    assert "return;" in src


def test_migration_executor_runs_inside_one_transaction() -> None:
    src = _src(SAFE)
    assert "Future<void> applySafeMigrations" in src
    assert "await db.transaction((txn) async {" in src
    # Journal table is created inside the same transaction as the DDL.
    journal_create = src.index("CREATE TABLE IF NOT EXISTS $journalTable")
    journal_insert = src.index("await txn.insert(")
    assert journal_create < journal_insert


def test_journal_write_uses_conflict_ignore() -> None:
    src = _src(SAFE)
    assert "conflictAlgorithm: ConflictAlgorithm.ignore" in src


def test_column_adds_are_guarded_by_pragma_inspection() -> None:
    src = _src(SAFE)
    assert "Future<bool> columnExists(String table, String column)" in src
    assert "PRAGMA table_info($table)" in src
    assert "if (await columnExists(table, column)) {" in src
    assert "return; // already applied (idempotency)" in src


def test_step_writes_are_journaled_before_next_step() -> None:
    src = _src(SAFE)
    # The journal row for v1->v2 is written only after the statements ran.
    alter = src.index("addColumnIfMissing('user_progress'")
    insert = src.index("await txn.insert(")
    assert alter < insert


def test_drop_table_prohibition_is_retained() -> None:
    src = _src(SAFE)
    assert "validateMigrationStatements" in src
    assert "Prohibited DROP TABLE detected on protected user table" in src
    assert "protectedUserTables" in src


def test_progress_attach_is_atomic_and_idempotent() -> None:
    src = _src(PROGRESS)
    assert "await database.transaction((txn) async {" in src
    assert "await _ensurePhase16bColumns(txn);" in src
    # Executor-typed helper: transaction and database both satisfy it.
    assert "DatabaseExecutor executor" in src
    assert "if (columns.contains(entry.key)) continue" in src
    assert "CREATE INDEX IF NOT EXISTS idx_pair_card_progress_context" in src


def test_migration_applies_only_forward() -> None:
    src = _src(SAFE)
    assert "if (oldVersion < 2 && newVersion >= 2)" in src
