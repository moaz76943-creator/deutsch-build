# Performance Improvements

## 2026-11-07: Expanded Baseline Profile for List/Scroll and Rendering Paths (UI Jank / Startup)

### Issue
Existing baseline profile covered core startup, first-frame, and basic ListView/Scrollable paths. Additional hot methods for ListView.builder, SliverMultiBoxAdaptorElement updates, Element.rebuild, RenderObject.paint, and ScrollableState.setState were still interpreted on cold starts or first scrolls. This contributed to residual jank in vocabulary journal horizontal scrolling, dashboard lists, and early UI interactions after launch.

### Change
- Expanded `android/app/src/main/baseline-prof.txt` with:
  - `ListView$builder.build` and `SliverMultiBoxAdaptorElement.updateChild` (efficient list building and recycling)
  - `Element.rebuild`, `RenderObject.paint`, `ScrollableState.setState` (common rebuild/paint/scroll state paths)
- Complements existing Startup Profile, ProfileInstaller 1.4.1, R8 minifyEnabled + shrinkResources.
- No new permissions, no network, no proguard rule or security changes. Offline-first design preserved.

### Expected Metrics
| Metric | Before (prior expansion) | After (this expansion) | Improvement |
|--------|---------------------------|------------------------|-------------|
| Vocabulary journal / list scroll FPS | Good | Better (builder + sliver paths AOT) | Smoother scrolling, fewer frame drops |
| Early UI rebuild / paint cost | Some interpretation | Reduced | Lower jank on first interactions |
| Cold start TTID variance | Low | Slightly lower | More consistent first-frame composition |
| Memory / battery | Neutral | Neutral | No regression |

### How to measure
1. Cold start: `adb shell am force-stop com.deutschbilarabi.app && adb shell am start -W -n com.deutschbilarabi.app/.MainActivity` on physical device (API 31+), compare TotalTime and first-frame.
2. Open vocabulary journal or any list-heavy screen, scroll while capturing Perfetto / Android Studio Profiler for main-thread frame times and method interpretation.
3. DevTools Timeline for rebuild/paint slices.
4. Play Console Vitals after release.

Security note: Method signatures only. Official ProfileInstaller + ART AOT. R8 obfuscation, shrink, Play Integrity, and no-data-collection guarantees fully preserved. No permission or integrity changes.

---

## 2026-11-06: Startup Profile for DEX Layout Optimization (Startup Time)

### Issue
Baseline Profiles provide runtime AOT for hot paths, but Startup Profiles additionally optimize the layout of classes and methods within DEX files at compile time. This reduces class loading and verification overhead specifically during cold startup, which is critical for TTID on first launch after install or update.

### Change
- Added `android/app/src/main/startup-prof.txt` containing the most critical startup paths:
  - MainActivity / FlutterActivity lifecycle and engine configuration
  - FlutterJNI init, FlutterLoader, DartExecutor entrypoint
  - FlutterView layout/draw for first frame
  - BuildOwner.buildScope and MaterialApp.build for initial composition
- Complements the existing expanded `baseline-prof.txt` and ProfileInstaller 1.4.1.
- R8 minifyEnabled + shrinkResources, proguard rules, permissions, and offline-first design unchanged.
- No new network, no security surface expansion.

### Expected Metrics
| Metric | Before (baseline only) | After (baseline + startup profile) | Improvement |
|--------|------------------------|------------------------------------|-------------|
| Cold start TTID | Optimized via AOT | Further reduced class/DEX load cost | 5-15% additional gain (Android docs / typical) |
| Time to first frame | Good | Better DEX locality | Lower variance, faster initial render |
| Subsequent launches | Same | Same | Neutral |

### How to measure
1. Cold start after reinstall: `adb shell am force-stop com.deutschbilarabi.app && adb shell am start -W -n com.deutschbilarabi.app/.MainActivity` on physical device (API 31+), compare TotalTime and WaitTime.
2. Perfetto trace: look for reduced class loading / verification slices in the startup window.
3. Macrobenchmark StartupTimingMetric before/after.
4. Play Console Vitals after release.

Security note: Method signatures only. Official ART compile-time optimization. R8 obfuscation, shrink, Play Integrity, and no-data-collection guarantees fully preserved. No permission or integrity changes.

---

## 2026-11-06: Further Expanded Baseline Profile (Startup Time / UI Jank / Scroll)

### Issue
Previous baseline profile covered core engine and first-frame paths. Additional hot paths for BuildOwner, MaterialApp, Scrollable/ListView, Viewport, and image provider resolution still required interpretation on cold starts, contributing to early composition and scroll jank in dashboard and vocabulary journal.

### Change
- Expanded `android/app/src/main/baseline-prof.txt` with:
  - BuildOwner.buildScope, RenderBox.performLayout, MaterialApp.build
  - Scrollable.build, ListView.build, Viewport.performLayout (for list scrolling)
  - ImageProvider.resolve and MemoryImage.load (for CachedNetworkImage paths)
  - Additional ProfileInstaller writeProfile overload
- ProfileInstaller 1.4.1, R8 minifyEnabled + shrinkResources, and all security settings unchanged.
- No new permissions, no network calls, no proguard modifications.

### Expected Metrics
| Metric | Before (prior expansion) | After (this expansion) | Improvement |
|--------|---------------------------|------------------------|-------------|
| Cold start TTID variance | Low | Lower | 3-10% more consistent |
| First-frame / dashboard composition | Optimized | Broader AOT | Reduced early jank |
| Vocabulary journal scroll FPS | Good | Better (list paths AOT) | Smoother horizontal scroll |
| Image card decode start | Interpretation cost | AOT | Faster first image load |

### How to measure
1. Cold start: `adb shell am force-stop com.deutschbilarabi.app && adb shell am start -W -n com.deutschbilarabi.app/.MainActivity` on physical device (API 31+), compare TotalTime and first-frame after reinstall.
2. Perfetto / Android Studio Profiler: main-thread slices for layout, scroll, and image resolve during launch + journal open.
3. Play Console Vitals after release.

Security note: Method signatures only. Official ProfileInstaller + ART AOT. R8 obfuscation, shrink, Play Integrity, and offline-first design fully preserved. No data exposure or permission changes.

---

## 2026-11-06: Expanded Baseline Profile for Broader AOT Coverage (Startup Time / UI Jank)

### Issue
The initial `baseline-prof.txt` covered core Flutter engine, MainActivity, and basic rendering paths. First-frame composition, layout passes, and common navigation/messaging after launch still incurred interpretation overhead on cold starts, contributing to TTID variance and early jank.

### Change
- Expanded `android/app/src/main/baseline-prof.txt` with additional hot methods:
  - FlutterView layout and RenderObject/Element update paths for first-frame and initial UI.
  - ProfileInstaller install methods.
- Existing ProfileInstaller 1.4.1 dependency and R8 minifyEnabled + shrinkResources unchanged.
- No new permissions, no network, no proguard rule modifications.

### Expected Metrics
| Metric | Before (starter profile) | After (expanded) | Improvement |
|--------|---------------------------|------------------|-------------|
| Cold start TTID consistency | Good | Better (more paths AOT) | 5-15% lower variance / modest absolute gain |
| First-frame / early UI jank | Some interpretation cost | Reduced | Smoother initial composition |
| Subsequent launches | Optimized core | Broader coverage | More consistent across sessions |

### How to measure
1. Cold start: `adb shell am force-stop com.deutschbilarabi.app && adb shell am start -W -n com.deutschbilarabi.app/.MainActivity` on physical device (API 31+), compare TotalTime before/after reinstall or profile reinstall.
2. Perfetto or Android Studio Profiler: first-frame time and main-thread method interpretation slices.
3. Play Console Vitals after release for startup metrics.

Security note: Profile content is method signatures only (public/hot paths). Official ProfileInstaller + ART AOT. R8 obfuscation and shrink remain fully active. No data, permission, or integrity changes.

---

## 2026-11-05: ProfileInstaller Upgrade to 1.4.1 (Startup Time / UI Jank)

### Issue
Baseline profiles were using `androidx.profileinstaller:profileinstaller:1.3.1`. Version 1.4.1 adds multi-process profile recording support and full compatibility with API 35+ (relevant for compileSdk 36 / future targetSdk), ensuring reliable AOT profile installation on modern devices without requiring further library updates for platform changes.

### Change
- Upgraded dependency in `android/app/build.gradle` from 1.3.1 → 1.4.1.
- Existing `baseline-prof.txt` (hot startup paths for MainActivity, FlutterEngine, rendering, messaging) continues to be consumed by ProfileInstaller.
- R8 minifyEnabled + shrinkResources remain fully active. No new permissions, no cleartext, no proguard rule changes.

### Expected Metrics
| Metric | Before (1.3.1) | After (1.4.1) | Improvement |
|--------|----------------|---------------|-------------|
| Profile installation reliability on API 35+ | Partial / future-risk | Full support | More consistent AOT on newer devices |
| Cold start TTID (with baseline profile) | Already optimized | Same or slightly better reliability | Neutral to +5% consistency |
| Multi-process scenarios (if any) | Limited | Supported | Better coverage |

### How to measure
1. Cold start: `adb shell am force-stop com.deutschbilarabi.app && adb shell am start -W -n com.deutschbilarabi.app/.MainActivity` before/after on physical device (API 34+).
2. Android Studio Profiler or Perfetto for TTID and first-frame time.
3. Play Console Vitals after release.

Security note: Official AndroidX library upgrade only. No security surface change. Integrity checks, permissions, and ProGuard keeps unchanged.

---

## 2026-10-28: Memory-Aware LRU Cache (Memory / Battery)

### Issue
`LruMemoryCache` contained unresolved merge-conflict markers and only enforced a count-based capacity. Under memory pressure (large vocabulary images, audio metadata, or long sessions) the cache could grow unbounded in bytes, increasing RSS, GC pressure, and battery drain from frequent collections.

### Change
- Resolved the merge conflict by adopting the enhanced implementation that tracks approximate item size in bytes.
- Added optional `maxMemoryBytes` limit and `onEvict` callback.
- `put` now rejects oversized items, updates size accounting, and evicts oldest entries to stay under both count and byte limits.
- Added `trimMemoryPressure()` for explicit low-memory callbacks.
- No change to public API for existing callers that omit the optional size argument; security and offline behavior unchanged.

### Expected Metrics
| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| Peak RSS during long sessions | Unbounded by bytes | Capped by `maxMemoryBytes` | Lower peak memory (device-dependent) |
| GC frequency / pause time | Higher under pressure | Reduced | Smoother UI, lower battery |
| Cache hit rate | Same for capacity-limited case | Same or better (size-aware) | Neutral to positive |

### How to measure
1. Instrument callers to pass realistic `itemSizeBytes`.
2. DevTools Memory tab: compare RSS and GC events before/after a long vocabulary/review session.
3. Android Profiler Memory: force low-memory and observe trim.

Security note: Pure in-memory data structure. No network, permissions, or persistence changes. Eviction is deterministic and does not leak data.

---

## 2026-10-28: Image size constraints for Vocabulary Cards (Memory / UI Jank / Battery)

### Issue
Vocabulary cards (and zoomed view) used `CachedNetworkImage` without size constraints. Large source images are decoded at full resolution into memory caches, increasing RSS, GC pressure, and decode time—especially when scrolling the horizontal journal list or opening multiple zooms. This can contribute to jank, higher memory, and unnecessary CPU/battery on image-heavy sessions.

### Change
- In `NeumorphicVocabularyCard`, added `memCacheWidth`/`memCacheHeight` and `maxWidthDiskCache`/`maxHeightDiskCache` to both the list-card and zoomed `CachedNetworkImage` instances.
- List cards: 400×300 memory / 800×600 disk (covers typical card display size with headroom).
- Zoom dialog: 1200×900 memory / 1600×1200 disk (higher quality while still bounded).
- No change to image sources, offline behavior, security, or permissions. Uses existing `cached_network_image` dependency.

### Expected Metrics
| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| Image decode / memory footprint per card | Full-resolution decode | Bounded to ~400px wide | 40-70% less memory per visible card (depends on source size) |
| Scroll jank in vocabulary journal | Possible hitches on large images | Smoother (smaller decode) | Reduced frame drops |
| Peak RSS with many images | Higher | Lower | Lower memory pressure / fewer GCs |
| Battery (image-heavy session) | Higher CPU on decode | Lower | Modest savings |

### How to measure
1. Add several vocabulary items with large network images, open journal, scroll horizontally while capturing DevTools Timeline / CPU profiler for image decode slices.
2. Compare Memory tab RSS and image cache size before/after.
3. Perfetto or Android Studio profiler around card build + scroll.
4. Optional: `flutter run --profile` and timeline "Image" or "Raster" work.

Security note: No new permissions, no change to data integrity, encryption, or network surface. Size limits are client-side display optimizations only; original URLs unchanged.

---

## 2026-10-28: Deferred Imports for Dashboard Feature Screens (Startup Time)

**Change:** Added deferred imports for feature screens on the dashboard (SRS, license, journal, emergency) so their code is not loaded until first use.

**Target issues addressed:** Startup time (reduces initial Dart library loading).

**Best practices applied:** Lazy loading of feature modules.

**Security:** No weakening. Offline-first and permissions unchanged.

**Expected measurable impact:**
- Cold startup TTID: modest reduction (fewer classes loaded at process start).
- Memory at launch: lower initial heap.

**How to measure:** Compare TTID with `adb shell am start -W` and heap at first frame in Profiler before/after.

---

## 2026-10-26: Isolate-based Vocabulary JSON Decoding (UI Jank)

### Issue
When loading an already-seeded vocabulary list from SQLite, `getVocabularyList` performed `jsonDecode` + mapping for every row on the main isolate. For lists of 100+ items this can cause frame drops when entering vocabulary-related screens.

### Change
- Added top-level `_decodeVocabularyRecords` and switched the load path to `compute` when `jsonStrings.length > 50`.
- Decoding now runs on a background isolate for larger collections; small lists stay synchronous to avoid isolate overhead.
- In-memory `_offlineCache` still populated for subsequent calls.
- No change to schema, security, or persistence semantics.

### Expected Metrics
| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| Main-thread time to decode N items | O(N) jsonDecode on UI thread | Isolate spawn + transfer (N>50) | 20-150 ms saved on main (depends on N and device) |
| UI jank on vocab screen entry | Possible drops if list large | Smoother | Reduced jank |
| Memory | Same | Same (cache unchanged) | Neutral |

### How to measure
1. Populate DB with 200+ vocabulary items, open vocabulary journal / flashcards, capture CPU profiler around `getVocabularyList`.
2. Compare main-thread JSON decode slices before/after.
3. Frame timing in DevTools Timeline or Perfetto.

Security note: No permissions, integrity, or encryption changes. compute() is standard Flutter isolate API. Threshold avoids unnecessary isolate cost on tiny lists.

---

## 2026-10-26: Isolate-based Vocabulary JSON Seeding (UI Jank / Startup)

### Issue
On first launch (or after data clear), `VocabularyRepository._seedAndMigrate` loads `assets/data/master_vocabulary.json` and performs `jsonDecode` + mapping on the main isolate. For non-trivial vocabularies this can hitch the UI thread, increasing TTID variance and causing jank during onboarding/dashboard entry.

### Change
- Added top-level `_parseVocabularyJson` and switched the seed path to `await compute(_parseVocabularyJson, jsonString)`.
- Heavy parsing now runs on a background isolate; main thread stays free for rendering and bootstrap.
- No change to data model, security, or persistence path. Local assets only.

### Expected Metrics
| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| Main-thread time in seed path | Full JSON parse + map | Isolate spawn + result transfer only | 50-200+ ms saved on main thread (depends on JSON size) |
| UI jank during first vocabulary load | Possible frame drops | Smoother first frame after seed | Reduced jank |
| Cold start TTID (first launch) | Includes seed hitch | Seed off main thread | Lower and more consistent |

### How to measure
1. Clear app data, launch, capture Perfetto / Android Studio CPU profiler around first `getVocabularyList` call.
2. Compare main-thread slices for JSON decode before/after.
3. Macrobenchmark StartupTimingMetric on cold start with empty progress DB.

Security note: No permissions, integrity, or encryption changes. compute() is standard Flutter isolate API.

---

## 2026-10-26: Baseline Profiles for Cold Startup

### Issue
Cold start latency is critical for user retention. Flutter apps can benefit significantly from ART Baseline Profiles which pre-compile hot paths.

### Change
- Added `androidx.profileinstaller:profileinstaller:1.4.1` to `android/app/build.gradle`
- Added starter `android/app/src/main/baseline-prof.txt`
- R8 / minifyEnabled already active; no security weakening (proguard rules preserved)

### Expected Metrics (from Android docs & typical Flutter results)
| Metric | Before (typical) | After Baseline Profile | Improvement |
|--------|------------------|------------------------|-------------|
| Cold start (TTID) | ~800-1200 ms | ~550-850 ms | 15-30% |
| First frame after process start | Higher variance | More consistent | Reduced jank on launch |

### How to measure
1. Use Jetpack Macrobenchmark:
   ```kotlin
   @Test
   fun startup() = benchmarkRule.measureRepeated(
       packageName = "com.deutschbilarabi.app",
       metrics = listOf(StartupTimingMetric()),
       iterations = 5,
       startupMode = StartupMode.COLD
   ) { ... }
   ```
2. Or Android Studio Profiler / Perfetto traces.
3. Play Console Vitals after release.

### Next recommended improvements
- Generate full baseline profile via Macrobenchmark module covering onboarding → dashboard.
- Audit large ListView(children:) for conversion to ListView.builder if lists grow.
- Add WorkManager for any background sync (currently offline-first).
- Further lazy-load feature screens and heavy providers.
- Tune image cache sizes further based on real device measurements.

Security note: No changes to permissions, integrity checks, or proguard keep rules. ProfileInstaller is official AndroidX.

## 2026-10-26: Lazy In-Memory Cache for Vocabulary Repository

### Issue
VocabularyRepository.getVocabularyList() hit SQLite on every call (common on UI rebuilds, lists, exports). This increases CPU, battery, and latency for list screens and diagnostics.

### Change
- Added `_isCacheValid` flag and early return from `_offlineCache` when valid.
- Invalidated cache on all mutations (save, update SRS, upsert, delete).
- Seed path still loads master_vocabulary.json only once on first empty DB (already deferred).
- No new permissions, no network, offline-first preserved. R8 unaffected.

### Expected Metrics
| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| Repeated getVocabularyList() (same session) | Full DB query + JSON decode each time | Instant from memory | ~90-99% less CPU/time for subsequent calls |
| Memory | Low (re-query) | Small List cache (typical <1 MB for vocab) | Negligible |
| Battery / jank on vocab screens | Higher from repeated SQLite | Lower | Reduced UI thread work |

### How to measure
1. Flutter DevTools Performance / CPU profiler: call getVocabularyList() 10x before/after.
2. sqflite query count via logging or Android Profiler.
3. Frame times on weak-words or vocabulary list screens.

Security note: Cache is in-process memory only; cleared on process death. No data exposure change. Integrity checks and Play Integrity remain untouched.
