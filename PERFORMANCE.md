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
| Memory | Improved | ImageCache + L1 trim on pressure; further tightened below |
| Battery | Good | Offline-only, no background network, WorkManager not needed |
| Network | Excellent | Permissions stripped; zero runtime network |
| UI jank | Good | ListView.builder paths in baseline; CI guard against blocking build() |

## Concrete Improvement (this run)
**Tightened ImageCache limits** in `lib/main.dart`:
- Before: 250 images / 48 MB
- After: 200 images / 32 MB

**Expected measurable impact** (device-dependent, mid-range phones):
- ~15–25 % lower peak image memory during vocabulary sessions
- Fewer GC pauses → smoother scrolling / less jank
- Modest battery savings from reduced memory pressure

No security regression (no keep-rule changes, offline integrity preserved).

## Recommendations for next runs
1. Generate full Baseline + Startup Profiles via Macrobenchmark (startup + first list scroll).
2. Prefer `ListView.builder` / `Sliver` for any dynamic long lists.
3. Keep R8 full mode; audit keep rules periodically.
4. Profile with Android Studio / Perfetto on a low-end device.

Metrics should be captured with `flutter run --profile` + Macrobenchmark or Android Vitals after next release.
