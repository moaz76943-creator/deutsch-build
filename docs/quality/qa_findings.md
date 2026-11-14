# QA Findings — DEUTSCH بالعربي (Room 3 Independent QA)

**Reviewer:** Room 3 — Independent QA Architect / Security Verifier / Reliability Engineer
**Base SHA:** ab207624e (origin/main, 2026-11-15)
**Branch:** agent/qa-verification
**Evidence log:** `/data/data/com.termux/files/usr/tmp/opencode/qa_pytest_excl3.log` (209 failed / 1175 passed / 12 skipped in 89.30s)
**Registry check:** `content-factory/catalog/validate_registry.py` → OK 100 languages, Hebrew excluded (exit 0)

## QAD-001 — Python canonical test suite cannot be collected (P1)
- **Path:** `tests/test_v166_gradle_wrapper_bootstrap.py`, `tests/test_v168_gradle_wrapper_stability.py`, `tests/test_v221_ci_secret_hygiene.py`
- **Cause:** collection-time `FileNotFoundError` reading `.github/workflows/build-apk.yml` (hyphen), but the actual file is `.github/workflows/build_apk.yml` (underscore).
- **Effect:** `pytest tests/` aborts collection → no canonical result at all.
- **Proposed fix:** point tests at `build_apk.yml`, or rename workflow to match tests (Room 2/owner decides).

## QAD-002 — False GREEN CI on `main` (P0-equivalent for process integrity)
- **Evidence:** `Polyglot Unified CI & Security Gate` (merge-gating) runs only `flutter test test/core/polyglot/`. The 970-file Dart suite under `test/` and the ~280-file Python suite under `tests/` are NOT exercised by this workflow.
- **Measured:** full Python suite at ab207624e → 209 failed / 1175 passed / 12 skipped (exit 1). Yet `gh run` reports Polyglot CI = success on main.
- **Impact:** merges are gated by a narrow slice; failures in the wider suite are invisible. "Green" ≠ verified.

## QAD-003 — Fake Dart security tests (`expect(true, isTrue)`) (P1)
- **Instances:** 22 across 15 files, e.g. `test/high_priority_security_integrity_tests.dart` (3), `test/enhanced_vault_security_tests.dart` (2), `test/features/core_data/core_*_ingestion_test.dart` (8).
- **Cause:** tests document "verified" invariants (no network permission, backup disabled, vault round-trip) but assert nothing.
- **Proposed fix:** replace with real assertions (manifest parse, vault seal/unseal round-trip); Room 1 owns app code, Room 2 owns security.

## QAD-004 — False `terms_count` metadata on 100 orphan core packs (P1, content integrity)
- **Evidence:** 100 `*_core_a1.pack.gz` files on disk (not referenced by manifest) carry `terms_count=150` with zero terms. Regression test: `tools/qa_audit/regression_tests/test_orphan_pack_false_terms_count.py` → 1 failure (exit 1).
- **Manifest:** honest (`release_status=BLOCKED_DEPENDENCY`, `intellectual_property_status=UNVERIFIED_RIGHTS`, `is_active=false` for all 100).
- **Content depth:** manifest packs contain 50 domain labels + 0 vocabulary items.

## QAD-005 — Security audit is fail-open (P0)
- **Path:** `.github/workflows/security_audit.yml`, `Enforce security decision` step.
- **Cause:** `failed=1` branch executes `exit 0` instead of `exit 1`.
- **Effect:** security findings never fail the workflow.
- **Test contract:** `tests/quality_gate/test_security_audit_decision.py` — 12 param cases fail with `assert 0 != 0`.
- **Proposed fix (Room 2 owns CI):** change `exit 0` → `exit 1` in the failed branch.

## QAD-006 — Crude manifest assertion (test accuracy)
- **Path:** `tests/test_final_release_hardening_contract.py::test_manifest_keeps_only_currently_used_release_permissions`
- **Cause:** asserts `"android.permission.INTERNET" not in manifest`, but manifest declares it with `tools:node="remove"` (i.e. removed at merge). Test is a false positive, not a privacy defect.
- **Verdict:** manifest is fail-closed (removes network permissions). Test needs intent-aware parsing.

## QAD-007 — Test rot: stale references to removed files/workflows (P2)
- Examples: `engineering-ci.yml`, `quality.yml`, `build-apk.yml` (hyphen), `lib/core/storage/local_db/learner_state_database.dart`, `legacy_learner_snapshot_reader.dart`, `learner_state_migration.dart` — all absent.
- Effect: ~dozens of collection/runtime errors among the 209 failures.

## Verified PASS (with real evidence)
- Registry: 100 languages, Hebrew excluded, validator exit 0.
- Manifest SHA-256: 100/100 match, 100/100 size match, 0 missing.
- Pack gzip/JSON: 204 packs parse cleanly.
- Polyglot CI on a8dfd7788: success (narrow slice).
- Python suite non-collection: 1175 passed.
- Security audit workflow structure (triggers, permissions, fetch-depth, gitleaks sha256) validated by tests that passed.
EOF
echo done