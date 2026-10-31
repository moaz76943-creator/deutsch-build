# Language-Ready Architecture Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make future language additions or replacements localized to language-specific files while preserving current learning quality, content IDs, behavior, security, and performance.

**Architecture:** Keep Core algorithms language-agnostic, isolate language rules and content in language-specific packs, and let the Composition Root select the active language for a build. Use compatibility adapters before high-risk model migrations; do not introduce dynamic multi-language runtime now.

**Tech Stack:** Flutter/Dart source, Python pytest architecture tests, existing content generation and audit scripts.

**Spec:** `docs/superpowers/specs/2026-09-12-language-ready-architecture-design.md`

## Global Constraints

- No change to learning/content/search/mastery algorithms unless an equivalent interface refactor is proven by tests.
- No content-data mutation; stable IDs must remain unchanged.
- No new package dependency unless separately approved.
- No Multi-Language Runtime in this phase.
- No secrets, learner state, subscription authority, or authentication credentials in language packs.
- High-risk model/interface migration is isolated into its own stage.
- Flutter/Dart build status must be reported accurately.
- Full pytest regression is required after every implementation stage.

---

### Task 1: V346 Language Boundary Audit

**Files:**
- Create: `docs/ARCHITECTURE_LANGUAGE_AUDIT_V346.md`
- Create: `tests/test_v346_language_boundary_audit.py`

**Interfaces:**
- Produces a reviewed inventory of language-coupled areas and a migration roadmap.

- [x] Step 1: Write the failing audit test.
- [x] Step 2: Run the focused test and observe RED.
- [x] Step 3: Write the audit classification from the actual codebase.
- [x] Step 4: Re-run the focused test for GREEN.
- [x] Step 5: Run full pytest regression and architecture/security/privacy/quality/accessibility/weakness gates.

---

### Task 2: V347 Content Contract Compatibility Layer (staged)

**Files:**
- Create: `lib/core/content_contract.dart`.
- Modify: `lib/models/content.dart`, `lib/services/search_index.dart`, `lib/services/app_dependencies.dart`, dependent tests.
- Test: `tests/test_v347_content_contract.py` plus migrated static search tests.

**Interfaces:**
- Core consumes a stable language-neutral content view.
- Existing `ContentItem` remains as compatibility input.

- [x] Step 1: Write failing tests for the projection boundary.
- [x] Step 2: Run RED.
- [x] Step 3: Implement the smallest adapter/projection and generic search boundary.
- [x] Step 4: Run focused tests GREEN and migrate stale implementation-detail assertions.
- [x] Step 5: Run full regression and all release gates.
- [x] Step 6: Migrate `LearningCore` to consume the language-neutral contract without changing learning behavior.

---

### Task 3: V348 German Language Pack at Composition Root

**Files:**
- Create: `lib/language/german/...` contracts/configuration.
- Modify: `lib/services/app_dependencies.dart`, `lib/main.dart`.
- Test: `tests/test_v348_german_language_pack.py`.

**Interfaces:**
- Composition Root receives one language pack for the current build.
- German implementation remains behaviorally identical.

- [x] Step 1: Write failing tests.
- [x] Step 2: Run RED.
- [x] Step 3: Implement language pack façade only.
- [x] Step 4: Run focused GREEN.
- [x] Step 5: Full regression + gates.

---

### Task 4: V349 German Content Namespace Migration

**Files:**
- Move language-specific content files from `lib/data` to `content/german` through a compatibility-safe migration.
- Modify imports and generators only as needed.
- Test: `tests/test_v349_german_content_namespace.py`.

**Interfaces:**
- Existing content IDs and corpus cardinality remain unchanged.

- [x] Step 1: Write corpus identity/ID preservation tests.
- [x] Step 2: Run RED.
- [x] Step 3: Move sources with compatibility exports where required.
- [x] Step 4: Run GREEN.
- [x] Step 5: Full regression + content quality audit.

---

### Task 5: V350 Language Exercise Strategy Isolation

**Files:**
- Create language-specific assessment/production/repair/conversation strategy contracts.
- Modify corresponding services and tests.
- Test: `tests/test_v350_language_exercise_isolation.py`.

**Interfaces:**
- Exercise generation no longer hardcodes German in language-agnostic services.

- [x] Step 1: Write failing tests.
- [x] Step 2: Run RED.
- [x] Step 3: Implement one strategy boundary at a time.
- [x] Step 4: Run focused GREEN.
- [x] Step 5: Full regression + audits.

---

### Task 6: V351+ Language-Aware Presentation Split

**Files:**
- `lib/ui_v35/*` and legacy UI only where justified by the audited coupling.
- Test files for each extracted boundary.

**Interfaces:**
- Shared page shells consume language-aware content/strings through contracts.
- German-only scenarios and copy remain isolated.

- [ ] Step 1: Split one bounded UI surface at a time.
- [ ] Step 2: Verify visual/content behavior before expanding scope.
- [ ] Step 3: Repeat until German-specific UI coupling is localized.
