# Performance Analysis — Deutsch بالعربي (Flutter)

## Overview
Offline-first German learning app. Analyzed for startup time, memory, battery, network, and UI jank.

### Current Strengths (already implemented)
- **R8 / Minification**: Enabled in release (`minifyEnabled true`, `shrinkResources true`, custom ProGuard rules).
- **Baseline Profiles**: `baseline-prof.txt` + `androidx.profileinstaller:1.4.1` for AOT compilation of hot paths → faster cold start and reduced jank.
- **Image cache tuning**: In `main.dart`, reduced to 250 images / 48 MB (from defaults 1000 / 100 MB) + memory-pressure clearing.
- **L1 Vocabulary Cache**: LRU with 100 items / 10 MB budget + trim on memory pressure.
- **Isolated bootstrap & CPU worker**: Heavy work off main isolate (`IsolatedBootstrapPipeline`, `persistent_cpu_worker.dart`).
- **Efficient lists**: Most long lists use `ListView.builder` (e.g. vocabulary, verb conjugations with precomputed flat items).
- **CI performance guard**: Static analysis for blocking calls in `build()`, controller leaks, etc.
- **Offline-first**: Minimal network; no cleartext; privacy-focused permissions.

### Areas Reviewed
- Startup: Bootstrap is lightweight and isolated; splash/theme optimized.
- Memory: Caches bounded; image cache trimmed; SQLite on worker where possible.
- Battery: No persistent wake locks; background work minimized (offline).
- Network: Negligible (offline packs).
- UI Jank: Builder pattern used for dynamic lists; const widgets where possible.

## Concrete Improvement (previous run)
**Change**: Converted `MilestoneBadgesPage` from eager `ListView(children: [...map...])` to `ListView.builder` with a precomputed item list (`_HeaderItem`, `_TitleItem`, `_BadgeItem`).

**Why**: Even for moderate lists, eager children materialize all widgets during the first frame. Builder defers construction until scroll, reducing initial layout time and peak memory during screen open. Follows Flutter best practice for list performance and lazy loading.

**Expected measurable impact**:
- First-frame time for the badges screen: ~10-30% reduction on mid-range devices (fewer widgets inflated at once).
- Lower transient memory spike when opening the screen.
- No security impact (pure UI change; no new permissions, no data exposure, offline integrity preserved).

**Before**: All badge cards built in `build()` via spread `...StreakMilestonesEngine.availableBadges.map`.
**After**: Only visible items built via `itemBuilder`; list precomputed once after load.

## Concrete Improvement (this run)
**Change**: Added `RepaintBoundary` and stable `ValueKey`s to each day cell in the `GridView.builder` of `StreakCalendarScreen`.

**Why**: The calendar grid is a frequently viewed static-but-visual component. Isolating each day cell with `RepaintBoundary` prevents unnecessary repaints of the entire grid when surrounding UI updates (e.g. snackbars, haptics, or parent rebuilds). Stable keys improve element matching and reduce rebuild work. This reduces UI jank risk on mid-range devices during screen interactions.

**Expected measurable impact**:
- Reduced overdraw and frame time variance on the streak screen (~5-15% smoother interactions on mid-range devices).
- Lower CPU usage during minor parent rebuilds.
- No security impact (pure rendering optimization; no new permissions, no data exposure).

**Before**: Plain `Container` widgets in grid without isolation or keys.
**After**: Each day cell wrapped in `RepaintBoundary(key: ValueKey('streak_day_$day'))`.

### How to measure
Use Flutter DevTools Timeline or Performance overlay on a physical device:
- Open StreakCalendarScreen and trigger minor rebuilds (e.g. via snackbar).
- Compare raster time / jank percentage before/after.
- Monitor in Android Studio Profiler for GPU/CPU during the screen.

Further improvements for future runs: expand Baseline Profile with more hot paths, add `cacheExtent` tuning, lazy-load secondary feature modules, or WorkManager for any deferred offline pack validation.
