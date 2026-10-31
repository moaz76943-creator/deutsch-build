# V179 — Compatibility & Legacy Hardening

## Scope

This stage improves maintainability without changing the learning content or removing product features.

## Changes

- Moved the `flutter_tts` plugin boundary from `lib/ui_v35/safe_ui.dart` into `lib/services/tts_service.dart`.
- Preserved `SafeTtsController` behavior: serialized speech, generation invalidation, stop/shutdown lifecycle handling, and failure containment.
- Kept `lib/ui_v35/safe_ui.dart` as a compatibility shim so existing UI imports do not require a broad rewrite in one step.
- Kept the existing `speech_to_text` and `shared_preferences` adapter boundaries in `lib/services/`.
- Fixed the `learning_pages.dart` dispose path to call the controller's own `stop()` API instead of passing a controller to a plugin-typed helper.
- Audited the versioned UI directories and documented why `lib/ui_v35` is current runtime code while `lib/ui/app.dart` remains retained for historical regression coverage.
- Added regression coverage for platform-plugin boundaries and legacy UI safety.

## Verification evidence

- Python regression suite: 161 passed.
- Content quality audit: PASS; 14,793 entries, 14,793 unique IDs, 14,793 unique German entries.
- Security audit: PASS.
- Python compile checks: PASS.
- Maintained shell syntax checks: PASS.
- Flutter/Dart binaries are not installed in the current execution environment, so `flutter analyze`, `flutter test`, and an Android APK build were not claimed.
