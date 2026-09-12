# V371 — Core Boundary Closure

## Purpose

Move the German-specific content-quality and answer-normalization implementations out of `lib/core`, while preserving legacy service call sites during the staged migration.

## Changes

- Removed `lib/core/text_normalizer.dart`.
- Removed `lib/core/content_quality.dart`.
- Kept `lib/services/text_normalizer.dart` as a temporary compatibility facade delegating to `GermanTextNormalizer`.
- Kept `lib/services/quality.dart` as a temporary compatibility facade delegating to `GermanContentQuality`.
- Preserved the validation cache and collection-validation API used by existing callers.
- Updated the remaining direct UI import from the removed core quality implementation to the service compatibility facade.
- Updated release contracts to the V371 build identity.

## Boundary decision

The Core layer no longer implements German-specific normalization or German content-quality policy. The service facades are explicitly temporary compatibility surfaces; subsequent stages will replace their static calls with injected language contracts and remove the facades.

## Verification

- Focused V371 tests: 14 passed.
- Full pytest: 598 passed.
- Content validation: 14,813 items / 11,718 verb rows / 0 audio entries — PASS.
- Audio validation: PASS.
- Compiler + parity: PASS.
- Security audit: PASS.
- Privacy audit: PASS.
- Accessibility audit: PASS — 0 warnings.
- Architecture audit: PASS.
- Quality audit: PASS.
- Weakness Gate: PASS; mutation NONE.
- Python compileall: PASS.
- Flutter/Dart build not claimed because Flutter SDK is unavailable in the execution environment.

## Remaining architecture work

The final language-ready gate is still intentionally not closed. Shared services still contain direct content projections and compatibility normalization/quality calls. V372 should migrate those service dependencies to `LanguageTextNormalizer` and `LanguageContentQuality` through explicit dependency injection, then re-run the architecture gate.
