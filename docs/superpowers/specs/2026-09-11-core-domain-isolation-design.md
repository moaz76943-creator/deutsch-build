# Core Domain Isolation Design

## Status

APPROVED FOR STAGED IMPLEMENTATION — architectural hardening within the existing app.

## Goal

Make `lib/core/` a true domain layer that does not import implementation services, while preserving existing public service import paths through compatibility facades.

## Current Finding

`lib/core/learning_core.dart` still imports `TextNormalizer`, `ContentQuality`, `MemoryQueue`, and `Mastery` from `lib/services/`. This makes the core depend upward on service implementations and weakens the intended dependency direction.

## Chosen Approach

Move the domain primitives required by `LearningCore` into `lib/core/`:

- `core/text_normalizer.dart`
- `core/content_quality.dart`
- `core/srs.dart`
- `core/memory.dart`
- `core/mastery.dart`

The existing service files remain as compatibility facades that export the canonical core implementations. This avoids a broad call-site migration while establishing a one-way dependency rule: core may depend on models, but not services, UI, data, or platform code.

## Alternatives Considered

1. **Leave the current imports** — lowest risk immediately, but preserves the architectural violation.
2. **Inject every primitive through function/object ports** — strongest theoretical isolation but adds unnecessary indirection and API surface for deterministic domain logic.
3. **Canonicalize deterministic domain primitives in `core/` with service facades** — recommended: preserves existing consumers while making the dependency direction explicit.

## Boundaries

- Core primitives contain deterministic learning/domain logic only.
- Models remain passive data contracts.
- Services may depend on core; core must not depend on services.
- Generated/content data remains outside core.
- UI and platform integrations remain outside core.
- No behavior changes are intended in this phase.

## Compatibility

Existing imports such as `services/srs.dart`, `services/memory.dart`, `services/mastery.dart`, `services/quality.dart`, and `services/text_normalizer.dart` remain valid through exports. No public service symbol is intentionally renamed.

## Verification

A regression test will inspect all Dart imports under `lib/core/` and fail if they reference `../services/`, `../ui`, `../data`, or platform packages. Existing regression tests and architecture/security/privacy gates must remain green.
