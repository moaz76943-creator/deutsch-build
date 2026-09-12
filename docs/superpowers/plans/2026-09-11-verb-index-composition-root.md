# VerbIndex Composition Root Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Move V35 verb-index ownership from direct singleton access into explicit composition-root dependency injection.

**Architecture:** `main.dart` composes one `VerbIndex` instance and exposes it through `AppDependencies`. V35 verb pages consume the injected index; they do not construct or look up the singleton.

**Tech Stack:** Flutter/Dart application code, Python pytest contract/regression tests.

**Spec:** `docs/superpowers/specs/2026-09-11-verb-index-composition-root-design.md`

## Global Constraints

- Keep `VerbIndex.instance` confined to composition/compatibility boundaries.
- Do not change verb data, caching, favorites, or conjugation behavior.
- Do not construct services inside V35 pages.
- Preserve existing behavior outside the migrated V35 surface.
- Run focused tests and the full regression suite after changes.

---

### Task 1: Inject VerbIndex into V35 verb pages

**Files:**
- Modify: `lib/ui_v35/verb_pages.dart`
- Modify: `lib/ui_v35/app.dart`
- Test: `tests/test_v340_verb_index_dependency_injection.py`

**Interfaces:**
- Consumes: `AppDependencies.verbIndex`.
- Produces: `VerbConjugationPage(..., verbIndex: VerbIndex)` and `VerbFavoritesPage(..., verbIndex: VerbIndex)`.

- [x] Write focused contract tests.
- [x] Verify tests fail against singleton-based implementation.
- [x] Inject `VerbIndex` into both V35 pages.
- [x] Pass the injected instance through navigation.
- [x] Verify focused tests and full regression.
- [x] Run all quality and security gates.
