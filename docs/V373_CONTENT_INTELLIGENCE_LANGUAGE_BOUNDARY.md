# V373 — Content Intelligence Language Boundary

## Goal

Move language-specific content-intelligence heuristics out of the shared service layer while preserving the existing report model and learning behavior.

## Boundary

- `LanguageContentIntelligence` is the language-owned contract.
- `GermanContentIntelligence` owns German lexical normalization, lexical-class heuristics, word-family heuristics, curriculum inference, near-duplicate detection, and German-oriented gap recommendations.
- `ContentProfile`, `ContentIntelligenceReport`, `CurriculumGap`, and `ContentLevel` are neutral result models exposed from the language contract so shared consumers do not need a German implementation.
- `ContentIntelligence` remains only as an instance facade around an injected `LanguageContentIntelligence` implementation.
- `LearningIntelligence`, `LearningEngine`, and `MasteryDashboard` receive `LanguageContentIntelligence` explicitly.
- UI callers obtain the selected implementation from `LanguagePack` at the Composition Root boundary.

## Compatibility

No canonical content, IDs, SRS state, mastery state, or audio assets are mutated. The compatibility service no longer contains German heuristics or imports a German implementation.

## Verification

- V373 focused tests: PASS
- Full pytest regression: PASS
- Content validation: PASS
- Audio validation: PASS
- Compiler: PASS
- Compiler parity: PASS
- Security: PASS
- Privacy: PASS
- Accessibility: PASS
- Architecture: PASS
- Quality: PASS
- Weakness Gate: PASS
- Final language-ready gate: intentionally reports remaining findings for subsequent migrations; it is not yet the completion gate.

Flutter/Dart tooling is not installed in the execution environment, so no Flutter build or `flutter analyze` result is claimed.
