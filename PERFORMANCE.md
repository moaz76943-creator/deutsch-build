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
