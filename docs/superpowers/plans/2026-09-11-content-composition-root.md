# Content Composition Root Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Move V35 content ownership from direct `ContentEngine.instance` access into explicit composition-root dependencies.

**Architecture:** The composition root creates one immutable corpus and supplies it through `AppDependencies`. V35 pages consume the corpus explicitly and never construct content/search services themselves.

**Tech Stack:** Flutter/Dart application code, Python pytest contract/regression tests.

**Spec:** `docs/superpowers/specs/2026-09-11-content-composition-root-design.md`

## Global Constraints

- Keep `ContentEngine.instance` confined to composition/root or compatibility boundaries.
- Do not change learning/content algorithms.
- Do not construct `SearchIndex` or `VerbIndex` inside V35 UI.
- Preserve existing behavior and compatibility outside the migrated V35 surface.
- Run focused tests and the full regression suite after changes.

---

### Task 1: Compose the content corpus explicitly

**Files:**
- Modify: `lib/services/app_dependencies.dart`
- Modify: `lib/main.dart`
- Test: `tests/test_v339_content_composition_root.py`

**Interfaces:**
- Consumes: `ContentEngine.instance.items` at the composition root.
- Produces: `AppDependencies.corpus` as the explicit `List<ContentItem>` dependency consumed by V35.

- [x] Add the corpus contract to `AppDependencies`.
- [x] Build the corpus once in `main.dart`.
- [x] Pass the same corpus to `SearchIndex` and `AppDependencies`.
- [x] Verify the focused V339 tests.

### Task 2: Remove direct content access from V35

**Files:**
- Modify: `lib/ui_v35/app.dart`
- Modify: `lib/ui_v35/learning_pages.dart`
- Modify: `lib/ui_v35/progress_pages.dart`
- Test: `tests/test_v339_content_composition_root.py`

**Interfaces:**
- Consumes: `AppDependencies.corpus`.
- Produces: V35 page constructors with explicit corpus dependencies.

- [x] Add `corpus` to V35 pages that consume content.
- [x] Pass corpus through nested navigation paths.
- [x] Remove all `ContentEngine.instance` references from V35.
- [x] Prevent `SearchIndex(...)` and `VerbIndex.instance` construction in V35.
- [x] Migrate historical contract tests to the new boundary.
- [x] Verify full regression and quality/security gates.
