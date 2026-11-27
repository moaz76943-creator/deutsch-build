# Architecture Improvement Roadmap for Deutsch بالعربي

## Goal
Make development **fast, wonderful, and very easy** while maximizing speed, quality, security, and maintainability. Offline-first, privacy-focused, tamper-resistant.

## Current State (as of 2026-11-28)
- Flutter + Riverpod + sqflite + secure storage
- Complex `lib/core/` with agents, audio, caches, bootstrap
- Performance tunings already applied (ImageCache, ListView.builder + RepaintBoundary, lazy channels)
- Many GitHub Actions workflows (build AAB, performance guards, etc.)
- 437+ open issues — architectural debt and maintenance friction
- Feature structure mixed (`ui_v35`, partial `features/`)

## Prioritized Action Plan

### 1. Modularization & Feature-First Structure (Highest Priority — this run)
**Why:** Biggest win for development speed and ease. Isolate features so teams/AI can work independently, reduce cognitive load, enable parallel development and easier testing.

**Target structure:**
```
lib/
├── app/                  # MaterialApp, routing, theme, providers
├── core/                 # Shared utilities, design system, error types, security
├── features/
│   ├── onboarding/
│   ├── vocabulary/
│   ├── grammar/
│   ├── srs/
│   └── progress/
└── main.dart
```

Each feature:
```
features/vocabulary/
├── presentation/
│   ├── pages/
│   ├── widgets/
│   └── providers/     # Riverpod
├── domain/
│   ├── entities/
│   ├── repositories/  # abstract
│   └── usecases/
└── data/
    ├── datasources/
    ├── models/
    └── repositories/  # impl
```

**Concrete example (Vocabulary):**
See sample code below in the next section. Migrate one feature at a time starting with onboarding or vocabulary.

### 2. Clean Architecture Layers (Presentation → Domain ← Data)
- Domain has zero Flutter/Android dependencies.
- Unidirectional data flow.
- Use cases for business logic.
- Repository pattern (already partially used).

### 3. Dependency Injection with Riverpod
Already using `flutter_riverpod`. Standardize:
- Provider for repositories and use cases.
- `ref.watch` / `ref.read` in presentation.
- Override in tests.

### 4. Testing Strategy
- **Unit:** Domain use cases + repositories (mock datasources).
- **Widget:** Presentation with Riverpod overrides.
- **Integration:** Golden paths (onboarding → vocabulary → SRS).
- Target 70%+ coverage on domain.
- Use `flutter_test` + `mocktail`.

### 5. CI/CD for Google Play
- Existing `build_aab.yml` is good start.
- Add Fastlane or Google Play API upload step.
- Automated versioning (pubspec + git tags).
- Security: sign with Play App Signing, R8 full mode (already), ProGuard rules for sensitive code.
- Post-release: crash reporting (Sentry/Firebase optional, privacy-preserving).

### 6. Performance Optimizations
Continue current approach (lazy loading, ListView.builder + cacheExtent + RepaintBoundary, ImageCache limits, isolate for heavy work).
Next: baseline profiles (already mentioned), deferred components, const constructors everywhere.

### 7. Security Hardening (maintain/enhance)
- Keep offline-first, no unnecessary INTERNET permission.
- `flutter_secure_storage` for keys/tokens.
- Integrity checks / SafetyNet / Play Integrity API for tamper detection.
- R8 + minify + shrink.
- No logging of PII or content.
- Crash-loop guard (already present).
- Encrypt local DBs if sensitive (sqflite_sqlcipher already in deps).

## Concrete Refactoring Example: Vocabulary Feature (Key Optimization This Run)

**Before (typical):** Direct SharedPreferences / sqflite access in UI or giant core files.

**After:**

```dart
// features/vocabulary/domain/entities/vocabulary_item.dart
class VocabularyItem {
  final String id;
  final String german;
  final String arabic;
  final String? audioPath;
  const VocabularyItem({required this.id, required this.german, required this.arabic, this.audioPath});
}

// features/vocabulary/domain/repositories/vocabulary_repository.dart
abstract class VocabularyRepository {
  Future<List<VocabularyItem>> getItems({String? packId});
  Future<void> markKnown(String id);
}

// features/vocabulary/data/repositories/vocabulary_repository_impl.dart
class VocabularyRepositoryImpl implements VocabularyRepository {
  final LocalVocabularyDataSource local;
  VocabularyRepositoryImpl(this.local);
  @override
  Future<List<VocabularyItem>> getItems({String? packId}) => local.fetch(packId);
  // ...
}

// features/vocabulary/presentation/providers/vocabulary_providers.dart
final vocabularyRepositoryProvider = Provider<VocabularyRepository>((ref) {
  return VocabularyRepositoryImpl(LocalVocabularyDataSource(ref.read(databaseProvider)));
});

final vocabularyItemsProvider = FutureProvider<List<VocabularyItem>>((ref) {
  return ref.watch(vocabularyRepositoryProvider).getItems();
});

// In UI (ConsumerWidget):
final itemsAsync = ref.watch(vocabularyItemsProvider);
itemsAsync.when(
  data: (items) => ListView.builder(
    itemCount: items.length,
    itemBuilder: (context, i) => RepaintBoundary(
      child: VocabularyCard(item: items[i]),
    ),
  ),
  loading: () => const CircularProgressIndicator(),
  error: (e, _) => Text('Error: $e'),
);
```

This pattern:
- Makes the feature independently testable and developable.
- Keeps UI thin.
- Domain is pure Dart → easy unit tests.
- Security preserved (data layer owns storage/encryption).

## Next Steps (Continuous Improvement)
1. Create the `features/vocabulary/` skeleton and migrate one screen (this run's deliverable).
2. Add unit tests for the new domain.
3. Update CI to run `flutter test` on PRs.
4. Document the pattern in AGENTS.md for AI-assisted development.
5. Gradually migrate other features (grammar, SRS, progress).
6. Add Play Store upload automation.

**Security note:** All changes must preserve offline-first, no new network permissions without explicit review, and keep secure storage + integrity checks intact.

Development becomes fast and wonderful when features are self-contained, logic is pure, and the feedback loop (edit → test → run) is under 10 seconds.
