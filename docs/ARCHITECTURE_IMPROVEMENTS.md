# Architecture Improvements for Deutsch بالعربي

## Current State Review
- Flutter offline-first app using Riverpod, sqflite, SharedPreferences.
- Feature folders exist but mixed with top-level screens/, providers/, services/.
- Complex bootstrap pipeline in main.dart for resilience and integrity (good for security).
- Recent performance wins on ListViews (cacheExtent + addAutomaticKeepAlives: false).
- Many GitHub Actions workflows; some disabled. High automation but potential complexity.
- Security focus: offline-first, integrity checks, secure storage.

## Key Principles for Speed, Quality, Ease of Development
1. **Feature-first modularization** (not layer-first at top level) — reduces merge conflicts, speeds onboarding.
2. **Clean Architecture + MVVM** with Riverpod:
   - Domain: pure Dart entities, use cases, repository interfaces.
   - Data: implementations, local sources.
   - Presentation: ViewModels (Notifiers), UI (widgets).
3. **Dependency Injection**: Riverpod providers with overrideWith for testability. Avoid globals.
4. **Unidirectional Data Flow**: state down, events up.
5. **Performance**: const widgets, ListView.builder + cacheExtent + !keepAlives for pure items, compute() for heavy work, baseline profiles.
6. **Testing**: unit for domain/use cases, widget for UI, golden where visual contracts matter. CI gates on coverage/lint.
7. **CI/CD**: simplify workflows, use fastlane or codemagic for Play releases (already have codemagic.yaml), signed AAB, staged rollouts.
8. **Security**: keep integrity deferred, no sensitive data in logs, use flutter_secure_storage, ProGuard/R8, no data leaks in error widgets.

## Prioritized Action Plan (Continuous Improvement)
### P0 - Immediate (this run + next)
- [x] Document architecture (this file).
- [ ] Resolve any remaining merge conflicts in screens.
- [ ] Apply ListView opts to all dynamic lists.
- [ ] Introduce feature module template.

### P1 - Short term (1-2 weeks)
- Refactor one feature (e.g. onboarding or flashcards) to full Clean + Riverpod Notifier.
- Add go_router for declarative navigation + deep links.
- Set up Melos for future multi-package if needed.
- Expand unit tests for core engines (SRS, etc.).

### P2 - Medium
- Full modularization: move screens into features/*/presentation.
- Baseline profile generation via Macrobenchmark.
- CI: reduce workflow count, add architecture lint (custom_lint already present).
- Play release pipeline hardening (versioning, changelog, privacy).

### P3 - Ongoing
- Performance profiling sessions.
- Security audits (tamper resistance, data leak prevention).
- Developer experience: Makefile targets, hot-reload friendly structure.

## Concrete Example: Feature Module Structure (implemented as template)
See `lib/features/_scaffold/README.md` for the pattern to copy.

This makes adding new features fast and consistent, improves testability, and keeps security boundaries clear (domain has no Flutter deps).
