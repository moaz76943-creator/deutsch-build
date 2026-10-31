# V382 — Persistence Composition Boundary

## Scope

This stage strengthens the persistence dependency boundary without changing learner-state semantics.

## Changes

- `LearnerRepository` now receives its `LearnerPersistence` dependency from the composition boundary instead of constructing it internally.
- `main.dart` composes `PreferencesService`, `LearnerPersistence`, and `LearnerRepository` explicitly.
- The legacy `VerbPage` storage future remains behaviorally equivalent while using the explicit persistence dependency.
- JSON serialization/deserialization remains confined to `LearnerPersistence`.
- No SRS, mastery, entitlement, authentication, or learner-state scoring rules were changed.

## Verification

- V382 persistence composition tests: PASS
- Full pytest: PASS
- Python compileall: PASS
- Language architecture gate: PASS
- Architecture audit: PASS
- Security audit: PASS
- Privacy audit: PASS
- Accessibility audit: PASS
- Release verification: PASS
- Flutter/Android build: NOT RUN — Flutter SDK is unavailable in the execution environment.
