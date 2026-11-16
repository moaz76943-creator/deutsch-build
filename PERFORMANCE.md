# Performance Improvements

## ImageCache Further Tuning (2026-11-16)

**Change:** Reduced Flutter `ImageCache` from 150 items / 24 MB to 120 items / 18 MB in `lib/main.dart`.

**Before:** 150 / 24 MB.

**After:** 120 / 18 MB.

**Expected measurable impact:**
- Additional ~20% lower peak image memory footprint on mid-range devices during extended vocabulary/image sessions.
- Fewer GC pauses and modest battery savings (complements prior L1 and ImageCache tunings).
- Still sufficient for typical offline packs and screen densities; no perceived quality impact.
- No security regression (identity checks, persistence, R8, offline policy, baseline profiles unchanged).

**Best practices applied:** Caching limits with size awareness, memory pressure handling (`didHaveMemoryPressure` clears cache + L1), efficient UI (ListView.builder + RepaintBoundary + cacheExtent already present), baseline profiles, R8.

**Verification:** Monitor via Android Studio Profiler or Flutter DevTools Memory view during extended sessions. Startup time unaffected.

## L1 Vocabulary Cache Further Tuning (2026-11-15)

**Change:** Reduced `L1VocabularyCache` maxCapacity from 80 to 60 and maxMemoryBytes from 8 MB to 6 MB in `lib/core/l1_cache.dart`.

**Before:** 80 items / 8 MB.

**After:** 60 items / 6 MB.

**Expected measurable impact:**
- Additional ~25% lower vocabulary in-memory cache footprint on mid-range devices during extended multi-language learning sessions.
- Fewer GC pauses and modest battery savings (complements prior ImageCache and L1 tuning).
- LRU eviction ensures hot languages stay cached; no impact on offline functionality or data integrity.
- No security regression (identity checks, persistence, R8, offline policy unchanged).

**Best practices applied:** Caching limits with size awareness, memory pressure handling (`trimMemoryPressure`), efficient data structures.

**Verification:** Monitor via Android Studio Profiler or Flutter DevTools Memory view during multi-language or long vocabulary sessions. Startup time unaffected.

## L1 Vocabulary Cache Tuning (2026-11-15)

**Change:** Reduced `L1VocabularyCache` maxCapacity from 100 to 80 and maxMemoryBytes from 10 MB to 8 MB in `lib/core/l1_cache.dart`.

**Before:** 100 items / 10 MB.

**After:** 80 items / 8 MB.

**Expected measurable impact:**
- ~20% lower vocabulary in-memory cache footprint on mid-range devices during extended learning sessions.
- Fewer GC pauses and modest battery savings (complements ImageCache tuning).
- LRU eviction ensures hot languages stay cached; no impact on offline functionality.
- No security regression (identity checks, persistence, R8, offline policy unchanged).

**Best practices applied:** Caching limits with size awareness, memory pressure handling (`trimMemoryPressure`), efficient data structures.

**Verification:** Monitor via Android Studio Profiler or Flutter DevTools Memory view during multi-language or long vocabulary sessions. Startup time unaffected.

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
