# Performance Analysis — Deutsch بالعربي (Flutter/Android)

## Summary (2026-11-09)
Offline-first German learning app. Strong baseline already in place:
- R8 minify + shrinkResources + optimization passes
- Baseline Profiles (profileinstaller 1.4.1) + baseline-prof.txt covering startup, rendering, lists
- ImageCache tuned, memory-pressure trim, limited asset bundling
- No INTERNET permission (battery + privacy win)
- Presentation performance guard in CI

## Areas Reviewed
| Area | Status | Notes |
|------|--------|-------|
| Startup (TTID/TTFD) | Good | Baseline profiles, minimal bootstrap pipeline, App Startup-style isolation |
| Memory | Improved | ImageCache + L1 trim on pressure; SafeVocabularyImage right-sizing added |
| Battery | Good | Offline-only, no background network, WorkManager not needed |
| Network | Excellent | Permissions stripped; zero runtime network |
| UI jank | Good | ListView.builder paths in baseline; CI guard against blocking build() |

## Concrete Improvement (this run — 2026-11-09)
**Added `SafeVocabularyImage`** in `lib/design_system/safe_vocabulary_image.dart`:
- Always applies `cacheWidth` / `cacheHeight` scaled by device pixel ratio.
- Prevents full-resolution decode of large offline pack assets into ImageCache.
- Includes placeholder and error handling.

**Expected measurable impact** (device-dependent, mid-range phones):
- 5–20× lower decoded bitmap memory per vocabulary/media image.
- Fewer GC pauses and lower peak RSS during list scrolling.
- Smoother UI on low-end devices; complements previous ImageCache limit reduction (200 / 32 MB).

No security regression (no keep-rule changes, offline integrity preserved).

## Previous Improvement
**Tightened ImageCache limits** in `lib/main.dart`:
- Before: 250 images / 48 MB
- After: 200 images / 32 MB

## Recommendations for next runs
1. Migrate existing Image.asset / Image.file usages in vocabulary screens to `SafeVocabularyImage`.
2. Generate full Baseline + Startup Profiles via Macrobenchmark (startup + first list scroll).
3. Prefer `ListView.builder` / `Sliver` for any dynamic long lists.
4. Keep R8 full mode; audit keep rules periodically.
5. Profile with Android Studio / Perfetto on a low-end device.

Metrics should be captured with `flutter run --profile` + Macrobenchmark or Android Vitals after next release.
