# V297 — Learning Core Repository Ownership Boundary

## Status
VERIFIED

## Decision
`lib/core/learning_core.dart` must remain independent of the repository/storage layer. It consumes `LearnerState` as input and returns learning-domain results; persistence ownership remains in `LearnerRepository`.

## Scope
- Remove the stale repository import from `LearningCore`.
- Add a regression guard preventing a repository dependency from returning.
- Do not change learning behavior, state ownership, persistence, authentication, subscription, or content schemas.
