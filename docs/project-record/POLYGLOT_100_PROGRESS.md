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
| 17 | T93: fast/expensive CI separation in `Polyglot Unified CI & Security Gate` (polyglot_ci.yml) — cheap Python audit (status + security-scan) always runs; a change-detection step (HEAD vs PR base / push predecessor; zero-OID, empty or unknown diff falls back to the full expensive path, fail-closed) gates the Flutter SDK/analyze/test steps to non-docs diffs; same-ref concurrency cancellation added; docs-only PRs skip the Flutter job; check/job names unchanged (`verify`). 6 contracts (tests/test_t93_ci_separation.py); detection logic simulated on scratch git repos (docs-only→fast, code/workflow→full, root README.md→fast, zero-OID/empty diff→full); 4 pre-existing workflow-cache test failures verified identical on clean tree (stash-verified), not introduced here | PR #1199 merged @ c7913abea | MERGED |
| 10 | red-line fix: removed excluded-language pack stub assets/packs/he.json | PR #1191 merged @ d5dc8cef9 | MERGED |
| 11 | T66/T70-adjacent: fail-closed guard against excluded-language pack assets in registry_sync.py --check | PR #1192 merged @ ac048707f | MERGED |
| 12 | T71: measured, provenance-backed content inventory (708 files, 5002 units, 27 languages with content; 73 measure zero — factory harvest pending) | PR #1193 merged @ e87f0f90c | MERGED |
| 13 | T71-adjacent: Language Registry Guard CI now runs `content-inventory --check`, failing the gate on measured-content drift | PR #1195 merged @ 825a366b2 | MERGED |
| 9 | T69: transactional, idempotent, recoverable migrations — `SafeLearnerMigration.applySafeMigrations` runs DDL + journal write in one transaction with pragma-guarded ALTERs and ConflictAlgorithm.ignore journaling; fixed `MigrationJournal` recording the timestamp as the migration id (dedupe never worked); `PairProgressDatabase.attach` now runs full bootstrap in one transaction | PR `feat/transactional-migrations-t69` | merged to `main` as `09630f748` via PR #1189 | MERGED |
| 14 | T70: content packs separated from private learner state — bundled golden German pack now installs to the shared pack storage root (`getApplicationSupportDirectory()/packs/polyglot_content_v2.db`) instead of the private `getDatabasesPath()` directory that holds `user_progress_v2.db`; legacy hash-matching copies in the databases dir are retired after the canonical install; content packs are regenerable from bundled assets, learner state is never touched | PR `feat/storage-separation-t70` | MERGED |
| 15 | Factory lineage anchor: #1181 (`ab207624e`) landed the `content-factory/` import as a single-parent commit, flattening history. Merged `consolidate/content-factory` with `-s ours` so the source HEAD `ca821e59ac` and import commit `070b88776` are ancestors of `main` (verified `git merge-base --is-ancestor`, both true); `content-factory/IMPORT_PROVENANCE.md` updated to record the two-step landing; tree otherwise byte-identical (577 tip diffs were stale-base artefacts, 0 content reverts). Duplicate PR #1182 closed as superseded | PR `increment/anchor-factory-lineage` | MERGED-ON-PUSH |
| 16 | Secrets incident audit (owner red-line): classified all 305 Gitleaks findings from Security Audit run 43681022541 — 1 real-format GitHub PAT in `get-app` history @ `b19dfd490` (2026-10-11, in main, all branches, 21 tags), 2 test-only ED25519 key pairs @ `a040e5b08`, 302 false positives (canonical_key fixtures, SHA-256 digests, RFC test vectors, placeholder constants, plan-doc prose). Current tree verified CLEAN (`scoped_security_audit.py` PASS; no ghp_/PEM in tree; gh session token is a different `gho_` credential). Enabled GitHub secret scanning + push protection on the repo (was off). NO history rewrite performed: irreversible; dangles lineage anchor `ab207624e`, all receipts and 100 open PRs; revocation is owner-only and is the only effective remediation; no force-push without explicit owner authorization. Incident record + checkpoint committed; owner revocation tracked in issue #1198 | commit `d944c53fc` merged to `main` as `45308c1ce` | MERGED |

|| 18 | T94: build artifact provenance — `tools/polyglot/build_provenance.py` generates a reproducible pinned section (SHA-256 + bytes of 8 tracked build inputs: pubspec, Dart catalog, registry artifacts, content inventory) plus a descriptive volatile section (sourceCommit + subject, generatedAt, Python/OS environment, CI run metadata); `--check` fails closed on checksum/size/version drift, missing pinned entries, malformed digests, or missing sourceCommit; volatile excluded from the comparison so the artifact stays reproducible; `assets/registry/build_provenance.json` (pinned fileCount=8); 10 fail-closed contracts | PR #1200 merged @ 57fdc6dfd | MERGED |
| 19 | T96: release artifact traceability to exact source commits — `tools/polyglot/release_traceability.py` binds each release artifact (apk/aab) to `GITHUB_SHA` (fail-closed: on CI it must equal `git rev-parse HEAD`, and `GITHUB_SHA` must be present), the canonical pubspec version, the T94 verified provenance record (checksum), and the artifact SHA-256 + size; `--write`/`--check` modes; `build_apk.yml` + `build_aab.yml` wire provenance verify + traceability write/check before publish; AAB version no longer hardcoded (was `3.3.10+133`, drifted from pubspec `1.0.0+1`) — now derived from pubspec.yaml at build time; 18 fail-closed contracts; quality_gate failure set stash-verified identical to baseline (49F/119P/10S) | PR #1202 merged @ c4b2367cd | MERGED |
|| 20 | T97: safe rollback to last-known-good application versions — `tools/polyglot/lkg_rollback.py`: `--promote` certifies a release as LKG only after the T96 traceability record verifies against the artifact, the committed T94 provenance record and the current checkout (any drift fails closed, nothing promoted); `--check` verifies structure/embedded-traceability-snapshot SHA-256/internal consistency/source-commit existence (`git cat-file -e`) and re-hashes artifact bytes with `--artifact`/`--require-artifact` (atomic write via tmp+rename); `--plan` emits a fail-closed JSON rollback plan (re-publish the LKG artifact pinned by SHA-256, rebuild from its source commit), refuses no-op rollbacks (current bytes == LKG bytes) and refuses to plan from an invalid LKG record; `build_apk.yml` + `build_aab.yml` promote the LKG record after the T96 step and upload/release it; pack-side half already shipped as T68 | PR #1204 merged @ 5c3afd886 | MERGED |

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
- PR #1187 (`agent/security-hardening`) is BLOCKED: merge conflict in
  `lib/core/storage/atomic_database_installer.dart` and, more fundamentally,
  its truthful Security Audit fails on (a) the leaked-PAT/test-key findings in
  history (see increment 16 — owner revocation, not a code fix) and (b)
  pre-existing offline-policy violations (`http`, `cached_network_image` as
  direct deps + `package:http`/`dart:io` network capabilities) that conflict
  with the strict offline-only policy. It must not be merged while it puts
  `main` red, and the policy-vs-product conflict needs an owner decision.
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
