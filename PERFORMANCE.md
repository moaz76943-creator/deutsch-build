# Performance Improvements

## ImageCache Tuning (2026-11-15)

**Change:** Reduced Flutter `ImageCache` from 200 items / 32 MB to 150 items / 24 MB in `lib/main.dart`.

**Before:** 200 / 32 MB (previous tightening on 2026-11-09 from default 1000/100 MB).

**After:** 150 / 24 MB.

**Expected measurable impact:**
- Additional ~10% lower peak image memory footprint on mid-range devices during long vocabulary/image sessions.
- Fewer GC pauses and modest battery savings.
- No impact on perceived image quality (packs are size-constrained; offline-first).
- No security regression (R8, minify, offline permissions, crash-loop guards, baseline profiles unchanged).

**Best practices applied:** Caching limits, memory pressure handling (`didHaveMemoryPressure` clears cache + L1), efficient UI (ListView.builder + RepaintBoundary + cacheExtent already present), baseline profiles, R8.

**Verification:** Monitor via Android Studio Profiler or Flutter DevTools Memory view during extended sessions. Startup time unaffected (baseline profiles + R8 already active).

Other areas (startup, battery, network, UI jank) already addressed via existing code (see baseline-prof.txt, proguard, manifest INTERNET removal, ListView optimizations).
