# Performance Improvements

## Baseline Profiles (Android)

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

Other optimizations already present: R8 full optimization, multiDex, isolated bootstrap pipeline, offline-first (minimal network), LRU caches in core.
