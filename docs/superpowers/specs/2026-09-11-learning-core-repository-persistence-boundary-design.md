# Learning Core ↔ Repository Persistence Boundary — Design

## Status

APPROVED/IMPLEMENTED under the project's standing engineering authorization.

## Problem

`LearnerRepository` combined canonical learner-state lifecycle with JSON serialization, storage I/O, migration, cleanup, and normalization. This made the repository a storage adapter as well as the canonical owner of learner state.

## Decision

Introduce `LearnerPersistence` as the physical persistence boundary.

- `LearnerRepository` remains the canonical owner/orchestrator of `LearnerState` and its in-memory cache.
- `LearnerPersistence` owns JSON encoding/decoding, persisted-state normalization, storage reads/writes, legacy favorite migration, and local-data cleanup.
- Persistence keys remain declared by `LearnerRepository` and are passed explicitly to `LearnerPersistence`; this preserves the existing key-ownership/privacy contract.
- UI, Authentication, Subscription, Content, and Learning Engine boundaries are unchanged.

## Security and privacy invariants

- No new credentials, tokens, payment data, or authentication state enter learner persistence.
- `SharedPreferences` remains behind the existing `PreferencesService` adapter.
- Persisted input continues to be bounded and partially recoverable.
- Canonical learner state is still represented only through `LearnerRepository`.
- Cache is updated only after successful persistence and is invalidated after cleanup attempts.

## Non-goals

- No schema change to learner state.
- No new dependency.
- No backend/authentication integration.
- No UI behavior change.
- No deletion of historical release archives.

## Verification target

Python regression suite, privacy/security/quality/accessibility/architecture audits, and weakness gate must remain green. Flutter/Android build verification remains subject to the environment having the required Flutter/Gradle toolchain.
