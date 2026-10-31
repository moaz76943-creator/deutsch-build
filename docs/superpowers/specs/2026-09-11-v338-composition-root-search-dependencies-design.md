# V338 Composition Root Search Dependencies — Design

## Goal

Move creation of search-related runtime dependencies to the application composition root and inject them into the V35 UI, while preserving search behavior and keeping the legacy facade only for compatibility.

## Architecture

`main.dart` is the composition root for the V35 runtime and constructs `SearchIndex` from the canonical content corpus plus `VerbIndex.instance`. Those explicit dependencies are grouped in `AppDependencies` and passed into `DeutschAppV35`, then into the small set of V35 pages that need search/profile lookup.

`SearchIndex` remains dependency-explicit. `LegacySearchIndex` remains available only as a temporary compatibility facade for callers outside the migrated surface; V35 must not import or call it. No search algorithm, content schema, learner data, authentication, or subscription behavior changes.

## Boundaries

- `SearchIndex`: pure-ish search engine over explicitly supplied content and `VerbIndex`.
- `AppDependencies`: composition container for explicitly shared V35 services; no learner/auth/subscription state.
- `main.dart`: constructs runtime dependencies; no business behavior is added.
- V35 UI: consumes injected dependencies; it does not resolve service singletons.
- `LegacySearchIndex`: compatibility-only bridge for not-yet-migrated callers.

## Data Flow

```text
ContentEngine.instance.items + VerbIndex.instance
                    |
                    v
             main.dart (composition root)
                    |
                    v
             AppDependencies
               /         \
              v           v
       SearchIndex     VerbIndex
              |
              v
        V35 UI/pages
```

## Constraints

- No change to search scoring, limits, sorting, tokenization, morphology, or fuzzy behavior.
- No content data changes.
- No new package dependency.
- No removal of `LegacySearchIndex` in this stage.
- No secrets, credentials, or learner state in `AppDependencies`.
- Migration remains incremental; only current V35 search consumers are migrated.

## Verification

- Focused architecture tests must fail before the refactor and pass after it.
- Full Python regression suite must pass.
- Security, privacy, quality, accessibility, architecture, and weakness gates must pass.
- Flutter/Dart verification is performed only if the toolchain is available.
