# Deutsch بالعربي — V250 Architecture Phase 0 + Content Boundary

## Scope

This stage applies the approved low-risk reusable architecture without turning the product into a multi-language runtime.

## Phase 0 findings

- The current product remains German-only.
- `ContentEngine` is already the main consumer-facing content boundary.
- `LegacyContentSource` remains intact and is still the default source unless `DEUTSCH_JSON_CONTENT=true` is supplied at build time.
- `JsonGeneratedContentSource` exists, but it currently exposes generated Dart content rather than loading raw JSON at runtime. A true asynchronous `JsonContentSource` is therefore deferred until the current data/build contracts justify it.
- Current learning/UI consumers use `ContentEngine.instance.items`; no direct consumer-side `a1` catalog dependency was found outside the content engine/data layer.
- There is no `AppDependencies` or `AppConfig` composition root yet. Creating them wholesale would be premature.
- TTS is currently isolated in `services/tts_service.dart`, but its implementation is deliberately German-specific (`de`/`de-DE`). There are no recorded audio asset files in the current source tree, so an `AudioResolver` abstraction is deferred rather than introduced as an empty layer.
- Existing `ContentItem` is already the shared content model. A duplicate `ContentData`/item hierarchy is not introduced.
- The current source tree has no Git repository; Git history/remote cannot be verified from this snapshot.

## Decision

Introduce only the first real reusable boundary that has immediate value: make `ContentEngine` explicitly constructible with a `ContentSource`, while preserving the existing singleton/default behavior and the generated-content factory.

This gives the future composition root a clean injection point without changing current callers or forcing a migration of the whole application.

## Implemented change

`ContentEngine` now supports:

```dart
const ContentEngine(this._source);
```

while retaining:

```dart
static const ContentEngine instance = ContentEngine._default();
```

and:

```dart
factory ContentEngine.generated() =>
    const ContentEngine(JsonGeneratedContentSource());
```

The build-time JSON switch remains unchanged in behavior and still defaults to the legacy source.

## Intentionally deferred

- Runtime multi-language switching.
- Language registry/manager.
- `AppDependencies` wholesale introduction.
- `AppConfig` propagation through all layers.
- True runtime JSON loading.
- `ContentRepository` creation without a demonstrated boundary need.
- `AudioResolver` without an existing recorded-audio asset boundary.
- Generic pronunciation rules.
- Moving all files into a theoretical directory tree.
- Removing `LegacyContentSource`.
- Renaming existing IDs.
- Adding future-language assets or audio.

## Verification

- Python regression suite: 235 passed.
- Content validation: PASS — 14,813 content rows; 11,718 verb rows.
- Content compiler + parity: PASS — 14,813 content rows; 11,718 verb rows.
- Security audit: PASS.
- Privacy audit: PASS.
- Quality audit: PASS — 14,813 entries / 14,813 unique IDs / 14,813 unique German entries.
- Accessibility audit: PASS — 0 warnings.
- Architecture audit: PASS.
- Weakness gate: PASS.
- Build-path compatibility: PASS.
- Python compileall: PASS.
- Bash syntax checks: PASS.
- Flutter/Android/APK/AAB execution: not performed; the required toolchain is unavailable in this environment.

## Next stage candidate

The next low-risk step should be selected from an actual boundary discovered in the code, not from the target directory diagram. The highest-value candidates are:

1. isolate the German TTS configuration only if it can be done without changing current behavior; or
2. strengthen content-source parity/contract tests before any true JSON runtime migration.

No language-switching implementation is planned at this stage.
