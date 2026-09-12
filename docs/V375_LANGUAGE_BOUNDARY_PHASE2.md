# V375 — Language Boundary Normalization Phase 2

## Scope
This phase removes the remaining legacy text-normalization dependency from four shared consumers without moving German rules into shared services.

## Changes
- `VerbIndex` now receives `LanguageTextNormalizer` explicitly.
- German construction remains in `GermanContentPack`.
- `ConversationEngine` now receives the selected language normalizer.
- `ProductionEngine.matches` now receives the selected language normalizer.
- `WritingAnalyzer.analyze` now receives the selected language normalizer.
- The writing and conversation UI passes the selected language contract from the composition root.
- The historical singleton source assertions were updated to reflect the superseding dependency-injection architecture rather than preserving the old German-bound global construction.

## Architecture Gate
- V375 baseline: 43 findings.
- V375 result: 35 findings.
- Reduction: 8 findings.
- No normalization finding remains for `VerbIndex`, `ConversationEngine`, `ProductionEngine`, or `WritingAnalyzer`.

## Verification
- Focused V375 + affected historical contracts: 23 passed.
- Full pytest: 632 passed.
- Flutter build: not executed because Flutter SDK is unavailable in the environment.

## Deferred
The remaining 35 findings are not suppressed. They belong to the next architecture phases: content-engine/content-contract boundaries, quality compatibility, repository/search projections, and remaining German-shaped learning services.
