# V352 — Real-World Learning Presentation Split

## Scope

V352 continues the staged language-aware presentation split started in V351. The bounded surface is the real-world learning page.

## Changes

- Added `RealWorldLearningPresentation` and `RealWorldScenario` to the language presentation contract.
- Moved the real-world German scenario dataset and learning-specific labels into `GermanRealWorldLearningPresentation`.
- Kept the existing `GermanyRealityPage` and `RealityPractice` public widget names for compatibility while making their content dependency explicit through `LanguagePresentation`.
- Composition Root now passes the selected language presentation to the real-world learning surface.
- No SRS, Mastery, learner-state, authentication, subscription, security, or content-ID behavior was changed.

## Verification

Focused V352 architecture tests must pass before the full regression suite. Flutter/Dart analysis and APK build are not claimed when the toolchain is unavailable.
