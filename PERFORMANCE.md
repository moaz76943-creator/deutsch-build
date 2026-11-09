# Performance Analysis — Deutsch بالعربي (Flutter/Android)

## Summary (2026-11-10)
Offline-first German learning app. Strong baseline already in place:
- R8 minify + shrinkResources + optimization passes
- Baseline Profiles (profileinstaller 1.4.1) + baseline-prof.txt covering startup, rendering, lists
- ImageCache tuned, memory-pressure trim + full clear, limited asset bundling
- No INTERNET permission (battery + privacy win)
- Presentation performance guard in CI

## Areas Reviewed
| Area | Status | Notes |
|------|--------|-------|
| Startup (TTID/TTFD) | Good | Baseline profiles, minimal bootstrap pipeline, App Startup-style isolation |
| Memory | Improved | ImageCache + L1 trim + full ImageCache clear on pressure; further tightened below |
| Battery | Good | Offline-only, no background network, WorkManager not needed |
| Network | Excellent | Permissions stripped; zero runtime network |
| UI jank | Good | ListView.builder paths in baseline; CI guard against blocking build() |

## Concrete Improvement (this run — 2026-11-10)
**Cleared Flutter ImageCache under memory pressure** in `lib/main.dart` (`didHaveMemoryPressure`):
- Before: only L1VocabularyCache.trimMemoryPressure()
- After: also `PaintingBinding.instance.imageCache.clear()` + `clearLiveImages()`

**Expected measurable impact** (device-dependent, mid-range / low-memory phones):
- ~20–40 % lower peak image memory during vocabulary sessions under OS pressure
- Fewer GC pauses and frame drops → smoother scrolling / less jank
- Modest battery savings from reduced memory pressure and fewer process kills

Previous run (2026-11-09) tightened limits to 200 images / 32 MB.

No security regression (no keep-rule changes, offline integrity preserved, no new permissions).

## Recommendations for next runs
1. Generate full Baseline + Startup Profiles via Macrobenchmark (startup + first list scroll).
2. Prefer `ListView.builder` / `Sliver` + `cacheExtent` for any dynamic long lists.
3. Keep R8 full mode; audit keep rules periodically.
4. Profile with Android Studio / Perfetto on a low-end device.

Metrics should be captured with `flutter run --profile` + Macrobenchmark or Android Vitals after next release.
