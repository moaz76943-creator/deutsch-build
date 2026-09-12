# V262 — Review / ReviewCard Persistence Coherence

## Goal
Ensure the duplicated review representation (`review` IDs and `reviewCards`) cannot drift when a `LearnerState` is persisted through `LearnerRepository`.

## Change
Persistence normalization now:
- normalizes the existing `reviewCards` map first;
- bounds the `review` set;
- creates a `ReviewCard` for any review-only ID so legacy/review-only state remains usable by SRS consumers;
- unions normalized card IDs back into `review` so every persisted card is represented in the review set;
- keeps existing collection and payload limits unchanged.

## TDD evidence
Focused V262 test was first run and failed on the missing reconciliation contract. The minimal repository normalization was then added and the focused V262 tests passed.

## Verification
- Full regression: 255 passed
- Content compiler: 14,813 content rows / 11,718 verb rows; parity PASS
- Privacy audit: PASS
- Security audit: PASS
- Quality audit: PASS
- Accessibility audit: PASS (0 warnings)
- Architecture audit: PASS
- Weakness gate: PASS
- Build path compatibility: PASS
- CI secret hygiene: PASS
- Python compileall: PASS
- Bash syntax: PASS

Flutter/Android/APK/AAB build and runtime remain unverified because the required Flutter and Android toolchain is not available in the current execution environment.

No educational content was deleted or replaced, no dependency was upgraded, and no destructive repository reset was performed.
