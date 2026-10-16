# DEUTSCH-IMPROVE-08 — Visual and Widget Regression Lab

Scope: `test/visual_regression/**` and `tool/visual_regression/**` ONLY. No production file, Android manifest, baseline image, CI workflow, or learner database changes.

## Source baseline

- Repository: `moaz76943-creator/deutsch-build`
- Base: `staging/v2-full-platform`
- Inspected base HEAD: `8dee49f1ab2a82e023fe6f93067fa980d8471bb8`
- Related open Draft PRs inspected: #132 BiDi, #129 Typography, #87 Responsive UI, #143 Onboarding, #123 Quality Gate.
- Their changed-file lists did not overlap this task's two new directories at inspection time.

## Test coverage — authored, NOT_RUN

`test/visual_regression/startup_recovery_visual_test.dart`
1. Bounded splash timeout displays a critical recovery screen.
2. No packs available displays recovery and limits manual retry.
3. Degraded startup with usable content still permits offline UI.
4. Safe-mode fallback without verified pack does not show learning content.
5. Async boot completion after disposal cannot resurrect a widget.
6. Narrow viewport recovery has no framework exception.

`test/visual_regression/learning_ui_visual_test.dart`
7. Home CTA can be pressed at 320 px width, without asserting database data.
8. Placement selection A2 and continue callback with enlarged text.
9. Learning-path units scroll on a narrow screen with enlarged text.
10. Review flip and a rating advance one visible sample card.
11. First-run onboarding callback functions without network operation.
12. German/Japanese LTR and Arabic RTL are isolated under Arabic UI.

Tests exercise real widgets from the inspected BASE, not fabricated screen copies. They use no production account, network fixture, learner storage, file replacement, or pack installation. A failing case is evidence only AFTER an actual Flutter run.

## Verification

Run from repository root:

```bash
bash tool/visual_regression/run.sh --dry-run
bash tool/visual_regression/run.sh --run
```

The runner refuses to claim success without Flutter SDK and locally resolved packages. It has no pub-get/network step, no auto-fix, and no golden baseline update. With coreutils `timeout` it caps the suite to 300 seconds. A missing SDK or package configuration exits with code 2 and `NOT_RUN`.

Once a Flutter SDK with cached dependencies is available, execute the directed suite and record:
- OS/Flutter/Dart versions, exit code, exact test names, stack traces.
- RenderFlex overflow details and device geometry.
- Screenshots/approved goldens as a subsequent independently authorized baseline, never a blind `--update-goldens`.
- Any production file fix requires a newly verified exclusive owner; out of scope here.

## Explicit gaps

- **GOLDEN_TESTS = NOT_RUN / NOT_CREATED** — pixel baselines require a reproducible Flutter renderer and approved image snapshots.
- **Home SRS storage state = NOT_RUN** — avoids modifying or fabricating learner progress; only CTA is covered.
- **Live PackManager download / offline network simulation = NOT_RUN** — requires injection seams and an isolated fixture.
- **Real FlashcardsScreen persistence, audio errors, pair isolation = NOT_RUN** — use dedicated SRS/SQLite ownership, not demo deck success.
- **Theme contrast, multi-device snapshot diff, back-navigation restoration = NOT_RUN** — need executable renderer and additional harness.
- **Existing tests and required CI = NOT_RUN** — GitHub [skip ci] policy is preserved; do not treat skipped checks as passed.

The test files are candidate regression checks. No visual defect is claimed confirmed, and no production defect is claimed fixed in this PR.

## Handoff capsule

- TASK_ID: DEUTSCH-IMPROVE-08
- Source baseline: 8dee49f1ab2a82e023fe6f93067fa980d8471bb8
- Scope owner: DEUTSCH-IMPROVE-08 / dedicated test and tool paths only
- Production edits: none
- Tests: 12 authored; Flutter execution NOT_RUN (SDK unavailable in authoring environment)
- Follow-up owner action: run `bash tool/visual_regression/run.sh --run` in an authorized Flutter environment; inspect failures before any `lib/` modification; do not merge on skipped CI alone.
