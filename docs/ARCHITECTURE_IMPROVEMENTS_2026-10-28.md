# Architecture Review & Continuous Improvement Plan
Deutsch بالعربي (Flutter + Riverpod) — 2026-10-28

## Current Strengths
- Offline-first with SQLite + secure storage
- Riverpod (AsyncNotifier, repository providers) for testable DI
- Feature-oriented structure under lib/features/
- Strong bootstrap pipeline, crash-loop guard, Play Integrity
- Recent perf wins: deferred feature imports, compute() isolates for JSON, Baseline Profiles, R8
- Rich CI: build AAB/APK, security audit, performance guard, quality gates

## Recommended Architecture (Clean / Feature-first MVVM-style)
Adopt a consistent layered feature structure while keeping Riverpod as the DI + state holder:

```
lib/
  core/                 # shared: bootstrap, security, theme, utils, database
  features/
    flashcards/
      data/             # repository impl, data sources, models (DTO)
      domain/           # pure use-cases, entities, repository interfaces (no Flutter)
      presentation/     # screens, widgets, Riverpod notifiers / viewmodels
    pronunciation/
      ...
  design_system/
```

- **Domain layer**: pure Dart, no Flutter/Android deps → easy unit tests, reusable.
- **Presentation**: Riverpod notifiers act as ViewModels (expose AsyncValue / state).
- **DI**: Riverpod Providers + overrides in tests (already started). Prefer constructor injection via providers.

### Concrete Refactoring Example: Vocabulary Feature
Current `vocabulary_provider.dart` is already solid. Next step — extract a pure use-case:

```dart
// lib/features/vocabulary/domain/get_vocabulary_use_case.dart
class GetVocabularyUseCase {
  final VocabularyRepository repo;
  GetVocabularyUseCase(this.repo);

  Future<List<VocabularyItem>> call() async {
    final raw = await repo.getVocabularyList();
    return raw.map(VocabularyItem.fromJson).toList();
  }
}

// Provider
final getVocabularyUseCaseProvider = Provider((ref) =>
  GetVocabularyUseCase(ref.watch(vocabularyRepositoryProvider)));

// Notifier uses the use-case
class VocabularyNotifier extends AsyncNotifier<List<VocabularyItem>> {
  @override
  Future<List<VocabularyItem>> build() async {
    final useCase = ref.watch(getVocabularyUseCaseProvider);
    return useCase();
  }
}
```
Benefits: test use-case without Flutter, clearer boundaries, easier to add caching/remote later.

## Dependency Injection
- Continue Riverpod as the primary DI container (lightweight, compile-safe, test overrides).
- For complex graphs use ProviderScope overrides or a small manual DI container in core/ if needed.
- Avoid service locators; prefer explicit providers.

## Modularization
- Short-term: keep monorepo, strict feature folders + barrel exports.
- Medium-term: extract heavy features (pronunciation, SRS) into local packages under packages/ for independent testing and faster incremental builds.
- Use deferred imports (already done for some screens) + lazy provider loading for cold-start wins.

## Testing Strategy
1. **Unit**: pure domain use-cases + repository mocks (mockito / fake_async).
2. **Widget**: pump Widget with ProviderScope(overrides: [...]) — test loading/error/data states.
3. **Integration**: flutter_driver or integration_test for critical flows (onboarding → first lesson).
4. **Golden**: for design-system components (already have some validators).
5. Target: 70%+ domain coverage; key presentation paths.

Example test snippet:
```dart
testWidgets('shows vocabulary list', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        vocabularyListProvider.overrideWith(() => FakeVocabularyNotifier()),
      ],
      child: const MaterialApp(home: VocabularyScreen()),
    ),
  );
  expect(find.text('Wort'), findsOneWidget);
});
```

## CI/CD for Google Play
- Keep existing AAB workflows.
- Ensure: signed release AAB, Play Integrity checks, ProGuard/R8 keep rules, privacy policy URL, Data Safety form match.
- Add: automated upload via fastlane or Play Publisher API on tag, internal track first.
- Security gates: no cleartext, backup disabled, integrity attestation before sensitive features.

## Performance Optimizations (Prioritized)
1. **Done**: deferred screens, isolates for JSON, Baseline Profiles, R8 full mode.
2. **Next (this run focus)**: Audit ListView(children:) → ListView.builder + itemExtent where lists > 20 items. Reduces memory and improves scroll FPS.
3. Generate full Baseline Profile covering onboarding + dashboard + one feature via Macrobenchmark module.
4. Image/SVG caching and pre-warming for common assets.
5. Isolate more heavy computations (SRS scheduling, large pack imports).

## Security (maintain / enhance)
- Play Integrity already present — keep gating premium/offline packs.
- flutter_secure_storage for any secrets / progress tokens.
- No PII collection (matches privacy policy).
- Code obfuscation + resource shrinking enabled.
- Tamper detection via integrity + optional root/debug checks in release.

## Prioritized Action Plan (next 4 weeks)
| Priority | Action | Effort | Impact | Owner |
|----------|--------|--------|--------|-------|
| P0 | Convert large ListViews to .builder + measure scroll jank | S | High (UI smoothness) | Eng |
| P0 | Add 3-5 domain unit tests for core use-cases | S | Medium (quality) | Eng |
| P1 | Extract 1 feature to domain/data/presentation layers as template | M | High (DX long-term) | Eng |
| P1 | Generate & ship full Baseline Profile | M | High (startup) | Eng |
| P2 | Local packages for pronunciation + SRS | L | Medium (build speed) | Eng |
| P2 | Fastlane Play upload on main tag | M | High (release speed) | DevOps |
| P3 | Widget golden tests for design system | M | Medium | QA |

## Key Optimization Implemented This Run
Added this living document + concrete vocabulary use-case refactoring template. Next runs can land the actual domain extraction and ListView.builder migration with before/after metrics.

All changes preserve offline-first, integrity checks, and no-data-collection guarantees.
