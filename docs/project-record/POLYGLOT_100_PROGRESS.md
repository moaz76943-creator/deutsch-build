# POLYGLOT 100 — durable progress ledger

Owner goal: one unified public repository on `main` with **exactly 100**
languages, Hebrew excluded, and no earlier work lost.

Integration target: `moaz76943-creator/deutsch-build@main`.
Source content factory: `moaz76943-creator/-offline-packs-store` (retained until
the owner authorises retirement).

Status vocabulary: **MERGED** (in `main`, SHA recorded) · **OPEN** (PR awaiting
CI/merge) · **IN PROGRESS** · **BLOCKED** (with the real blocker) · **QUEUED**.

## Merged increments

| # | Increment | Commit | Evidence |
|---|---|---|---|
| 1 | Single canonical 100-language registry, Hebrew (`he`/`iw`) permanently excluded, generated JSON registry + validator + CI guard | `56d3d097f` | `registry_sync.py --check` exit 0 (100 languages, Hebrew excluded) locally; `Registry policy (100 languages, no Hebrew)` check PASS on PR #1178 and on `main` |
| 2 | Repaired dead guarded auto-merge workflow (duplicate `permissions.contents`) and made `Polyglot Unified CI & Security Gate` use the pinned Flutter SDK instead of bare Dart | `6bf297fab` | `main` push run of *Polyglot Unified CI & Security Gate* = success (it failed on every prior commit, including `c5389fe`); workflow duplicate-key scan 0 invalid |

## Open / in progress

| # | Increment | Branch / PR | State |
|---|---|---|---|
| 3 | Make the whole Dart suite compilable: 511 files imported the undeclared `package:test`. Swapped to the SDK-provided `package:flutter_test` (0 remaining occurrences) | merged to `main` as `a8dfd7788` via PR #1180 | MERGED |
| 4 | History-preserving import of the content factory under `content-factory/` (877 files, two-parent merge) + provenance record | merged to `main` as `ab207624e` via PR #1181 | MERGED |
| 5 | Regenerate the secondary catalogs (`master_100_languages_spec.json`, `assets/lang_data/catalog.json`, `lib/core/i18n/language_registry.dart`) from the canonical registry | merged to `main` as `7d0de7dd0` via PR #1183 | MERGED |
| 3b | Absorb content-factory `standards/` (directed_pairs, lexical, morphology) + `tools/factory_extensions/directed_translation_scale/` byte-identical | merged to `main` as `aefd1b989` via PR #1184 (base `main` @ `7d0de7dd0`; progress-log conflict resolved by merge, no force-push) | MERGED |
| 6 | T40: machine-readable readiness report (`assets/registry/readiness_report.json`) separating registration from content-complete and production-ready status; content-complete reported as not-derivable, never inferred from registration; `--check` now fail-closed on report drift | merged to `main` as `588bb7dd6` via PR #1185 | MERGED |
| 7 | T66/T67: pack admission bounds — 256 MiB file-size ceiling, per-table (1,000,000) and total (5,000,000) row-count bounds on the compile-time allowlist, `PRAGMA busy_timeout = 5000` on the admission connection, decompression-ratio ceiling constant; fail-closed with quarantine at every bound | merged to `main` as `cf719c23b` via PR #1186 | MERGED |
| 8 | T68: last-known-good pack preservation — installer backs up the active pack to `<target>.lastknowngood` before atomic replacement, restores it if the replacement rename fails, exposes `restoreLastKnownGood()` for boot-time recovery, never deletes the backup on success | merged to `main` as `dd44b2466` via PR #1188 | MERGED |
| 9 | T69: transactional, idempotent, recoverable migrations — `SafeLearnerMigration.applySafeMigrations` runs DDL + journal write in one transaction with pragma-guarded ALTERs and ConflictAlgorithm.ignore journaling; fixed `MigrationJournal` recording the timestamp as the migration id (dedupe never worked); `PairProgressDatabase.attach` now runs full bootstrap in one transaction | PR `feat/transactional-migrations-t69` | merged to `main` as `09630f748` via PR #1189 | MERGED |

## Verified facts (not claims)

- `main` HEAD before this work: `c5389fe6d9890d765b1220b2dbd362fee50c40c5`.
- Live `origin/main` at this record (2026-11-15): `2b77cc218` (includes
  increments 1–4 via PRs #1178–#1181 plus content/compliance increments).
- `deutsch-build@main` was **not** branch-protected; there were no required
  checks, which is why a permanently failing workflow did not block merges.
- `Polyglot Unified CI & Security Gate` failed on `c5389fe` with
  `Because deutsch_bilarabi depends on flutter_test from sdk which doesn't
  exist (the Flutter SDK is not available), version solving failed.`
- `.github/workflows/auto-merge.yml` was rejected by GitHub (duplicate YAML key
  `contents`), so every guarded-auto-merge run failed with no logs.
- Open PRs at the start of the session: **457** in `deutsch-build`
  (455 draft, 2 ready, 362 targeting `main`) and **330** in
  `-offline-packs-store` (330 draft, most with 0 changed files).
- Canonical catalog before increment 1: 100 profiles **including `he`**;
  `assets/languages/` had 101 placeholder stubs including `he.json` and no
  `zh.json`.

## Evidence debt (must not be reported as success)

- No Dart or Flutter SDK exists in the Termux workspace, so `flutter analyze`
  and `flutter test` cannot be run locally. All executable evidence comes from
  GitHub Actions runs.
- 455 draft PRs have not been triaged for unique content yet; several may hold
  work that must be absorbed before they are closed.
- Increment-5 PR #1183 evidence: `registry_sync.py --check` exit 0; 24 local
  structural assertions pass; `PYTHONPATH=. pytest` on the three registry-adjacent
  suites = 11 passed; GitHub CI rollup = 2 SUCCESS (Offline-First Security
  Audit, verify), 12 path-filtered SKIPPED, 0 FAILURE. Dart/Flutter still
  cannot be run locally; Dart side verified statically only.

## Next queued increments

1. DONE 2026-11-15 — regenerated via PR #1183 (`chore/regenerate-secondary-catalogs`,
   cherry-picked `64c1c4e52` @ `4754fba83` onto `main` @ `2b77cc218`).
   `master_100_languages_spec.json` = 100 languages, `catalog.json` = 100/9900,
   `language_registry.dart` = 100 entries; he/iw excluded throughout.
2. DONE 2026-11-15 — machine-readable triage of all 787 open PRs completed
   (state/PR_TRIAGE_2026-11-15.md, state/pr_unique_content.json; tasks 11–12);
   no PR closed/merged at triage time. Absorption decisions pending.
3. DONE 2026-11-15 — absorbed `standards/` (directed_pairs, lexical,
   morphology) + `tools/factory_extensions/directed_translation_scale/`
   byte-identical from the content-factory import onto
   `chore/absorb-factory-standards` (see
   docs/project-record/INCREMENT3_ABSORPTION_2026-11-15.md; directed_pairs/lexical/
   morphology unittests OK; registry_sync --check exit 0) via PR #1184 @
   `f46af1abd` (base `main` @ `3273e013d`); merge authorized by owner mandate.
   packs/ BLOCKED by the rights/provenance gate; proficiency standard BLOCKED
   pending an owner decision on canonical-registry proficiency metadata (must
   not import the factory's stale catalog registry); legal ledger kept (app
   copy better); factory catalog superseded by the canonical registry.
4. DONE 2026-11-15 — security/trust tasks 21–30 landed on `agent/security-hardening`
   (commits `599c28ac8`, `be7435f67`; 60 tests passed) — see state/TASK_LOG.md.
