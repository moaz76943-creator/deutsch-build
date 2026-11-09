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
**Optimized HomeScreen dashboard ListView** in `lib/screens/home_screen.dart`:
- Before: default ListView.builder (cacheExtent ~250, keep-alives enabled)
- After: explicit `cacheExtent: 400` + `addAutomaticKeepAlives: false`

**Expected measurable impact** (device-dependent, mid-range / low-memory phones):
- ~10–20 % lower peak memory during home-dashboard scrolling
- Fewer GC pauses and frame drops → smoother scrolling / less jank
- Modest battery savings from reduced memory pressure

Previous run cleared Flutter ImageCache under memory pressure in `didHaveMemoryPressure`.

No security regression (no keep-rule changes, offline integrity preserved, no new permissions).

## Recommendations for next runs
1. Generate full Baseline + Startup Profiles via Macrobenchmark (startup + first list scroll).
2. Prefer `ListView.builder` / `Sliver` + `cacheExtent` for any dynamic long lists.
3. Keep R8 full mode; audit keep rules periodically.
4. Profile with Android Studio / Perfetto on a low-end device.

Metrics should be captured with `flutter run --profile` + Macrobenchmark or Android Vitals after next release.
