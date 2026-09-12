# V151 — Weakest Item Semantics Hardening

## Problem
`LearningCore.weakestItemForSkill` previously converted an item with no attempts into an effective mastery score of zero. That made unmeasured/new content appear weaker than genuinely measured weak content and could distort the learner's next-step recommendation.

## Fix
- Separate measured items from unmeasured items.
- Score only items with actual attempts.
- Keep the first eligible unmeasured item as an explicit fallback.
- Return the weakest measured item when any measured items exist; otherwise return the unmeasured fallback.
- Add the direct `Mastery` import so the Dart dependency is explicit.

## Verification
- V151 focused tests: 3 passed.
- Full Python regression suite: 240 passed.
- `python -m compileall -q tests tool`: PASS.
- Flutter/Dart compile and Android runtime remain unverified because the Flutter SDK/emulator are unavailable in this environment.
