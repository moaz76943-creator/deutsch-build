# Performance Analysis — Deutsch بالعربي (Flutter Android)

**Date:** 2026-11-09  
**Focus areas:** startup time, memory, battery, network, UI jank  
**Constraints:** Security must not be weakened (R8, ProGuard, integrity, offline-first preserved).

## Current State (as of main @ 30bfa025)

| Area | Status | Notes |
|------|--------|-------|
| Startup (TTID) | Good | Baseline Profile present (`android/app/src/main/baseline-prof.txt`) covering Activity, Flutter embedding, engine init, first frame, ListView. ProfileInstaller 1.4.1. Minimal bootstrap pipeline. |
| Memory | Good | ImageCache capped at 250 images / 48 MB in `main.dart`. `LruMemoryCache` with `trimMemoryPressure()`. `didHaveMemoryPressure` handler. Asset bundle budget locked by test. |
| Battery | Good | Offline-first; no unnecessary network. Image cache reduced. Background work audited (no WorkManager currently). |
| Network | Excellent | Offline-first architecture; `http` only for optional packs. CachedNetworkImage used where needed. |
| UI Jank | Improving | Many screens already use `ListView.builder` + `cacheExtent: 300` + `addAutomaticKeepAlives: false` (e.g. weak words, curriculum hub). R8 full minify + shrinkResources enabled. |
| R8 / ProGuard | Strong | `minifyEnabled true`, `proguard-android-optimize.txt`, custom rules with 5 optimization passes, repackageclasses. |

**Security:** All changes preserve R8/obfuscation, no new permissions, no data exposure, offline integrity gates untouched.

## Improvement Implemented This Run (2026-11-09)

**Target:** Home dashboard scroll smoothness & memory (UI jank / memory).

**Change:** `lib/screens/home_screen.dart`
- Added `cacheExtent: 300` to `ListView.builder`.
- Added `addAutomaticKeepAlives: false`.

**Expected measurable impact:**
- Lower peak memory during dashboard scroll (fewer retained off-screen elements).
- Reduced jank risk on mid-range devices when the dashboard grows.
- Consistent with existing optimized screens.

**Before/After metrics (to capture on device):**
- Use Flutter DevTools Timeline or `flutter run --profile` + Android Studio Memory Profiler.
- Scroll the home screen 10 times; compare RSS and frame times (before ~default 250 cacheExtent + keep-alives, after 300 + no keep-alives).
- Expected: 5–15% lower memory delta during scroll, smoother 60/120 FPS on mid-tier hardware.

**Verification:**
```bash
flutter analyze lib/screens/home_screen.dart
flutter test  # existing tests still pass
```

## Next Recommended Improvements (future runs)

1. Generate a real Baseline Profile via Macrobenchmark module covering onboarding → dashboard → vocabulary list scroll (current profile is hand-written).
2. Audit remaining `ListView(children:)` for conversion to `.builder` + `itemExtent` where heights are known.
3. Lazy-load heavy audio/TTS engines behind isolates or deferred components.
4. Add WorkManager only if background content sync is required (currently not needed).
5. Measure cold startup TTID with Android Vitals / Macrobenchmark after next profile update.

---
*Generated and applied via automated performance pass. Changes do not weaken security.*
