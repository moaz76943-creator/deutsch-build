# V299 — Model Boundary Reconciliation

## Decision

Separate learner-owned history models from static content and ephemeral assessment models.

- `ContentItem` remains the static content model only.
- `Attempt` and `AssessmentHistory` belong to learner state/history and are defined in `models/learner.dart`.
- `assessment.dart` contains runtime assessment question/response/result models plus content lookup helpers only.
- The duplicate lightweight `MasteryEvidence` model previously living in `content.dart` is removed; canonical mastery evidence remains in `services/mastery.dart`.

## Compatibility

No business behavior or persisted JSON keys were intentionally changed. Existing persistence normalizers continue to operate against the same model fields.

## Verification

- Model-boundary tests: PASS
- Full Python regression: PASS (382 tests)
- Flutter/Android build not executed because Flutter/Gradle are unavailable in the current environment.
