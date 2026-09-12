# Service Dependency Injection Design

## Status

APPROVED FOR STAGED IMPLEMENTATION — architectural hardening within the existing app.

## Goal

Remove hidden global-singleton dependencies from domain-adjacent services without forcing a broad application-wide migration in one step.

## Scope

This stage targets `WordProfileService` only. It will stop reading `SearchIndex.instance` and `VerbIndex.instance` internally. Callers will provide those dependencies explicitly. Existing `SearchIndex.instance` and `VerbIndex.instance` remain available at composition/UI boundaries for compatibility and will be addressed in later stages.

## Chosen Approach

Use explicit parameters on the existing `WordProfileService.build` API:

```dart
WordProfileService.build(
  ContentItem item,
  LearnerState state, {
  required SearchIndex searchIndex,
  required VerbIndex verbIndex,
  List<ContentItem>? corpus,
  List<Attempt>? itemAttempts,
  DateTime? now,
})
```

The service remains stateless and does not become a global singleton. The two current UI call sites create the dependency values at the caller boundary and pass them into the service. No new package or runtime mechanism is added.

## Alternatives Considered

1. **Keep singleton access inside the service** — smallest change, but preserves hidden coupling and makes isolated testing difficult.
2. **Create a global dependency container** — reduces parameter count but introduces a new global coordination layer before it is needed.
3. **Explicit dependency parameters** — recommended for this stage: transparent dependencies, minimal API surface, easy testing, and incremental migration.

## Data Flow

```text
UI/composition boundary
   ├── SearchIndex.instance
   └── VerbIndex.instance
            ↓ explicit parameters
WordProfileService.build(...)
            ↓
WordProfile
```

The service must not resolve either dependency itself.

## Boundaries

- `WordProfileService` may depend on model types and service interfaces/types required for its calculation.
- `WordProfileService` must not access `SearchIndex.instance` or `VerbIndex.instance`.
- No learner persistence, authentication, subscription, network, or platform dependency is introduced.
- No behavior or scoring formula changes are intended.
- Existing singleton entry points remain temporarily valid at outer composition boundaries.

## Testing

A focused Python regression test must fail before the refactor if `WordProfileService` still contains singleton access, and must pass after the refactor while confirming both explicit dependency parameters exist and the current two UI callers provide them.

Full `pytest -q` plus security, privacy, quality, accessibility, architecture, and weakness gates must remain green.

## Future Direction

Subsequent architectural stages may move the same explicit-dependency boundary outward to `SearchIndex`, `VerbIndex`, and content composition. This stage deliberately does not remove those singletons globally.
