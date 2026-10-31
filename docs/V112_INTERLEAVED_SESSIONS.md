# V112 — Interleaved Adaptive Sessions

Version: 1.60.0+70

- Added a guarded interleaving pass to the adaptive learning plan.
- The planner now prefers a fresh practice mode and topic before relaxing either constraint.
- Existing priority ordering remains the tie-breaker, so due reviews and serious mistakes keep their priority.
- No existing content IDs were changed.

Verification:
- `pytest -q test/tool`: PASS (30 tests)
- Quality Audit: PASS
- Security Audit: PASS
- Flutter build: not run because the current environment has no Flutter SDK.
