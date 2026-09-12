# V267 — UpdatedAt Persistence Safety

## Scope
Keep persisted `LearnerState.updatedAt` temporally coherent at the persistence boundary.

## Change
`LearnerRepository._normalizeForPersistence` now:
- promotes stale `updatedAt` values to the current time;
- clamps values more than one day in the future to the current time;
- persists the normalized timestamp.

## Safety
No content rows, IDs, dependencies, or user-facing learning semantics were removed or migrated.

## TDD
Focused test `tests/test_v267_updated_at_persistence_safety.py` was observed RED before implementation, then GREEN after the minimal repository change.

## Verification
- Focused V267 tests: 2 passed
- Full regression: 261 passed
- Content: 14,813
- Verbs: 11,718
- Privacy: PASS
- Security: PASS
- Quality: PASS
- Accessibility: PASS (0 warnings)
- Architecture: PASS
- Weakness Gate: PASS
- Python compileall: PASS
- Bash syntax: PASS
- Content compiler/parity verification: PASS
