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
| UI jank | Improved | ListView.builder + RepaintBoundary on dashboard and curriculum hub; CI guard against blocking build() |

## Concrete Improvement (this run — 2026-11-10)
**Added RepaintBoundary around CurriculumHubScreen ListView.separated items** in `lib/screens/curriculum_hub_screen.dart`:
- Before: plain `itemBuilder` returning AppBaseGlassCard directly (potential overpaint on complex glass cards during scroll)
- After: each item wrapped in `RepaintBoundary`

**Expected measurable impact** (device-dependent, mid-range phones):
- Reduced overpainting / fewer skipped frames during curriculum mission list scrolling
- Smoother interactions on lists with gradient/glass cards
- Modest reduction in GPU work and battery drain from unnecessary repaints

Previous runs optimized HomeScreen ListView with RepaintBoundary + cacheExtent/addAutomaticKeepAlives, ImageCache limits, and JSON compute isolation.

No security regression (no keep-rule changes, offline integrity preserved, no new permissions).

## Recommendations for next runs
1. Generate full Baseline + Startup Profiles via Macrobenchmark (startup + first list scroll).
2. Prefer `ListView.builder` / `Sliver` + `cacheExtent` for any dynamic long lists.
3. Keep R8 full mode; audit keep rules periodically.
4. Profile with Android Studio / Perfetto on a low-end device.
5. Consider wrapping other complex card lists (weak words, grammar guides) with RepaintBoundary if frame drops are observed.

Metrics should be captured with `flutter run --profile` + Macrobenchmark or Android Vitals after next release.
