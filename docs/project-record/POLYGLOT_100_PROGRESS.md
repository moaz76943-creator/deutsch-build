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
| 3 | Make the whole Dart suite compilable: 511 files imported the undeclared `package:test`. Swapped to the SDK-provided `package:flutter_test` (0 remaining occurrences) | `fix/test-sdk-imports` / PR #1180 | OPEN — waiting on CI |
| 4 | History-preserving import of the content factory under `content-factory/` (877 files, two-parent merge) + provenance record | `consolidate/content-factory` | IN PROGRESS |
| 5 | T40: machine-readable readiness report (`assets/registry/readiness_report.json`) separating registration from content-complete and production-ready status; content-complete reported as not-derivable, never inferred from registration; `--check` now fail-closed on report drift | `chore/registry-readiness-report` | OPEN — awaiting CI/merge |

## Verified facts (not claims)

- `main` HEAD before this work: `c5389fe6d9890d765b1220b2dbd362fee50c40c5`.
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
- `assets/database/master_100_languages_spec.json` still declares
  `supported_languages_count: 100` while listing 10 languages; it is a
  subset/factory view, not the registry, and must be regenerated from
  `assets/registry/languages_100.json` (task queued).

## Next queued increments

1. Regenerate the secondary catalogs (`master_100_languages_spec.json`,
   `assets/lang_data/catalog.json`, `lib/core/i18n/language_registry.dart`) from
   the canonical registry so no divergent language count survives.
2. Machine-readable PR triage: classify all 787 open PRs (empty diff / unique
   content / stale base / duplicate) and absorb unique content before closing
   anything.
3. Absorb content-factory unique assets into the application tree with
   equivalence proof (packs, standards, legal ledger).
4. Security/trust tasks 21–30 (audit exit codes, secret scanning, path and
   archive hardening, bounded downloads).
