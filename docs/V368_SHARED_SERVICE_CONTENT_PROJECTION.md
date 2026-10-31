# V368 — Shared-Service Content Projection

V368 moves the shared content-analysis and mistake/decision services onto the language-neutral `LearningContent` contract.

## Scope

- `ContentIntelligence` accepts `LearningContent` instead of `ContentItem`.
- `MistakeEngine` accepts `LearningContent` instead of `ContentItem`.
- `LearningIntelligence` accepts `LearningContent` at its service boundary.
- Stable IDs and learner-state semantics remain unchanged.
- No canonical content data is modified.

The German corpus remains the current source through `GermanLanguagePack`; this stage changes the service-facing projection, not the selected language.

## Compatibility

The existing `ContentItem` continues to implement `LearningContent`, so the migration does not require a data rewrite. Legacy consumers remain outside this stage and will be migrated in later focused stages.

## Verification

The stage includes architecture tests that reject direct `ContentItem` dependencies in the migrated services and verify use of the neutral contract.

Flutter/Dart build status must be reported separately when the Flutter toolchain is unavailable.
