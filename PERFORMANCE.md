# Performance Improvements

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

# Performance Improvements

## 2026-11-06: Expanded Baseline Profile for Broader AOT Coverage (Startup Time / UI Jank)
