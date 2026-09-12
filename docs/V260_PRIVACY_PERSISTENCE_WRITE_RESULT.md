# V260 — Privacy Persistence Write Result Boundary

## Goal

Ensure privacy-setting UI does not report a changed preference when the local persistence operation fails.

## Change

`PrivacySettings.setCloudAi` and `setSpeech` now return the underlying persistence result and fail closed with `false` on exceptions. The settings UI updates its in-memory switch only after a successful write.

## TDD evidence

- RED: `pytest -q tests/test_v260_privacy_persistence_result_boundary.py` failed because the setters returned `Future<void>` and the UI ignored persistence results.
- GREEN: the identical focused test passed after the minimal implementation.

## Safety

- No content rows changed.
- No persistence keys changed.
- No dependencies changed.
- No destructive migration introduced.

## Verification

- Full regression: 252 passed.
- Privacy audit: PASS.
- Security audit: PASS.
- Quality audit: PASS — 14,813 entries.
- Accessibility audit: PASS — 0 warnings.
- Architecture audit: PASS.
- Weakness gate: PASS.
- Build-path compatibility: PASS.
- Python compileall: PASS.
- `scripts/build.sh` bash syntax: PASS.
- `tool/bootstrap_flutter_android.sh` bash syntax: PASS.

Flutter/Android/APK/AAB runtime/build verification remains unavailable because the required toolchain is not installed in this environment.
