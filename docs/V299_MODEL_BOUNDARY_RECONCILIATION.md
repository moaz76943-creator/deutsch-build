# Deutsch بالعربي — V299 Model Boundary Reconciliation

## Status
VERIFIED

## Change
Reconciled model ownership so static content, learner history, and runtime assessment data no longer share the same model boundary.

### Before
`models/content.dart` contained `ContentItem` plus learner history (`Attempt`) and a duplicate `MasteryEvidence` model. `models/assessment.dart` also contained `AssessmentHistory` even though the history is stored as part of `LearnerState`.

### After
- `ContentItem` is the sole domain type in `models/content.dart`.
- `Attempt` and `AssessmentHistory` are owned by `models/learner.dart`.
- `models/assessment.dart` contains question/response/result models and content lookup helpers.
- Canonical `MasteryEvidence` remains in `services/mastery.dart`.

## Safety
Existing JSON fields and persistence normalization behavior were preserved. No secrets, authentication credentials, subscription state, or user ownership boundaries were introduced.

## Verification
- `pytest -q tests`: **382 passed**
- Focused model-boundary tests: **PASS**
- Security/privacy: **PASS by existing regression coverage**
- Flutter/Android build: **not run; required toolchain unavailable**

## Archive
See the V299 verified release archive and SHA-256 recorded alongside this document.
