# V376 — Language Boundary Core Services Phase 3

## Outcome

This phase completed the remaining shared-service language-boundary findings identified after V375 Phase 2. The protected architecture gate now reports zero findings.

## Changes

- `ContentEngine<T extends LearningContent>` and `ContentSource<T extends LearningContent>` are language-neutral.
- German legacy/generated source selection now lives in `GermanContentPack`.
- `AppDependencies<T extends LearningContent>` carries neutral corpus/search dependencies.
- Learning planning, vocabulary coaching, mastery dashboard, repository recording, and word-profile construction consume the neutral content contract.
- `WordProfile<T extends LearningContent>` no longer depends on German-shaped fields.
- Search-index internal entries use neutral `source`, `translation`, and `grammaticalMarker` terminology.
- Historical tests were updated where they asserted superseded singleton/German-specific implementation locations; behavioral coverage remains in the suite.
- The two documented compatibility facades (`quality.dart`, `text_normalizer.dart`) remain isolated shims and are not counted as shared-service architecture findings.

## Verification

- Architecture gate: `findings=0`
- Full pytest: `641 passed`
- Python compileall: PASS
- Release verification: all seven checks PASS; no failures
- Flutter/APK build: unavailable because Flutter SDK is not installed in this environment.

## Version

`3.3.2+125` / Android `versionCode 125`, `versionName 3.3.2`.
