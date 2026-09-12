# V83 — Learning Quality & UX Update

- Added 24 unique practical German entries (15133–15156).
- Corrected the recurring Arabic first-person pattern `أنا ي...` across legacy examples.
- Added `TextNormalizer` for tolerant answer checking and search normalization.
- Improved SRS safety bounds and focused fresh learning on the weakest measured skill.
- Added a daily-focus card showing goal, progress, accuracy, and review queue.
- Improved TTS behavior: stop previous utterance and use a slower German speech rate.
- Improved category ordering by content volume.
- Expanded quality checks for duplicate German entries and known Arabic conjugation defects.
- Added V83 regression tests for content uniqueness, normalization, SRS, and language defects.
- Applied Material 3/accessibility-oriented UI practices based on current Flutter documentation.

## Verification note

Flutter/Dart SDK is not installed in the current build environment, so `flutter test` and `flutter build apk` could not be executed here. Source-level, content-level, and archive integrity checks are performed separately; Android CI remains the authoritative build check.

## Tooling used

- Flutter official documentation was consulted for Material 3, accessibility targets, semantic labels, and performance guidance.
- The available app-building connector was probed; no matching project was exposed in the current workspace, so changes were applied directly to the supplied Flutter source archive.
