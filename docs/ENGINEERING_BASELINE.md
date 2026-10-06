# Engineering Baseline — 2026-10-06

## Frozen anchor

Owner-approved engineering anchor:

`main@d022ce7d6c09f5e25098fd1e30821b30f1f03de4`

This anchor contains the three completed consolidation steps that must not be reimplemented in later tasks:

1. tracked release-signing secret removal;
2. zero-billing GitHub Actions hardening already integrated at that point;
3. production bootstrap modularization, with `lib/main.dart` reduced to the thin entrypoint.

## Live-main reconciliation at freeze time

At Task 0 execution time, live `main` had already advanced by one direct descendant commit:

`8f34b8742acb61cc171ffab1b97bdf60c37eab8d`

Its parent is exactly the frozen anchor `d022ce7d6c09f5e25098fd1e30821b30f1f03de4`.

Therefore:

- `d022ce7...` is the immutable engineering baseline anchor requested by the owner.
- `8f34b874...` is the live continuation already integrated on top of that anchor.
- New implementation branches must start from the latest live `main` descendant of this anchor, never by resetting or force-moving `main` back to the anchor.
- The post-anchor build/signing stabilization in `8f34b874...` must be preserved unless a later scoped task explicitly changes it.

This distinction prevents a stale-baseline reset from regressing work that was integrated after the anchor was selected.

## Open pull-request audit at freeze time

The following open PRs were inspected before creating this baseline record:

| PR | Scope summary | Collision guidance |
| --- | --- | --- |
| #508 | `.circleci/config.yml` aggregate required-quality gate | Treat CircleCI/required-check work as owned by this PR until reconciled. |
| #506 | Phase3 production UI, `lib/main.dart`, saved words, quick review | Do not modify overlapping production UI/root files without explicit reconciliation. |
| #497 | Play deployment workflow + Fastlane | Do not modify Play deployment automation in unrelated tasks. |
| #454 | Manifest + SRS SQLite corpus + runtime/provider + `lib/main.dart` | Historical/draft overlapping architecture; never merge or copy blindly. |
| #449 | Manifest + notification/timezone + indexed corpus/runtime + `lib/main.dart` | Broad stale architecture overlap; reconcile before touching those paths. |
| #208 | Broad SRS/audio/services/UI/runtime changes | Large stale draft; no broad cherry-pick or merge into current architecture. |
| #202 | Generated Dart corpus + `lib/main.dart` + V35/test wiring | Conflicts with current composition/content direction; no blind reuse. |
| #199 | Progress/database/test state | Reconcile before persistence/progress work. |
| #198 | TTS service/test | Reconcile before TTS service changes. |

No open PR modifies this baseline document.

## Scope laws for subsequent tasks

1. One task = one isolated branch.
2. Start from the latest live `main` that descends from the frozen anchor.
3. Use `[skip ci] [skip build]` on engineering delivery commits unless hosted execution is explicitly intended.
4. Do not re-run or reimplement completed signing-secret removal, bootstrap modularization, or existing zero-billing guards merely because historical files/tests still mention older topology.
5. Do not delete compatibility code before a production reachability proof.
6. Cleanup tasks must not change SRS, SQLite, persistence, pack-admission, or runtime behavior unless that behavior is explicitly in scope.
7. Inspect current open PR file scopes before mutating any path.
8. Live GitHub `main` and exact-HEAD evidence supersede stale documentation.

## Task 0 exit condition

Task 0 is complete when this record is integrated into `main` and the resulting main SHA is recorded. That resulting SHA becomes the concrete starting ref for the next implementation branch while retaining `d022ce7...` as the immutable baseline anchor.
