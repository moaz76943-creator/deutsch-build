# Deutsch بالعربي — V348

V348 introduces the first explicit language-pack boundary at the Composition Root. The application now selects `GermanLanguagePack` as build configuration while preserving the existing German corpus, learning behavior, and shared core boundaries.

## Preserved

- Content IDs and corpus data
- SRS and Mastery behavior
- LearningCore language-neutral contract
- Search algorithm
- Learner state
- Authentication and subscription boundaries

## Verification

- 497 pytest tests passed.
- Flutter/Dart checks were not run because the toolchain is unavailable in this execution environment.
