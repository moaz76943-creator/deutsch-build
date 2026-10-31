# V381 — UI Dependency Boundary

## Scope

Removed direct UI dependencies on legacy German-specific compatibility facades and introduced an injectable privacy-settings contract.

## Changes

- Added `PrivacySettingsStore` and `LocalPrivacySettingsStore`.
- Kept `PrivacySettings` only as a compatibility facade for staged migration.
- Injected `PrivacySettingsStore` through `AppDependencies`.
- Updated V35 UI flows to consume the injected privacy boundary.
- Replaced UI `ContentQuality` facade usage with `LanguageContentQuality` supplied by the selected language pack.
- Removed legacy `TextNormalizer` facade imports from V35 UI.
- Added `tool/v381_ui_dependency_gate.py` and integrated it into `tool/architecture_audit.py`.
- Updated superseded regression assertions to the new architecture rather than restoring legacy dependencies.

## Verification

- Pytest: 668 passed, 0 failed.
- Python compileall: PASS.
- Language architecture gate: PASS (`findings=0`).
- UI dependency gate: PASS (`findings=0`).
- Architecture audit: PASS.
- Quality audit: PASS (14,813 entries; 14,813 unique IDs; 14,813 unique German entries).
- Security audit: PASS.
- Privacy audit: PASS.
- Accessibility audit: PASS (0 warnings).
- Weakness gate: PASS.
- Content ingestion validation: PASS.
- Compiler parity: PASS (14,813 content rows; 11,718 verb rows).
- Release verification: PASS (7/7 checks).
- Flutter/Android build: not executed because Flutter SDK is unavailable in the execution environment.

## Version

`3.3.7+130` / Android `versionCode 130`.
