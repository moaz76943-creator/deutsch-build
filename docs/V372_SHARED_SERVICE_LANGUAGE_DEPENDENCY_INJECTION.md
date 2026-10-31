# V372 — Shared Service Language Dependency Injection

## Scope

V372 removes direct use of the legacy language normalizer and German quality facade from the selected shared-service hot paths. The migration is dependency-injected from the selected `LanguagePack` and preserves the existing learning behavior and canonical content.

## Migrated boundaries

- `SearchIndex` now consumes `LanguageTextNormalizer` explicitly.
- `WordProfileService` now consumes `LanguageTextNormalizer` and reads neutral `LearningContent` projections for source/example text.
- `ReadingPractice` now consumes `LanguageContentQuality` and reads neutral source/example projections.
- `LearningEngine.buildPlan` now consumes `LanguageContentQuality` and passes it to `VocabularyCoach` and `ProductionEngine` instead of using the German compatibility facade.
- `VocabularyCoach` now consumes `LanguageContentQuality` and uses `sourceText` instead of the legacy `german` field.
- `CoreSession` and relevant shared UI callers receive language normalization and quality dependencies from the Composition Root.
- `LegacySearchIndex` remains a compatibility boundary and explicitly supplies `GermanTextNormalizer`; it is not a shared-service dependency.

## Regression behavior

The canonical corpus was not mutated:

- Content items: 14,813
- Verb rows: 11,718
- Unique content IDs: 14,813
- Audio entries: 0

## Verification

- Focused V372 tests: PASS
- Full pytest regression: 606 passed
- Content validation: PASS
- Audio validation: PASS
- Compiler: PASS
- Compiler parity: PASS
- Security audit: PASS
- Privacy audit: PASS
- Accessibility audit: PASS, 0 warnings
- Architecture audit: PASS
- Quality audit: PASS
- Weakness gate: PASS, mutation NONE
- Python compileall: PASS

Flutter/Dart tooling is not installed in the execution environment, so no Flutter build or `flutter analyze` result is claimed.

## Remaining language-specific service boundaries

The audit intentionally does not classify every language-sensitive service as generic merely to reduce the finding count. `ContentIntelligence`, `VerbIndex`, `ConversationEngine`, `WritingAnalyzer`, and `ProductionEngine` still contain language-specific behavior or legacy normalization dependencies and remain candidates for subsequent focused migrations. Those should be moved only when their contracts can preserve the current behavior without introducing a false abstraction.
