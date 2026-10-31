# V132 — Weakness Hardening

## Focus
This release prioritizes previously identified weak points instead of adding breadth.

- Legacy UI lifecycle safety after async persistence.
- Safer refresh operations after widget disposal.
- Null-safe mastery skill selection.
- Null-safe assessment skill sorting.
- Preservation of existing TTS/STT crash isolation.
- Regression coverage for these paths.

## Verification boundary
Static and Python verification can prove source contracts and data integrity, but Android runtime behavior still requires a Flutter SDK and device/emulator.
