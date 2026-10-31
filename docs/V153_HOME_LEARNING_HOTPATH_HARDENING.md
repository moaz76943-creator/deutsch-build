# V153 — Home & Learning Hotpath Hardening

## Goal
Reduce repeated work during Home rebuilds and avoid repeated full attempt scans inside the daily learning-plan selector.

## Changes
- Home now builds only the selected tab instead of constructing all four tab trees on every `build()`.
- The personal daily-path card is stateful and caches its `LearningPath` until the learner-state revision changes.
- Home increments a revision only when `refresh()` reloads learner state, so the daily path is recalculated when progress changes rather than on every rebuild.
- `LearningEngine.buildPlan()` groups attempts by item once and reuses that grouping for item priority and history checks.
- Per-item mastery in the plan now uses the already grouped item attempts via `Mastery.forItemRows` instead of rescanning the complete attempt list.
- Added an explicit semantic label around the current Home content while preserving the existing accessibility audit contract.

## Verification
- V153 focused tests: PASS
- Full Python regression: 250 passed
- compileall (`tests`, `tool`): PASS
- Accessibility audit: PASS, 0 warnings
- Architecture audit: PASS, max UI file 1000 lines, 0 oversized
- Quality audit: PASS, 14,793 entries / 14,793 unique IDs / 14,793 unique German entries
- Security audit: PASS

## Runtime limitation
Flutter/Dart SDK and an Android emulator are not available in this environment, so Flutter compilation, APK build, and Android runtime behavior remain unverified.
