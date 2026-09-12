# V270 — Repository Reload / Write Queue Boundary

## Goal
Ensure an explicit persisted-state reload cannot observe storage before writes already queued by the same `LearnerRepository` have completed.

## Change
Added `Future<LearnerState> reloadPersisted()` which awaits the repository write queue, invalidates the cached snapshot, and then loads persisted state through the existing normalization boundary.

The existing synchronous `reload()` remains unchanged for callers that explicitly need an immediate cache bypass and do not have a pending repository write dependency.

## TDD
- RED: focused V270 test failed because `reloadPersisted()` did not exist.
- GREEN: minimal method added.
- Focused tests: 2 passed.
- Full regression: 267 passed.

## Verification
- Privacy audit: PASS
- Security audit: PASS
- Quality audit: PASS (14,813 content rows)
- Accessibility audit: PASS (0 warnings)
- Architecture audit: PASS
- Weakness gate: PASS
- Content compiler/parity: PASS (14,813 content / 11,718 verbs)
- Python compileall: PASS
- Bash syntax checks: PASS

Flutter/Android/APK/AAB builds remain unverified because the required Flutter/Android toolchain is not available in this environment.
