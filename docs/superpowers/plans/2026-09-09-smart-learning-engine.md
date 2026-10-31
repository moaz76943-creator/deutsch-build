# Smart Learning Engine Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Turn the V91 assessment system into a connected offline-first learning engine that converts assessment and mistakes into a personalized daily path, reading practice, and visible skill progression.

**Architecture:** Add a pure local `LearningEngine` orchestration layer over the existing SRS, assessment, mistake, mastery, and content services. Persist only bounded learner-facing history/state locally; UI consumes deterministic snapshots and plans. Keep cloud AI optional and outside the core path.

**Tech Stack:** Flutter/Dart, SharedPreferences, existing local content/SRS/assessment services.

**Spec:** Approved V92–V98 direction from the conversation: personalized path, conversation/listening readiness, mistake coaching, interactive reading, skill levels, and long-term progress.

## Global Constraints

- Core learning must work offline.
- Existing security and content-quality audits must remain passing.
- No API keys or secrets in the APK.
- Persisted learner data remains bounded and treated as untrusted.
- Do not regress existing assessment/SRS behavior.

### Task 1: Learning engine and adaptive daily path
**Files:** `lib/services/learning_engine.dart`, `lib/models/learning_path.dart`, `test/v92_learning_engine_test.dart`, `lib/services/repository.dart`.
- [ ] Write failing tests for plan ordering: overdue review → weak-skill repair → targeted new content → listening/production balance.
- [ ] Verify focused tests fail for the missing engine contract.
- [ ] Implement `LearningEngine.buildPlan` and bounded `LearningPath` models.
- [ ] Integrate assessment weak skills and memory due cards without duplicating content selection logic.
- [ ] Rerun focused tests and existing learning tests.

### Task 2: Mistake coach, reading practice, and progression snapshot
**Files:** `lib/services/mistake_coach.dart`, `lib/services/reading_practice.dart`, `lib/models/progress_snapshot.dart`, `test/v92_coach_reading_test.dart`.
- [ ] Write failing tests for repeated-error coaching, level bands, and readable passages built only from valid content.
- [ ] Verify red state.
- [ ] Implement deterministic local coaching and reading extraction.
- [ ] Implement skill-level snapshot combining recent attempts, assessment history, and mastery evidence.
- [ ] Rerun focused tests and quality tests.

### Task 3: UI integration
**Files:** `lib/ui_v35/app.dart`, `lib/main.dart`, `test/v92_ui_contract_test.dart`.
- [ ] Write a lightweight source contract test for the new navigation labels and engine hooks.
- [ ] Implement home personalized-path card, progress page, mistake coach page, and reading practice page.
- [ ] Add a daily session entry point and keep existing pages accessible.
- [ ] Rerun focused tests.

### Task 4: Packaging, docs, audits
**Files:** `pubspec.yaml`, `docs/V92_SMART_LEARNING_ENGINE.md`, `tool/quality_audit.py`, `tool/security_audit.py` only if required, ZIP artifact.
- [ ] Update version to `1.40.0+50`.
- [ ] Add documentation and audit coverage for new local state/flows.
- [ ] Run Python audits, syntax checks, XML checks, ZIP integrity, and Flutter checks if SDK is available.
- [ ] Package `deutsch_bilarabi_v92_smart_learning_engine.zip`.

## Unresolved product decisions

- Cloud AI remains optional; no cloud dependency is required by this release.
- Speech recognition remains the existing optional device/cloud engine; no new provider is introduced.
