# V383 — Persistence Failure Boundary

## Goal
Replace generic persistence write errors with a stable, typed failure contract while preserving existing persistence behavior and safety limits.

## Changes
- Added `LearnerPersistenceFailureCode`.
- Added `LearnerPersistenceFailure`.
- Oversized serialized state now reports `payloadTooLarge`.
- Failed preference writes now report `writeFailed`.
- Existing bounded load/normalization behavior remains unchanged.
- Repository queue semantics remain unchanged; failures still propagate through the returned operation future.

## Verification
- Pytest: 675 passed, 0 failed.
- Architecture gate: PASS (`findings=0`).
- Security: PASS.
- Privacy: PASS.
- Accessibility: PASS.
- Content quality: PASS.
- Compiler parity: PASS.
- Release verification: 7/7 PASS.
- Flutter/Android build: not executed because Flutter SDK is unavailable in the execution environment.
