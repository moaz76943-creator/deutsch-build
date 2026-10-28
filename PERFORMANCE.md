# Performance Improvements Log

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

## 2026-10-28: Deferred Imports for Dashboard Feature Screens (Startup Time)

### Issue
DashboardScreen eagerly imported several feature screens (SRS flashcards, vocabulary journal, emergency phrasebook, license screen). Even if not navigated to immediately, Dart loads the full libraries at app start, increasing initial isolate memory and cold-start parsing/compilation time.

### Change
- Converted the four feature screen imports to deferred imports (`deferred as ...`).
- Updated navigation to call `loadLibrary()` on tap before pushing the route.
- Resolved minor merge-conflict markers in the GridView children.
- No change to UI, security, data flow, or offline behavior.

### Expected Metrics
| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| Initial library load / cold start TTID | All feature screens parsed on launch | Deferred until first navigation | 10-50 ms+ saved on cold start (depends on screen complexity and device) |
| Memory at startup | Higher (unused screen code) | Lower until used | Reduced initial RSS |
| First navigation latency | Instant | + small loadLibrary cost (usually <20 ms, cached after) | Negligible; subsequent taps instant |

### How to measure
1. Cold-start Macrobenchmark or Perfetto around `main()` → first dashboard frame.
2. Compare `flutter run --profile` startup timelines or Android Studio CPU profiler library load slices.
3. Monitor process memory in DevTools Memory tab right after launch vs. after visiting each screen.

Security note: Deferred loading uses standard Dart isolate/library loading. No permissions, integrity, or proguard changes. Screens remain fully offline.

---

## 2026-10-27: Isolate-based Vocabulary DB Decoding (UI Jank)

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

Security note: No changes to permissions, integrity checks, or proguard keep rules. ProfileInstaller is official AndroidX.
