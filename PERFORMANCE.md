# Performance Improvements

## 2026-11-05: Memory Pressure Observer for L1 Cache Trim (Memory / Battery)

### Issue
The L1 vocabulary cache (`L1VocabularyCache` / `LruMemoryCache`) had a `trimMemoryPressure()` method that halves capacity under pressure, but it was never invoked. On low-memory devices or long sessions with many vocabulary items/images, the process could retain more RSS than necessary, increasing GC frequency, frame drops, and battery use from repeated collections.

### Change
- In `ResilientAppRoot` (`lib/main.dart`), mixed in `WidgetsBindingObserver`.
- Registered the observer in `initState` and unregistered in `dispose`.
- Overrode `didHaveMemoryPressure()` to call `L1VocabularyCache().trimMemoryPressure()`.
- Added a debug log for observability.
- No changes to persistent storage, security gates (CrashLoopGuard, ProductionAcceptance), permissions, or offline-first behavior.

### Expected Metrics
| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| Peak RSS under memory pressure | Full cache retained | Halved on `didHaveMemoryPressure` | 30-50% temporary reduction in cache footprint |
| GC pauses / frequency during pressure | Higher | Reduced after trim | Smoother UI, lower battery |
| App survival on low-memory devices | Higher OOM risk | Better chance of continuing | Improved stability |
| Cache hit rate after pressure | N/A | Lower until refill | Temporary, acceptable tradeoff |

### How to measure
1. Fill vocabulary cache with 100+ items, then use Android Studio Profiler → Memory → force "Low memory" or use `adb shell am send-trim-memory`.
2. Observe DevTools Memory tab: RSS drop and reduced GC events after the callback.
3. Confirm log: `[DBA][MEMORY] Trimmed L1 cache under memory pressure`.
4. Verify offline vocabulary screens still function (cache refills on next access).

Security note: Only in-memory cache is trimmed. No data loss, no new permissions, no weakening of integrity, encryption, or Play Integrity checks. Observer is standard Flutter lifecycle API.

---

## 2026-11-05: Resolve Merge Conflict + Isolate-based JSON Decode for Vocabulary List (UI Jank / Startup)

### Issue
`lib/repositories/vocabulary_repository.dart` contained unresolved Git merge-conflict markers (including a broken `$(cat ...)` placeholder). This made the file invalid Dart and prevented clean builds. Additionally, even after resolution, `getVocabularyList` and the seed path performed `jsonDecode` + mapping on the main isolate for potentially large lists (100+ items), risking UI jank and startup hitching on vocabulary screens or first launch.

### Change
- Resolved the merge conflict by adopting the clean staging implementation and applying the previously planned isolate optimizations.
- Added top-level `_decodeVocabularyRecords` and `_parseVocabularyJson` functions.
- In `getVocabularyList`, when `jsonStrings.length > 50`, decoding now uses `await compute(...)` so heavy work runs on a background isolate; small lists remain synchronous to avoid isolate overhead.
- Seed path (`_seedAndMigrate`) and `importBackupJson` also use `compute` for parsing.
- In-memory `_offlineCache` and invalidation logic preserved.
- No schema, permission, network, or security changes. Offline-first behavior and R8/ProGuard compatibility unchanged.

### Expected Metrics
| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| Build / compile validity | Broken (conflict markers) | Clean Dart | Build succeeds |
| Main-thread time to load N>50 vocab items | Full jsonDecode on UI thread | Isolate spawn + transfer | 20-150 ms saved on main (device-dependent) |
| UI jank on vocab screen entry / first seed | Possible frame drops | Smoother | Reduced jank |
| Cold-start TTID (with seed) | Includes main-thread parse | Parse off main | More consistent |

### How to measure
1. Clear app data, launch, capture Perfetto / Android Studio CPU profiler around first `getVocabularyList` / seed.
2. Populate 200+ items, open vocabulary journal, compare main-thread slices before/after.
3. Frame timing in DevTools Timeline; check for absence of long JSON decode on UI thread.
4. Confirm no regression in cache hit rate or offline operation.

Security note: No new permissions, no data exposure, no weakening of integrity checks, encryption, or Play Integrity. `compute` is the standard Flutter isolate API. Threshold prevents unnecessary overhead on tiny lists.

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
