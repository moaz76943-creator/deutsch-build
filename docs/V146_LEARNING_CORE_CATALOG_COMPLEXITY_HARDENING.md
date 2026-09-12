# V146 — Learning Core & Catalog Complexity Hardening

## Findings
- `CategoriesPage` rebuilt a topic-to-items map from the entire A1 catalog on every widget rebuild.
- `LearningCore.weakestSkill()` materialized a filtered list separately for each skill.
- `LearningCore.skillScores()` repeated the same full attempts scan for every skill.

## Changes
- Added lazy cached `SearchIndex.topicGroups` built directly from the catalog.
- `CategoriesPage` now consumes the cached topic index instead of rebuilding the catalog map in `build()`.
- Added one-pass `_attemptsBySkill()` bucketing in `LearningCore`.
- `weakestSkill()` and `skillScores()` reuse those buckets and avoid repeated list materialization.
- Kept learning semantics, ordering, thresholds, and offline behavior unchanged.

## Verification
- Focused V146 tests: 3 passed.
- Full Python regression suite: 227 passed, 0 failed.
- `python -m compileall -q tests tool`: passed.
- Accessibility audit: PASS, 0 warnings.
- Architecture audit: PASS, 0 oversized files.
- Quality audit: PASS, 14,793 entries / 14,793 unique IDs / 14,793 unique German entries.
- Security audit: PASS.
- Weakness gate: PASS; review-only content queue, no mutation.

Flutter/Android runtime was not executed because Flutter SDK/emulator is unavailable in this environment.
