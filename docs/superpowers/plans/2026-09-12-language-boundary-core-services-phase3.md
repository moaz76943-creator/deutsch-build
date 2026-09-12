# Language Boundary Core Services Phase 3 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [x]`) syntax for tracking.

**Goal:** Remove remaining German-shaped dependencies from the core content/runtime contracts and learner-facing shared services without changing persisted IDs, SRS behavior, or security boundaries.

**Architecture:** Keep `LearningContent` as the shared read-only content contract. Make `ContentEngine`, `AppDependencies`, `LearningPath`, `LearningEngine`, `VocabularyCoach`, `MasteryDashboard`, and `WordProfileService` consume neutral contracts; keep German source assembly inside `lib/language/german/`. Retain compatibility facades only outside protected shared-service paths when necessary.

**Tech Stack:** Dart/Flutter source, Python pytest architecture/regression gates, JSON canonical content, existing language-pack contracts.

**Spec:** `docs/V374_DEVELOPMENT_ACCELERATION.md` plus the project master directive and existing V365–V375 language-boundary decisions.

## Global Constraints

- JSON remains the canonical content source; generated Dart is derived only.
- Persisted learner IDs and SRS/mastery semantics must remain unchanged.
- Security-sensitive code is not weakened or bypassed.
- Development verification is targeted; release verification remains full.
- Never hide skipped checks; report `SKIPPED — unaffected`.
- REVIEW REQUIRED content candidates are never auto-modified.
- German-specific source selection belongs in the German language layer, not shared core/services.

---

### Task 1: Neutralize runtime content boundary

**Files:**
- Modify: `lib/core/content_contract.dart`
- Modify: `lib/services/content_engine.dart`
- Modify: `lib/language/german/german_content_pack.dart`
- Test: `tests/test_v376_neutral_content_runtime.py`

**Interfaces:**
- Produces `ContentSource<T extends LearningContent>` with `Iterable<T> items`.
- Produces `ContentEngine<T extends LearningContent>` with `Iterable<T> items` and `T? byId(String id)`.
- German source selection remains in `GermanContentPack`.

- [x] **Step 1: Write failing architecture tests** asserting `content_engine.dart` has no German content imports, exposes generic `ContentSource<T extends LearningContent>`, and that German source classes live in the German adapter.
- [x] **Step 2: Run `pytest tests/test_v376_neutral_content_runtime.py -v` and confirm failure against the current German-bound implementation.
- [x] **Step 3: Move legacy/generated source implementations into the German content adapter, make `ContentEngine` generic over `LearningContent`, and keep `byId` behavior identical.
- [x] **Step 4: Run the same focused test and confirm PASS.
- [x] **Step 5: Run legacy content-engine contract tests and update only assertions that encode the old German-specific location.

### Task 2: Neutralize learner planning and dashboard services

**Files:**
- Modify: `lib/models/learning_path.dart`
- Modify: `lib/services/learning_engine.dart`
- Modify: `lib/services/vocabulary_coach.dart`
- Modify: `lib/services/mastery_dashboard.dart`
- Modify: `lib/services/learning_intelligence.dart` only if required by the new neutral path type
- Test: `tests/test_v376_learning_services_neutral.py`

**Interfaces:**
- `LearningPathItem.item` becomes `LearningContent`.
- `LearningEngine.buildPlan` accepts `List<LearningContent>`.
- `VocabularyCoach.recommend` accepts and returns neutral content lists.
- `MasteryDashboard.build` accepts `List<LearningContent>`.

- [x] **Step 1: Write failing tests asserting the shared services import `content_contract.dart` and contain no `ContentItem` dependency.
- [x] **Step 2: Run the focused tests and confirm the current implementation fails those assertions.
- [x] **Step 3: Replace shared-service `ContentItem` types with `LearningContent`, preserving all scoring, topic caps, mastery, mistake, SRS, and production-mode decisions.
- [x] **Step 4: Update UI-side type annotations only where necessary to consume the neutral `LearningPathItem.item` contract; keep concrete German `ContentItem` at the language/content boundary.
- [x] **Step 5: Run focused language-boundary and learning-engine regression tests.

### Task 3: Neutralize repository/profile/quality compatibility edges

**Files:**
- Modify: `lib/services/repository.dart`
- Modify: `lib/services/word_profile_service.dart`
- Modify: `lib/services/quality.dart`
- Modify: `lib/services/text_normalizer.dart` only if no longer referenced by shared code
- Test: `tests/test_v376_service_edges_neutral.py`

**Interfaces:**
- `LearnerRepository.record` accepts `LearningContent` for the item parameter while persisting the same `item.id` and `item.skill`.
- `WordProfileService.build` accepts `LearningContent` and generic search groups.
- Shared quality behavior is injected through `LanguageContentQuality`; the legacy facade is removed from protected shared paths rather than made more German-specific.

- [x] **Step 1: Write failing tests for neutral repository/profile contracts and absence of `ContentQuality`/`TextNormalizer` imports in protected services.
- [x] **Step 2: Run focused tests and confirm failure.
- [x] **Step 3: Apply the minimal neutral contract changes; preserve compatibility facades only where external callers still require them.
- [x] **Step 4: Run focused tests plus all existing quality/profile/repository regressions.
- [x] **Step 5: Run the architecture gate and record the exact remaining findings.

### Task 4: Verification, versioning, and release artifact

**Files:**
- Modify: `pubspec.yaml`
- Modify: `android/app/build.gradle` or the repository's current Android version source
- Create: `docs/V376_LANGUAGE_BOUNDARY_PHASE3.md`
- Create: `docs/V376_CHANGE_LOG.json`
- Create: `docs/V376_FAST_REPORT.json`
- Create: `docs/V376_RELEASE_VERIFICATION.json`
- Test: existing full pytest suite plus `tool/verify.py`

- [x] **Step 1: Run `pytest -q` and record the full result.
- [x] **Step 2: Run `python3 tool/v370_final_architecture_gate.py` and record the finding count.
- [x] **Step 3: Run `python3 tool/verify.py fast --report docs/V376_FAST_REPORT.json` with the actual changed files and record selected/skipped/cached checks.
- [x] **Step 4: Run `python3 tool/verify.py release --report docs/V376_RELEASE_VERIFICATION.json` and require all non-Flutter checks to pass.
- [x] **Step 5: If Flutter is unavailable, explicitly record APK/Flutter build as unavailable rather than claiming build success.
- [x] **Step 6: Package the verified tree as `deutsch_bilarabi_v376_language_boundary_phase3_verified.zip` and calculate SHA-256.
