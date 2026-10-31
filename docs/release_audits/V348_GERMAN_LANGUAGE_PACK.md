# V348 — German Language Pack at Composition Root

## Baseline

- Starting snapshot: V347b
- Scope: language configuration façade at the Composition Root only

## Changes

- Added `LanguagePack` as a language-neutral configuration contract.
- Added `GermanLanguagePack` as the canonical German implementation.
- Added the selected `LanguagePack` to `AppDependencies`.
- `main.dart` selects exactly one `GermanLanguagePack` at the Composition Root.
- No content files, learning algorithms, learner state, authentication, subscription, secure storage, or backend credentials were moved into the language pack.
- No dynamic multi-language runtime was introduced.
- Build identity advanced from `1.88.0+98` / Android `98` to `1.89.0+99` / Android `99`.

## Verification

```text
Focused V347b/V348 tests: 11 passed
Full pytest regression: 497 passed
Flutter/Dart analyze: not run (toolchain unavailable)
APK build: not run (toolchain unavailable)
```
