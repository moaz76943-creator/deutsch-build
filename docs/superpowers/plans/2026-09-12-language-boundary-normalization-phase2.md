# Language Boundary Normalization Phase 2 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox syntax for tracking.

**Goal:** Remove legacy German normalization dependencies from shared services while preserving existing behavior through injected `LanguageTextNormalizer` instances.

**Architecture:** Shared services receive the language-neutral `LanguageTextNormalizer` contract. German-specific construction remains in the language/composition layer. Legacy `TextNormalizer` is retained only as a compatibility facade until all consumers are migrated.

**Tech Stack:** Dart/Flutter source, Python pytest architecture/regression gates.

**Spec:** Existing V370 language-boundary architecture gate plus V374 development-acceleration governance.

## Global Constraints
- Do not move German rules into shared/core code.
- Preserve public behavior and existing SRS/mastery/learner semantics.
- Every behavior-changing refactor gets regression coverage.
- Fast verification remains targeted; release verification remains full.
- Never treat a compatibility facade as canonical source.
- No Flutter build claim unless Flutter is actually installed and executed.

---

### Task 1: Inject normalization into VerbIndex

**Files:**
- Modify: `lib/services/verb_index.dart`
- Modify: `lib/language/german/german_content_pack.dart`
- Test: `tests/test_v375_language_normalization_consumers.py`

**Interfaces:**
- Consumes: `LanguageTextNormalizer`.
- Produces: `VerbIndex({required LanguageTextNormalizer textNormalizer})`; lookup methods normalize through the injected dependency.

- [x] Write a regression test asserting `VerbIndex` stores and queries forms using a supplied fake normalizer and contains no `TextNormalizer` reference.
- [x] Run the focused pytest and verify it fails because the constructor/dependency is absent.
- [x] Implement the minimal injected-normalizer constructor and replace all `TextNormalizer.answer` calls with the field.
- [x] Make `GermanContentPack.verbIndex` own the German construction using its `GermanLanguagePack().textNormalizer`, preserving one cached instance.
- [x] Run the focused pytest and the existing V340/V354 verb composition tests.

### Task 2: Remove legacy normalization from ConversationEngine and ProductionEngine

**Files:**
- Modify: `lib/services/conversation_engine.dart`
- Modify: `lib/services/production_engine.dart`
- Test: `tests/test_v375_language_normalization_consumers.py`

**Interfaces:**
- Consumes: `LanguageTextNormalizer` through constructors/required arguments.
- Produces: conversation scoring and production matching with language-provided normalization.

- [x] Add tests using a fake normalizer that visibly transforms input and prove scoring/matching uses it.
- [x] Run focused tests and verify failure against current static legacy normalization.
- [x] Add required `LanguageTextNormalizer textNormalizer` dependency to each service seam without changing scoring formulas or accepted-answer semantics.
- [x] Update existing construction sites to pass the selected language normalizer.
- [x] Run focused tests plus affected conversation/production tests.

### Task 3: Inject normalization into WritingAnalyzer

**Files:**
- Modify: `lib/services/writing_analyzer.dart`
- Modify: `lib/ui_v35/conversation_pages.dart`
- Test: `tests/test_v375_language_normalization_consumers.py`

**Interfaces:**
- Consumes: `LanguageTextNormalizer`.
- Produces: `WritingAnalyzer.analyze(String input, {required LanguageTextNormalizer textNormalizer})`.

- [x] Add a test proving tokenization follows a supplied normalizer rather than German-specific rules.
- [x] Run focused test and verify failure.
- [x] Implement the injected normalizer parameter and preserve all existing local writing checks.
- [x] Pass the selected normalizer from the writing-coach UI composition boundary.
- [x] Run the focused writing tests and existing writing regression tests.

### Task 4: Normalize compatibility boundaries and audit

**Files:**
- Modify: `lib/services/search_index_legacy.dart`
- Modify: `lib/services/text_normalizer.dart` only if needed for compatibility documentation
- Modify: `docs/V375_LANGUAGE_BOUNDARY_PHASE2.json`
- Test: `tests/test_v375_language_normalization_consumers.py`

**Interfaces:**
- Consumes: language-layer normalizer at legacy compatibility boundaries.
- Produces: an explicit machine-readable migration record and a reduced V370 finding set.

- [x] Add architecture assertions that shared consumers no longer import or call the legacy `TextNormalizer`.
- [x] Run the architecture-focused tests and confirm they fail on remaining consumers.
- [x] Migrate `search_index_legacy.dart` to receive/use the neutral contract where its public shape permits; do not remove compatibility exports.
- [x] Run the V370 architecture gate and record before/after findings in JSON.
- [x] Run the full pytest suite and verify zero failures.

## Self-review checklist
- Shared services depend on the neutral interface, not German implementation classes.
- German construction remains in `lib/language/german/`.
- Existing compatibility APIs remain unless removal is proven safe by the architecture gate and tests.
- No task changes learner state, SRS, mastery, authentication, entitlement, or persistence behavior.
- The plan contains no placeholders or undefined interfaces.
