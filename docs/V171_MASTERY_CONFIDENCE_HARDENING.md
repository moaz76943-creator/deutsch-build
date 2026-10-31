# V171 — Mastery confidence and adaptive-focus hardening

## Changes

- Mastery skill scores now use a small neutral prior so one or two attempts cannot make a learner appear fully mastered.
- `MasteryEvidence` exposes an evidence-confidence heuristic and mastery requires sufficient evidence in addition to score, retention, and retrievability.
- Adaptive focus precomputes the latest timestamp per learning dimension instead of rescanning the item rows once per dimension.
- No scoring field is presented as a calibrated probability; the confidence value is explicitly heuristic.

## Verification

- V171 focused tests: PASS
- Full Python regression suite: PASS
- Python compileall: PASS
- Flutter/Android runtime build: not executed in this environment because Flutter/Android SDK is unavailable.
