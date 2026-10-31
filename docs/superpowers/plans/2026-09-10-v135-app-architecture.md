# V135 app.dart Architecture Refactor Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reduce the monolithic `lib/ui_v35/app.dart` safely by extracting independent pages without changing navigation or learning behavior.

**Architecture:** Move small, self-contained page classes into `lib/ui_v35/pages/core_pages.dart`. Keep shared domain logic in existing services/models and keep `app.dart` as the composition/root UI layer. Add static regression guards so the extracted classes remain outside the root file and the root file continues shrinking.

**Tech Stack:** Flutter/Dart source, Python pytest static architecture tests.

**Spec:** V135 weakness-hardening architecture plan.

## Global Constraints

- Preserve existing public widget class names and constructor signatures.
- Do not change learning algorithms, repository semantics, or navigation destinations.
- Do not introduce new runtime dependencies.
- Do not claim Flutter runtime verification while Flutter SDK is unavailable in this environment.
- Prefer small reversible extraction steps over a large rewrite.

---

### Task 1: Protect the first extraction with a failing architecture test

**Files:**
- Create: `test/v135_app_split_test.py`

**Interfaces:**
- Consumes: `lib/ui_v35/app.dart`
- Produces: static assertions for extracted page ownership and root-file size.

- [ ] Write failing test requiring `core_pages.dart` and requiring six page classes to be absent from `app.dart`.
- [ ] Run the focused test and confirm it fails before source changes.

### Task 2: Extract independent core pages

**Files:**
- Create: `lib/ui_v35/pages/core_pages.dart`
- Modify: `lib/ui_v35/app.dart`

**Interfaces:**
- Consumes: existing models/services used by Weekly, Germany Reality, Placement, Quality, and Feature Status pages.
- Produces: unchanged public page classes imported by `app.dart`.

- [ ] Move `WeeklyPage`, `GermanyRealityPage`, `RealityPractice`, `PlacementPage`, `QualityV35`, and `FeatureStatusPage`.
- [ ] Add the minimal imports needed by the new file.
- [ ] Import the new file from `app.dart`.
- [ ] Keep all constructor signatures unchanged.

### Task 3: Verify regression and document the extraction

**Files:**
- Modify: `docs/V135_WEAKNESS_ARCHITECTURE.md`
- Test: `test/v135_app_split_test.py`

- [ ] Run focused architecture tests.
- [ ] Run the complete Python test suite.
- [ ] Run quality, security, content, accessibility, and architecture audits.
- [ ] Run Python compile checks.
- [ ] Record Flutter runtime verification as unverified unless SDK is available.
