# DEUTSCH-IMPROVE-05: Offline recovery test handoff

This is an isolated test-only Draft PR. It is NOT evidence that the Flutter runtime has passed.

## Baseline and scope

- Base: staging/v2-full-platform at 8dee49f1ab2a82e023fe6f93067fa980d8471bb8
- PR: https://github.com/moaz76943-creator/deutsch-build/pull/149
- All modified paths: test/offline_recovery/**
- No production files, real learner data, or workflows changed.

## Executable independent reproduction

    python3 -m unittest test/offline_recovery/sqlite_failure_reproduction.py -v

The standalone Python sqlite3 test models orphaned foreign keys invisible to integrity_check, review rollback, and a backup rename crash window. Three independent scenarios were executed locally with Python 3 standard library: PASS. These tests do NOT execute the Dart application.

## Actual Flutter validation: NOT_RUN

    flutter test test/offline_recovery/

Flutter SDK and Dart SDK were absent in the current execution environment. Do NOT claim Flutter tests passed. The new suite deliberately contains RED regression cases on the existing staging base:

- New sqlite_v2_reader_acceptance_test.dart uses real SQLite FFI to reject a normal table masquerading as FTS5 and orphaned example rows before pack activation; also tests an intact v2 schema control.
- PR #142 currently owns lib/services/database_service.dart and has been notified. Current staging schema reader does not probe FTS5 MATCH or foreign_key_check.
- PR #139 owns the delta patch foreign_key_check fix.
- PR #131 owns false-ready database bootstrap after silent seeding.
- PR #134 owns rejection of fractional persisted SRS counters.
- IsolatedTaskQueue currently reuses the old session epoch during recursion; epoch-handoff regression is test-only pending ownership.
- PR #55 owns installer/backups/registry recovery. Power-loss fault injection is not yet run.
- PR #135 uses process-local review-event maps; durable replay safety across process death is not proven.
- PR #147 rewrites the same SRS service modified by PR #134, with incompatible public APIs. Resolve before merge.
- Persistent worker changes overlap across Draft PRs #52, #96, #97 and #130; no production edits permitted.

## Remaining verification gates

1. Resolve the owner matrix and PR dependency order first.
2. Run the targeted Flutter tests on the exact reconciled PR SHA; capture logs and run IDs.
3. Verify true Android process termination after pack rename and SRS commit, with LKG and learner data retained.
4. Never count NOT_RUN, SKIPPED or CI from unrelated SHA as PASS.
5. If an separately authorized lib/ change occurs, verify build-blocking errors only using: dart analyze lib/ 2>&1 | grep "error •".
6. Keep Draft; do not merge outside the designated integration coordinator.

Status: IMPLEMENTED_NOT_VERIFIED.
