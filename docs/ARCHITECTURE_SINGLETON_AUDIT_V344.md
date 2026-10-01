# Global Singleton Audit — V344

## Scope

All `.instance` references under `lib/` were inspected. This document classifies each current reference and prevents accidental reintroduction of hidden global coupling.

| Location | Reference | Classification | Decision |
|---|---|---|---|
| `lib/main.dart` | `PreferencesService.instance` | COMPOSITION_ROOT | Allowed. Storage gateway is initialized at the composition boundary before repository creation. Future injection may replace it if multiple storage implementations are introduced. |
| `lib/main.dart` | `UserVocabularyService.instance` | STORAGE_GATEWAY | Allowed. SQLite persistence for user vocabulary initialized at composition root. |
| `lib/main.dart` | `FavoritesRepository.instance` | STORAGE_GATEWAY | Allowed. SQLite persistence for vocabulary favorites initialized at composition root. |
| `lib/main.dart` | `DynamicUiVariationsEngine.instance` | STORAGE_GATEWAY | Allowed. SQLite persistence for daily UI variation tracking at composition root. |
| `lib/services/dynamic_ui_variations.dart` | `DynamicUiVariationsEngine.instance` | STORAGE_GATEWAY | Allowed. Internal database instantiation within service. |
| `lib/services/user_vocabulary_service.dart` | `UserVocabularyService.instance` | STORAGE_GATEWAY | Allowed. Internal database instantiation within service. |
| `lib/services/user_vocabulary_service.dart` | `FavoritesRepository.instance` | STORAGE_GATEWAY | Allowed. Internal singleton pattern within service. |
| `lib/main.dart` | `ContentEngine.instance` | COMPOSITION_ROOT | Allowed. Canonical content is materialized once into the explicit immutable corpus dependency. |
| `lib/main.dart` | `VerbIndex.instance` | COMPOSITION_ROOT | Allowed. Canonical verb index is created once and injected. |
| `lib/services/privacy_settings.dart` | `PreferencesService.instance` | MIGRATION_CANDIDATE | Hidden storage dependency inside a service. Safe next migration target: inject the storage gateway explicitly without changing persistence semantics. |
| `lib/services/search_index_legacy.dart` | `ContentEngine.instance` | LEGACY_COMPATIBILITY | Allowed only in compatibility facade. Must not spread to canonical search paths. |
| `lib/services/search_index_legacy.dart` | `VerbIndex.instance` | LEGACY_COMPATIBILITY | Allowed only in compatibility facade. Must not spread to canonical search paths. |
| `lib/ui/app.dart` | `PreferencesService.instance` | LEGACY_COMPATIBILITY | Legacy UI still owns a local repository boot path. Keep temporarily until legacy storage boundary migration is completed. |

## Rules

1. Core and `ui_v35` must contain zero `.instance` lookups.
2. Canonical services must not use content/index singletons as hidden fallbacks.
3. App-wide singleton creation is permitted only at the Composition Root or an explicitly documented compatibility facade.
4. Compatibility references must not be introduced into new code.
5. Any intentional global must be documented here before being retained.

## Next Migration Candidate

`PrivacySettings` should be migrated from `PreferencesService.instance()` to an explicitly supplied storage dependency. This is independent of content/search architecture and should be a separate TDD stage.


## V354 boundary update

The German content adapter now owns the language-specific singleton bindings introduced by the staged language content-pack boundary. This is intentional and keeps `main.dart` free of direct German content-source singleton lookups.

| `lib/language/german/german_content_pack.dart` | `ContentEngine.instance` | LANGUAGE_CONTENT_ADAPTER | Allowed. Binds the current German runtime content source behind `LanguageContentPack`. |
| `lib/language/german/german_content_pack.dart` | `VerbIndex.instance` | LANGUAGE_CONTENT_ADAPTER | Allowed. Binds the current German verb index behind `LanguageContentPack`. |
| `lib/services/streak_milestones_engine.dart` | `StreakMilestonesEngine.instance` | STORAGE_GATEWAY | Allowed. Storage gateway for sqflite offline milestone tracking. |
| `lib/ui_v35/progress_pages.dart` | `StreakMilestonesEngine.instance` | LEGACY_COMPATIBILITY | Required injection for milestone pages. |
| `lib/ui_v35/pages/silent_bubble_popper.dart` | `UserVocabularyService.instance` | COMPOSITION_ROOT | Expected temporary singleton injection during migration. |
