# V380 — Persistence Boundary Hardening

## Scope

Harden the learner persistence boundary without changing learner behavior, SRS semantics, entitlement rules, or storage keys.

## Root cause found

During a source-level review of `lib/services/learner_persistence.dart`, the review-card validation guard referenced `id.length` even though the local variable is named `key`. This is a latent Dart compile-time defect in a path not exercised by the Python-only test environment.

The correct guard is based on the already-normalized map key:

```dart
if (key.isEmpty || key.length > 160 || entry.value is! Map) continue;
```

## Boundary guarantees

- `LearnerRepository` owns learner-domain orchestration and delegates JSON serialization to `LearnerPersistence`.
- `LearnerPersistence` remains the physical JSON representation and migration boundary.
- `PreferencesService` remains the storage adapter boundary.
- No learner-state JSON encoding/decoding was introduced into the repository.
- Existing limits, storage keys, migration behavior, and SRS state shape are unchanged.

## Verification

- V380 regression tests: PASS
- Full pytest: required after the targeted RED → GREEN cycle
- Flutter/Dart build: not claimable in this environment because Flutter SDK is unavailable.
