# V369 — UI Language Boundary Cleanup

## Goal

Remove direct use of the legacy German-shaped content fields from the shared learning UI and route target-language presentation labels through `LanguagePresentation`.

## Changes

- Shared UI content reads now use `LearningContent` projections:
  - `sourceText`
  - `translationText`
  - `exampleText`
  - `exampleTranslationText`
  - `grammaticalMarker`
  - `pluralForm`
  - `acceptedForms`
- `LanguagePresentation` now owns target-language UI labels needed by the shared content views:
  - target language name
  - pronunciation tooltip
  - grammatical-marker label
  - plural label
- `CoreSession`, `SingleItemSession`, vocabulary, category, dictionary, and legacy learning surfaces receive the selected presentation from the Composition Root rather than constructing a German presentation themselves.
- `LearnerRepository.record` remains unchanged in this stage; persisted learner-state behavior and IDs are not migrated here.

## Safety

No canonical content, learner state, SRS cards, mastery data, or IDs are rewritten by this stage.

## Explicit scope boundary

The German verb-conjugation screen remains a language-specific feature surface because its underlying verb model is still language-shaped. Other target-language copy outside the migrated shared content surfaces remains queued for the final architecture cleanup rather than being hidden behind a global singleton.

## Verification

- Full Python regression suite must pass.
- Content and audio validation must pass.
- Compiler/parity checks must pass.
- No Flutter build claim is made when the Flutter SDK is unavailable in the execution environment.
