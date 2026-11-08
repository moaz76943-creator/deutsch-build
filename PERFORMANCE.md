# Performance Analysis — Deutsch بالعربي (Flutter)

## Overview
Offline-first German learning app. Analyzed for startup time, memory, battery, network, and UI jank.

### Current Strengths (already implemented)
- **R8 / Minification**: Enabled in release (`minifyEnabled true`, `shrinkResources true`, custom ProGuard rules).
- **Baseline Profiles**: `baseline-prof.txt` + `androidx.profileinstaller:1.4.1` for AOT compilation of hot paths → faster cold start and reduced jank.
- **Image cache tuning**: In `main.dart`, reduced to 250 images / 48 MB (from defaults 1000 / 100 MB) + memory-pressure clearing.
- **L1 Vocabulary Cache**: LRU with 100 items / 10 MB budget + trim on memory pressure.
- **Isolated bootstrap & CPU worker**: Heavy work off main isolate (`IsolatedBootstrapPipeline`, `persistent_cpu_worker.dart`).
- **Efficient lists**: Most long lists use `ListView.builder` (e.g. vocabulary, verb conjugations with precomputed flat items) + `cacheExtent` tuning where cards are complex.
- **CI performance guard**: Static analysis for blocking calls in `build()`, controller leaks, etc.
- **Offline-first**: Minimal network; no cleartext; privacy-focused permissions.

### Areas Reviewed
- Startup: Bootstrap is lightweight and isolated; splash/theme optimized.
- Memory: Caches bounded; image cache trimmed; SQLite on worker where possible.
- Battery: No persistent wake locks; background work minimized (offline).
- Network: Negligible (offline packs).
- UI Jank: Builder pattern used for dynamic lists; const widgets where possible; cacheExtent for prefetch.

## Concrete Improvement (previous run)
**Change**: Converted `MilestoneBadgesPage` from eager `ListView(children: [...map...])` to `ListView.builder` with a precomputed item list (`_HeaderItem`, `_TitleItem`, `_BadgeItem`).

**Why**: Even for moderate lists, eager children materialize all widgets during the first frame. Builder defers construction until scroll, reducing initial layout time and peak memory during screen open. Follows Flutter best practice for list performance and lazy loading.

**Expected measurable impact**:
- First-frame time for the badges screen: ~10-30% reduction on mid-range devices (fewer widgets inflated at once).
- Lower transient memory spike when opening the screen.
- No security impact (pure UI change; no new permissions, no data exposure, offline integrity preserved).

**Before**: All badge cards built in `build()` via spread `...StreakMilestonesEngine.availableBadges.map`.
**After**: Only visible items built via `itemBuilder`; list precomputed once after load.

## Concrete Improvement (previous run)
**Change**: Added `RepaintBoundary` and stable `ValueKey`s to each day cell in the `GridView.builder` of `StreakCalendarScreen`.

**Why**: The calendar grid is a frequently viewed static-but-visual component. Isolating each day cell with `RepaintBoundary` prevents unnecessary repaints of the entire grid when surrounding UI updates (e.g. snackbars, haptics, or parent rebuilds). Stable keys improve element matching and reduce rebuild work. This reduces UI jank risk on mid-range devices during screen interactions.

**Expected measurable impact**:
- Reduced overdraw and frame time variance on the streak screen (~5-15% smoother interactions on mid-range devices).
- Lower CPU usage during minor parent rebuilds.
- No security impact (pure rendering optimization; no new permissions, no data exposure).

**Before**: Plain `Container` widgets in grid without isolation or keys.
**After**: Each day cell wrapped in `RepaintBoundary(key: ValueKey('streak_day_$day'))`.

## Concrete Improvement (previous run)
**Change**: Expanded `android/app/src/main/baseline-prof.txt` with additional hot paths for `GridView`/`GridView.builder` and gesture handling (`GestureBinding.handleEvent`, `RenderObject.hitTest`).

**Why**: Baseline profiles enable AOT compilation of frequently executed methods via ProfileInstaller. Dashboards and calendars use GridView heavily; gesture paths are critical for first interactions and scroll flings. Adding these reduces interpretation overhead on first use after install or profile update, improving startup-to-interaction time and reducing early jank without affecting R8/security.

**Expected measurable impact**:
- Cold-start to first meaningful interaction (TTID / first grid interaction): additional ~5-15% improvement on mid-range devices (cumulative with existing profile).
- Smoother initial scrolls and taps on dashboard/calendar screens.
- No security impact (profile only affects compilation; R8 minify/obfuscation unchanged; no new code paths or permissions).

**Before**: Profile covered ListView and basic rendering.
**After**: Includes GridView and gesture hit-testing hot paths.

## Concrete Improvement (previous run)
**Change**: Further expanded `android/app/src/main/baseline-prof.txt` with hot paths for `ExpansionTile.build`, image stream listeners, and `RenderImage.paint`.

**Why**: Vocabulary screens heavily use ExpansionTile for detailed cards and image rendering for visual memory aids. AOT-compiling these reduces first-interaction jank when expanding cards or loading images after install. Aligns with baseline profile best practices for critical user journeys without changing any runtime code or security posture.

**Expected measurable impact**:
- Reduced jank on first expansion of vocabulary cards or image loads: ~5-10% smoother frame times on mid-range devices.
- Faster perceived responsiveness for learning sessions involving visuals.
- No security impact (pure profile addition; R8 full mode unchanged; no new permissions or data flows).

**Before**: Profile included GridView and basic gestures.
**After**: Covers ExpansionTile and image painting/decode paths used in journal and vocabulary views.

## Concrete Improvement (this run)
**Change**: Added `cacheExtent: 800` to the main `ListView.builder` in `VerbConjugationPage` and `cacheExtent: 600` to the favorites list in `VerbFavoritesPage`.

**Why**: Verb conjugation cards are complex (multiple Text, IconButtons, nested Containers). Default cacheExtent (250px) can cause hitches during fast flings as items are built on demand. Raising it prefetches more off-screen items, reducing frame drops during scroll while keeping memory bounded by the builder pattern. Follows Flutter performance best practices for lists with heavy item widgets.

**Expected measurable impact**:
- Smoother scrolling / lower jank % on the verb conjugation screen: ~5-15% fewer dropped frames during continuous scroll on mid-range devices.
- Slightly higher peak memory during scroll (bounded), but better perceived fluidity.
- No security impact (pure layout parameter; no new permissions, no data changes, R8/obfuscation unaffected).

**Before**: Default cacheExtent (~250 logical pixels).
**After**: Explicit 800/600 px prefetch for complex cards.

### How to measure
Use Flutter DevTools Performance view or Android Studio Profiler / Macrobenchmark:
- Open verb conjugation page, perform rapid flings/scrolls, measure frame times, jank percentage, and raster thread time.
- Compare before/after on physical device (profile or release builds).
- Monitor memory during scroll.

Further improvements for future runs: lazy-load secondary feature modules more aggressively, WorkManager for any deferred offline pack validation, or itemExtent where heights are fixed.

## Concrete Improvement (this run)
**Change**: Added `cacheExtent: 600` to both `ListView.separated` instances in `VocabularyV35` (`_buildListView` for corpus items and the custom entries list).

**Why**: Vocabulary cards use complex `ExpansionTile`s with multiple nested widgets, images/audio buttons, and conditional content. Default cacheExtent can lead to build hitches during rapid scrolling as off-screen complex items are materialized. Explicit prefetch of 600 logical pixels keeps more items ready, reducing jank while the builder pattern still bounds memory. Aligns with Flutter list performance best practices.

**Expected measurable impact**:
- Smoother continuous scrolling on the vocabulary list view: ~5-15% reduction in dropped frames / jank percentage on mid-range devices during flings.
- Lower raster/UI thread spikes when scrolling past expansion-capable cards.
- Slightly higher (but bounded) memory during active scroll.
- No security impact (layout parameter only; no new permissions, no data exposure, R8/obfuscation and offline integrity unchanged).

**Before**: Default cacheExtent (~250px).
**After**: Explicit 600px prefetch for complex vocabulary cards.

### How to measure
Flutter DevTools Performance / Android Profiler: open vocabulary screen in list mode, rapid scroll/fling, compare frame times and jank % before/after (profile/release build on physical device).
