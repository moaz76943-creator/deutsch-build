# Performance Analysis — Deutsch بالعربي (Flutter/Android)

## Summary (2026-11-15)
Offline-first German learning app. Strong baseline already in place:
- R8 minify + shrinkResources + optimization passes
- Baseline Profiles (profileinstaller 1.4.1) + baseline-prof.txt covering startup, rendering, lists
- ImageCache tuned, memory-pressure trim + full clear, limited asset bundling
- No INTERNET permission (battery + privacy win)
- Presentation performance guard in CI

## Areas Reviewed
| Area | Status | Notes |
|------|--------|-------|
| Startup (TTID/TTFD) | Good | Baseline profiles, minimal bootstrap pipeline, App Startup-style isolation |
| Memory | Improved | ImageCache + L1 trim + full ImageCache clear on pressure; further tightened below |
| Battery | Good | Offline-only, no background network, WorkManager not needed |
| Network | Excellent | Permissions stripped; zero runtime network |
| UI jank | Improved | ListView.builder + RepaintBoundary on dashboard, curriculum hub, grammar guide, articles matrix, achievements, vocabulary journal, offline dictionary, language select, emergency phrasebook, phonetics lab, scenario chat, daily challenges, smart error review, and theme switcher; CI guard against blocking build() |

## Concrete Improvement (this run — 2026-11-15)
**Added RepaintBoundary + cacheExtent: 300 + addAutomaticKeepAlives: false around ThemeSwitcherScreen ListView.builder items** in `lib/screens/theme_switcher_screen.dart`:
- Before: plain `itemBuilder` returning Container > AppBaseGlassCard with color circles and text (potential overpaint on glass cards if list grows)
- After: each item wrapped in `RepaintBoundary`; cacheExtent: 300; addAutomaticKeepAlives: false

**Expected measurable impact** (device-dependent, mid-range phones):
- Reduced overpainting / fewer skipped frames when scrolling theme options
- Smoother interactions on lists with nested glass cards (colored circles, text)
- Modest reduction in GPU work and memory pressure from unnecessary repaints and keep-alives
- Better consistency with other optimized list screens (home, curriculum, grammar, articles, achievements, vocabulary journal, offline dictionary, language select, emergency phrasebook, phonetics lab, scenario chat, daily challenges, smart error review)

Previous runs optimized HomeScreen, CurriculumHubScreen, GrammarGuideScreen, ArticlesMatrixScreen, AchievementsScreen, VocabularyJournalScreen, OfflineDictionaryScreen, LanguageSelectScreen, EmergencyPhrasebookScreen, PhoneticsLabScreen, ScenarioChatScreen, DailyChallengesScreen, and SmartErrorReviewScreen ListViews with RepaintBoundary + cacheExtent/addAutomaticKeepAlives, ImageCache limits, and JSON compute isolation.

No security regression (no keep-rule changes, offline integrity preserved, no new permissions).

## Recommendations for next runs
1. Generate full Baseline + Startup Profiles via Macrobenchmark (startup + first list scroll).
2. Prefer `ListView.builder` / `Sliver` + `cacheExtent` for any dynamic long lists.
3. Keep R8 full mode; audit keep rules periodically.
4. Profile with Android Studio / Perfetto on a low-end device.
5. Consider wrapping remaining complex card lists (flashcards decks, other journals, curriculum units if long) with RepaintBoundary if frame drops are observed.
6. Explore feature modularization (packages or feature modules) to improve incremental builds and ease of development as the codebase grows.

Metrics should be captured with `flutter run --profile` + Macrobenchmark or Android Vitals after next release.
