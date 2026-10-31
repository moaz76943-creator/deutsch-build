# V147 — Progress Hotpaths Hardening

## Weakness assessment
1. Reading practice word lookup scanned the entire A1 catalog for every tapped word.
2. The "next step" card materialized every item for the selected skill, sorted them, and built a full WordProfile for each candidate.
3. These paths were UI rebuild hotpaths, so their cost could repeat frequently.

## Fixes
- Reading word lookup now uses the cached `SearchIndex` instead of a full catalog scan.
- Added `LearningCore.weakestItemForSkill()` to bucket attempts once and evaluate candidate mastery with `Mastery.forItemRows`.
- The next-step card now selects one weakest item without sorting the entire skill catalog or building profiles for every candidate.
- The displayed final item's `WordProfile` is still built only for the selected item, preserving the existing UI information.

## Verification
- Focused V147 tests: 3 passed.
- Full Python regression suite: 230 passed, 0 failed.
- `python -m compileall -q tests tool`: passed.
- Accessibility audit: PASS, 0 warnings.
- Architecture audit: PASS, 0 oversized files.
- Quality audit: PASS, 14,793 entries / 14,793 unique IDs / 14,793 unique German entries.
- Security audit: PASS.
- Weakness gate: PASS; review-only queue, 1,180 candidates, no mutation.
- ZIP integrity: PASS.

Flutter/Android runtime was not executed because Flutter SDK/emulator is unavailable in this environment.
