# V135 — Weakness Hardening

V135 focuses on weak-point reduction rather than feature expansion.

## Changes

- Added an accessibility audit for explicit semantics, tooltips, and input labels.
- Added an architecture audit that exposes oversized Dart files without blocking the build.
- Added a review-only near-duplicate content queue. It never deletes or mutates source content.
- Added a weakness gate that prioritizes critical accessibility failures and reports architecture/content risk.
- Added semantic labels to the primary home statistics.
- Bumped the app to 1.80.0+90 / Android versionCode 90.

## Remaining evidence gap

Android runtime behavior is not claimed as proven in this environment because the Flutter SDK/emulator is unavailable here. Static verification cannot replace real-device lifecycle, accessibility, performance, TTS/STT, and process-recreation testing.
