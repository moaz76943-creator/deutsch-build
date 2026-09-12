# SearchIndex Dependency Isolation Design

## Goal
Make `SearchIndex` a pure search engine whose corpus and verb lookup dependency are supplied explicitly, while retaining a temporary compatibility facade for current callers.

## Architecture
`SearchIndex` owns only search state and algorithms. It receives an immutable corpus and a `VerbIndex` instance through its constructor and contains no `ContentEngine.instance` or `VerbIndex.instance` lookup.

`LegacySearchIndex` is the composition compatibility boundary. It may access `ContentEngine.instance` and `VerbIndex.instance` and expose the old application-level singleton behavior until callers are migrated. No core search logic belongs in that facade.

## Constraints
- No search behavior changes.
- No content schema changes.
- No subscription/auth changes.
- No new package dependencies.
- Keep the migration incremental; do not rewrite all UI construction in one step.
- The legacy facade is compatibility-only and must not be imported by `SearchIndex`.

## Validation
- Static architecture test proves `SearchIndex` has no singleton lookups/imports.
- Constructor test proves explicit corpus and verb dependency are required.
- Legacy compatibility test proves the facade still resolves the existing runtime sources.
- Full Python regression suite must remain green.
