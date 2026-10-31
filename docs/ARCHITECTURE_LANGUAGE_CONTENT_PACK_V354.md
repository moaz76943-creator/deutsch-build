# Language Content Pack Boundary — V354

## Purpose

V354 introduces the runtime boundary that makes the learning catalogue owned by the selected learning language. The current German build remains behaviorally unchanged, while the Composition Root no longer binds directly to German content/index singletons.

## Contract

`LanguageContentPack` provides:

- the immutable runtime `ContentItem` catalogue;
- the language-owned `VerbIndex`.

`LanguagePack` exposes the selected `LanguageContentPack` alongside the existing exercise strategy and presentation contracts.

## Current German adapter

`GermanContentPack` is the only adapter that binds the existing German runtime sources:

- `ContentEngine.instance` for the canonical German vocabulary catalogue;
- `VerbIndex.instance` for the current German verb index.

This is an intentional compatibility bridge. The underlying German datasets are not rewritten or moved in V354.

## Composition Root

`lib/main.dart` now follows:

```text
GermanLanguagePack
        ↓
LanguageContentPack
        ↓
corpus + verbIndex
        ↓
SearchIndex + AppDependencies
```

A future language pack can provide another content adapter without changing the dependency construction shape.

## Scope limits

V354 does not make JSON the runtime source, does not introduce dynamic language switching, and does not change learner state, SRS, Mastery, IDs, subscription authority, authentication, or security boundaries.

The next content stages can build on this seam to make editable vocabulary/verb ingestion and audio asset manifests language-owned and batch-friendly.
