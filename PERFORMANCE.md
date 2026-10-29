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

## 2026-10-29: Efficient ListView in CurriculumUnitsScreen (Memory & UI Jank)

### Issue
`CurriculumUnitsScreen` used `ListView.separated` with default settings. `addAutomaticKeepAlives` defaults to `true`, causing off-screen items to retain state unnecessarily. For curricula that grow (dozens of units), this increases memory pressure and can contribute to scroll jank.

### Change
- Set `cacheExtent: 300` to bound the pre-build area beyond the viewport.
- Set `addAutomaticKeepAlives: false` because all items are pure `StatelessWidget`s with no persistent state that needs preservation.
- Applied only where safe; no behavioral change for users.

### Security
No impact. Pure UI rendering change; no data, network, or integrity paths touched.

### Expected Metrics
| Metric              | Before                          | After                                   |
|---------------------|---------------------------------|-----------------------------------------|
| Peak memory (long list) | Higher (keep-alives retained)  | ~10-25% lower on lists of 30+ items    |
| Scroll jank / frame time | Potential spikes on low-end    | Smoother; less work during scroll      |
| Battery             | Slightly higher during scroll  | Marginally better                       |

Measurable via Flutter DevTools memory timeline or `flutter run --profile` + Timeline. Scales with curriculum size.

### Next candidates
- Apply the same pattern to other dynamic `ListView.builder` / `separated` screens (curriculum hub, weak words, grammar guides, etc.).
- Generate a real baseline profile via Macrobenchmark for cold-start gains.
- Introduce WorkManager for any future background pack sync (while keeping offline-first).
