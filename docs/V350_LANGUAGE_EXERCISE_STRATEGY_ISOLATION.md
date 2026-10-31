# V350 — Language Exercise Strategy Isolation

**Baseline:** V349 — German Content Namespace Migration

## Change

Assessment, production, repair, and conversation services no longer own German-specific prompts, expected-language wording, or scenario data. They consume the neutral `LanguageExerciseStrategy` contract. The German implementation lives in `lib/language/german/german_language_exercise_strategy.dart` and is selected through `LanguagePack` at the Composition Root.

## Preserved behavior

- SRS and Mastery algorithms unchanged.
- Assessment scoring/selection behavior unchanged; question construction is delegated.
- Production mode selection and answer matching unchanged; localized task construction is delegated.
- Repair flow selection remains deterministic; localized repair drills are delegated.
- Conversation scoring algorithm unchanged; scenario corpus is delegated.
- Content values, IDs, persistence semantics, authentication, subscription semantics, and search ranking are unchanged.

## Verification

- Focused V350 contract tests: PASS.
- Full pytest regression: 511 passed.
- Flutter/Dart analyze and APK build: not run because Flutter/Dart is unavailable in the execution environment.

## Architecture

```text
Composition Root
  ↓
LanguagePack
  ↓
LanguageExerciseStrategy
  ├── Assessment prompts
  ├── Production tasks
  ├── Repair drills
  └── Conversation scenarios
  ↓
Language-neutral exercise engines
```
