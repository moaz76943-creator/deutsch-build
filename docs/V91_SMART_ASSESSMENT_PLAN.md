# V91 Smart Assessment Implementation Plan

**Goal:** Add an offline-first adaptive assessment system that diagnoses skills, records trustworthy test history, and feeds results into the existing V90 memory/review engine.

**Architecture:** Add a focused assessment domain (`assessment.dart`) and service (`assessment_engine.dart`) without replacing the existing learner repository. Tests are deterministic and generated from existing content; the UI consumes assessment results and uses existing local persistence/review mechanisms.

**Tech Stack:** Flutter/Dart, existing local learner model, SharedPreferences-backed repository, existing content catalog.

**Global Constraints:** No API keys; assessment works offline; preserve V90 compatibility; bounded persisted data; do not fabricate mastery from synthetic placement answers.

### Task 1: Assessment domain and engine
**Files:** Create `lib/models/assessment.dart`, `lib/services/assessment_engine.dart`; Test `test/v91_assessment_test.dart`.
- Define question types, question, result, skill score, and test history records.
- Build deterministic adaptive question selection from content and learner attempts.
- Score hints separately from correct answers.
- Produce per-skill accuracy, confidence, weak skills, and next-review IDs.

### Task 2: Persistence and integration
**Files:** Modify `lib/models/learner.dart`, `lib/services/repository.dart`, `lib/core/learning_core.dart`.
- Persist bounded assessment history.
- Keep backward-compatible JSON defaults.
- Expose assessment-driven next actions without breaking existing review cards.

### Task 3: UI
**Files:** Modify `lib/ui_v35/app.dart`.
- Add اختبار ذكي entry point, question flow, result summary, skill breakdown, and review-now action.
- Show history and trend locally.

### Task 4: Quality and release checks
**Files:** Modify `pubspec.yaml`, quality/security audits if required, add docs.
- Update version to 1.39.0+49.
- Run static audits, Python syntax/ZIP checks, and Flutter commands if available.
