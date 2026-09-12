# V148 — Dictionary Rebuild Hardening

## Weaknesses found
- Dictionary cards loaded `LearnerRepository` state from inside each card build.
- Each card built a `WordProfile` repeatedly during rebuilds.
- `WordProfileService` scanned all verb conjugation rows for every profile.
- `WordProfileService` scanned the entire content corpus for related words/examples.
- `Mastery.forItem` scanned the full attempt history for each profile.

## Changes
- Search dictionary state is loaded once per page state.
- Profiles are cached by content ID for the page lifetime.
- Attempts are grouped once by item ID and passed to profile construction.
- Verb lookup uses the lazy `VerbIndex`.
- Related words/examples use lazy `SearchIndex` topic/skill groups.
- Mastery uses `Mastery.forItemRows` with pre-grouped attempts.

## Verification
- Focused V148 tests: 4 passed.
- V146/V147/V148 regression subset: 10 passed.
- Full suite: 234 passed, 0 failed.
- Accessibility audit: PASS, 0 warnings.
- Architecture audit: PASS, 0 oversized files.
- Quality audit: PASS, 14,793 entries; 14,793 unique IDs; 14,793 unique German entries.
- Security audit: PASS.
- Weakness gate: PASS; content review remains review-only.
- ZIP integrity: PASS.

Flutter/Android runtime was not executed because the Flutter SDK/emulator is unavailable in this environment.
