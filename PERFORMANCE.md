# Performance Optimizations — Deutsch بالعربي

## 2026-10-28: Dashboard Const Optimization and Architecture Review Kickoff

### Issue
DashboardScreen builds many widgets; missing const on some can cause unnecessary rebuilds. Combined with recent deferred imports, further micro-optimizations help cold start and frame times.

### Change
- Added const to more widgets in DashboardScreen (Text styles, SizedBox where possible).
- Updated this log with prioritized architecture improvement plan for future runs.
- No functional, security, or data changes. Offline-first and Play Integrity path unchanged.

### Expected Metrics
| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| Widget rebuilds on dashboard | Higher | Lower (const) | Reduced rebuild cost |
| Development velocity | Mixed structure | Clearer plan | Faster future features |

### Prioritized Action Plan for Continuous Improvement
1. **Modularization (High)**: Consolidate lib/screens, lib/modules into pure lib/features/<feature>/{data,domain,presentation}. Move DashboardScreen into features/dashboard/presentation/.
2. **Clean Architecture + MVVM (High)**: Enforce domain use-cases, repositories as interfaces, ViewModels (Riverpod Notifiers) for each feature. Current Riverpod is good start.
3. **Dependency Injection (Medium)**: Expand Riverpod providers for all services; avoid direct SharedPreferences outside ports (as per SYSTEM_RULES).
4. **Testing (High)**: Add unit tests for domain, widget tests for presentation, integration for offline flows. Target 70%+ coverage on core.
5. **CI/CD for Google Play (Medium)**: Consolidate the many workflows into a focused set: lint, test, build AAB, sign with secure secrets, upload to Play (internal track). Keep security audits.
6. **Performance (Ongoing)**: Full Baseline Profile via Macrobenchmark, more isolates for heavy JSON, lazy feature loading, R8 full mode.
7. **Security (Always)**: Maintain obfuscation, Play Integrity, no log leaks of user data, secure storage for any keys.

Security note: All changes preserve offline-first, no new permissions, no data exposure in logs or crashes.

---

## 2026-10-28: Deferred Imports for Dashboard Feature Screens (Startup Time)

### Issue
`CurriculumHubScreen` loaded up to 50 life missions into a `ListView.separated` with default settings. `addAutomaticKeepAlives` defaults to `true`, retaining off-screen item state. On longer lists this increases peak memory and can contribute to scroll jank on lower-end devices.

### Change
- Set `cacheExtent: 300` to bound the pre-build area beyond the viewport.
- Set `addAutomaticKeepAlives: false` because items are pure `AppBaseGlassCard` / `ListTile` widgets with no persistent state that must survive scrolling off-screen.
- Also resolved a lingering merge-conflict marker in the JSON asset loading path (no behavioral change).
- No change to data loading, filtering, or navigation behavior.

### Security
No impact. UI-only rendering optimization; no storage, network, integrity, or permission paths modified.

### Expected Metrics
| Metric                   | Before                              | After                                      |
|--------------------------|-------------------------------------|--------------------------------------------|
| Peak memory (50 missions)| Higher (keep-alives retained)       | ~10-20% lower on lists of 30+ items       |
| Scroll jank / frame time | Potential spikes on low-end devices | Smoother scrolling; less retained work     |
| Battery                  | Slightly higher during long scrolls | Marginally better                          |

Measurable via Flutter DevTools (Memory tab / Timeline) or `flutter run --profile`. Impact scales with the number of missions displayed.

### Next candidates
- Apply the same pattern to any remaining dynamic lists (e.g. language manager, achievements).
- Generate a real Baseline Profile via Macrobenchmark covering onboarding → dashboard → curriculum → hub path for cold-start gains (profileinstaller already present).
- Evaluate WorkManager only for future non-critical background pack verification (offline-first remains the primary path).

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

## 2026-10-30: Efficient ListView in WeakWordsReviewScreen (Memory & UI Jank)

### Issue
`WeakWordsReviewScreen` used `ListView.separated` with default settings. `addAutomaticKeepAlives` defaults to `true`. As the weak-words list grows (user reviews more failed vocabulary), off-screen items retain unnecessary state, increasing memory pressure and risking scroll jank on lower-end devices.

### Change
- Set `cacheExtent: 300` to limit the pre-build area beyond the viewport.
- Set `addAutomaticKeepAlives: false` — items are pure `StatelessWidget`s (`AppBaseGlassCard` rows) with no persistent state that must survive scrolling off-screen.
- No change to data, filtering, or navigation behavior.

### Security
No impact. UI-only rendering optimization; no storage, network, integrity, or permission paths modified.

### Expected Metrics
| Metric                   | Before                              | After                                      |
|--------------------------|-------------------------------------|--------------------------------------------|
| Peak memory (long list)  | Higher (keep-alives retained)       | ~10-20% lower on lists of 20+ weak words  |
| Scroll jank / frame time | Potential spikes when list grows    | Smoother scrolling; less retained work     |
| Battery                  | Slightly higher during long scrolls | Marginally better                          |

Measurable via Flutter DevTools (Memory tab / Timeline) or `flutter run --profile`. Impact scales with the number of weak words retained by the user.

### Next candidates
- Apply identical pattern to remaining dynamic lists: `grammar_guide_screen.dart`, `curriculum_hub_screen.dart`, `achievements_screen.dart`, etc.
- Generate Baseline Profile with Macrobenchmark covering onboarding → dashboard → curriculum → weak-words path for cold-start gains (profileinstaller already present).
- Evaluate WorkManager only for future non-critical background pack verification (offline-first remains the primary path).
