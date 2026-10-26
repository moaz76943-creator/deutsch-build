# Performance Improvements Log

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
- Ensure vocabulary JSON load is deferred until needed (lazy).
- Add WorkManager for any background sync (currently offline-first).

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
