# Performance Optimizations — Deutsch بالعربي

## 2026-10-29: Deferred Play Integrity Bootstrap (Cold Start)

### Issue
Play Integrity attestation (`IntegrityBootstrapStep`) was part of the blocking bootstrap pipeline in `lib/main.dart`. Even though marked non-critical, a slow or timed-out call (up to 8s) delayed the first frame / UI appearance.

### Change
- Critical bootstrap steps run first.
- UI is shown as soon as critical path succeeds.
- Integrity token request is launched with `unawaited` after `setState` so it does not block cold start.
- Existing feature-gating logic is unchanged; attestation still occurs and is logged.

### Security
No weakening. Token is still requested, stored/verified server-side before sensitive operations, and failure remains recoverable. Offline / unconfigured builds continue to work.

### Expected Metrics
| Metric              | Before                  | After                          |
|---------------------|-------------------------|--------------------------------|
| Cold-start time     | +0–8000 ms (integrity) | Critical path only (~hundreds ms) |
| Time-to-interactive | Higher on slow networks | Lower; integrity continues in background |
| Battery / Network   | Same total work         | Slightly better (no UI stall)  |

Instrumentation logs remain: `[DBA][BOOTSTRAP_PERF]`.

### Next candidates
- Expand baseline profile coverage for common user paths.
- Audit large `ListView`s / `GridView`s for `builder` + `cacheExtent` / `addAutomaticKeepAlives: false` where appropriate.
- WorkManager for any deferred pack downloads (offline-first remains primary).
