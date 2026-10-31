# V84 — Deep Quality Review

## Scope
Deep pass over content quality, learning state persistence, review scheduling, release metadata, accessibility-oriented UI foundations, and test coverage. Existing features and content are preserved.

## Content corrections
- Corrected obvious Arabic dictionary-form artifacts in generated entries (e.g. يؤكد/يشرح/يوصل/يتجنب).
- Corrected the malformed German sentence for `zusagen` to `Ich sage heute zu.`.
- Removed accidental `neu` labels from learner-facing German phrases.
- Corrected demonstrative agreement for simple `Das ist ...` examples based on der/die/das.

## Learning/review
- Attempt history is capped at the latest 2,000 attempts to prevent unbounded local storage growth.
- Daily streak now updates from calendar-day transitions.
- SRS uses a conservative explicit interval curve while retaining the existing public API.

## Quality gates
- Added duplicate-ID validation.
- Added empty accepted-answer validation.
- Kept duplicate-German detection and first-person Arabic checks.
- Corrected the release metadata/version mismatch.

## Verification
- Static content count and duplicate checks run locally with Python.
- ZIP integrity check run after packaging.
- Flutter/Dart build/test remain unverified if the environment does not provide Flutter SDK.
