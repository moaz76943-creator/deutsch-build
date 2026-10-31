# Deutsch بالعربي — Architecture Baseline V345

## Status

**Architecture state: VERIFIED / FROZEN** for the current canonical application architecture.

This freeze describes dependency direction and ownership. It does not freeze implementation details or prevent future refactors that preserve these boundaries.

## Canonical Layers

```text
Composition Root
      ↓
UI / Application Composition
      ↓
Services
      ↓
Core + Models
      ↑
Content / Learner State boundaries
```

### Composition Root

`lib/main.dart` is the production composition root for app-wide dependencies.

It owns creation/wiring of:
- `LearnerRepository` and local persistence initialization.
- canonical content corpus materialization from `ContentEngine.instance`.
- canonical `SearchIndex` creation from the composed corpus and `VerbIndex.instance`.
- `AppDependencies` construction.
- authentication/backend transport composition.

### Core

`lib/core/` contains language/domain-independent learning logic. It must not import UI or service implementations and must not resolve global singletons.

### Content

Static learning content and content engines remain separate from learner state. Canonical UI receives corpus explicitly.

### Learner State

Learner state and persistence remain separate from content, authentication, and subscription authority. Repository ownership stays explicit.

### Authentication

Authentication identity/session state is separate from learner data. Backend authority remains outside UI decisions.

### Subscription

Premium entitlement is not represented as a local APK boolean and is not owned by learner state.

### Transport

Backend HTTP transport is separate from authentication protocol and environment configuration. Production host configuration is not hardcoded into business logic.

### UI

Modern V35 UI receives app-wide dependencies explicitly. It must not resolve `ContentEngine.instance`, `VerbIndex.instance`, or `SearchIndex.instance`, and must not instantiate app-wide search/content services.

## Allowed Global Access

Only these forms remain intentionally global:

1. `ContentEngine.instance` and `VerbIndex.instance` in `lib/main.dart` as composition-source objects.
2. The same two references in `lib/services/search_index_legacy.dart` as a documented compatibility facade.
3. `PreferencesService.instance()` at the composition/storage compatibility boundary while the storage service remains a single shared adapter.
4. `PreferencesService.instance()` in `lib/ui/app.dart` because that file is legacy UI and retains its own repository boot path pending a separate storage-injection migration.

These are compatibility/composition exceptions, not patterns for new code.

## Forbidden Dependencies

- `lib/core/` → `.instance` lookups.
- `lib/ui_v35/` → `.instance` lookups.
- canonical services → `ContentEngine.instance` fallback.
- V35 → `LegacySearchIndex`.
- UI → construction of app-wide `SearchIndex`, `VerbIndex`, or `ContentEngine`.
- app layers → credentials, auth tokens, or payment secrets embedded in static content/configuration.

## Compatibility Policy

Legacy facades may remain while migration is incremental. New code must use explicit dependencies. Removing a facade requires all production callers and tests to use the canonical contract first.

## Review Rule

Any change that introduces a new singleton, global mutable state, hidden service locator, or new cross-layer import must add or update an architecture contract test before implementation.

## Next Candidate

`PrivacySettings` can be migrated from `PreferencesService.instance()` to an injected persistence adapter as a separate, bounded architecture stage. This is intentionally outside the V345 freeze because it is a storage-boundary migration, not a content/index boundary migration.
