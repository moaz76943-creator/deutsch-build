# Performance Improvement: Background JSON Decoding + Cache for Curriculum Hub

## Date
2026-10-29

## Issue Analyzed
- UI jank / main-thread blocking during screen load from synchronous `jsonDecode` of asset JSON (`missions_50.json`).
- Residual merge conflict markers in `lib/screens/curriculum_hub_screen.dart` that could prevent clean builds.
- ListView.separated already used (good, lazy). No security impact (local asset only).

## Improvement Implemented
In `lib/screens/curriculum_hub_screen.dart`:
- Moved `jsonDecode` to a background isolate via `compute(_decodeJson, jsonStr)`.
- Added static in-memory cache (`_cachedMissions`) so subsequent navigations skip re-parsing.
- Cleaned conflict markers; loading remains offline-first and secure.

### Why this helps
- Keeps UI isolate free during parsing → reduced jank, smoother screen transition.
- Cache provides near-instant re-entry (measurable via navigation timing).
- Scales better if mission data grows.
- Aligns with best practices: offload CPU work, caching, efficient lists.

## Expected Measurable Impact
- Frame time during load: reduction of any spikes >16ms from decoding (use Flutter DevTools Timeline or Performance overlay).
- For current ~50-item JSON: small absolute gain (few ms), but eliminates risk of jank on lower-end devices.
- Subsequent visits: load time ~0ms (cache hit) vs previous full re-parse.
- No change to APK size, battery, or network (asset-based).

## Before / After Metrics (to be measured locally)
| Metric | Before | After |
|--------|--------|-------|
| Main-thread JSON decode time | Synchronous (blocks UI) | Offloaded (background) |
| Cache hit on revisit | N/A | Instant |
| UI jank on open | Possible on slow devices | Eliminated for this path |

## Security
No weakening. Still loads only bundled assets via rootBundle. No additional permissions, no cleartext, no logging of sensitive data.

## Related Best Practices Applied
- Lazy / cached loading
- Background isolate for compute
- Efficient RecyclerView equivalent (ListView.separated / builder)
- Complements existing R8 full mode and profileinstaller dependency
