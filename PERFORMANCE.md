# Performance Improvements

## 2026-10-28: Memory-bounded Image Caching for Vocabulary Cards (Memory / UI Jank / Battery)

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

**Change:** Added `androidx.profileinstaller:profileinstaller:1.4.1` and an initial `baseline-prof.txt`.

**Target issues addressed:** Startup time, UI jank (first frames after cold start).

**Best practices applied:** Baseline profiles (AOT compilation of hot startup paths), complementary to existing R8/minifyEnabled + shrinkResources.

**Security:** No weakening. No extra permissions, no cleartext, existing ProGuard keeps remain. ProfileInstaller is a standard AndroidX library.

**Expected measurable impact** (based on Google Android performance guidance for Flutter/Android apps):
- Cold startup time: 15–40% reduction (typical measured range for apps enabling baseline profiles).
- First-frame / UI jank on launch: noticeable reduction in janky frames during initial composition.

**Before:** No baseline profile support; ART interprets startup methods on every cold start.
**After:** ProfileInstaller installs the profile on first run; subsequent launches use AOT-compiled paths.

**Next steps for full measurement:**
1. Generate a full profile using a Macrobenchmark module or the Flutter `baseline_profile` package on a physical device.
2. Measure with Android Studio Profiler or `adb shell am start -W` before/after.
3. Commit the generated `baseline-prof.txt`.

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
