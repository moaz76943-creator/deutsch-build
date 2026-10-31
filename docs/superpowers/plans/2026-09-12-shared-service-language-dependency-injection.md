# Shared Service Language Dependency Injection Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [x]`) syntax for tracking.

**Goal:** Remove direct German-language service dependencies from shared services by injecting the selected language's normalization and presentation contracts while preserving behavior.

**Architecture:** Shared services consume `LanguageTextNormalizer` and other neutral contracts supplied by the Composition Root. German-specific implementations remain under `lib/language/german/`; compatibility facades are not used by migrated services. No learner-state, SRS, mastery, content IDs, or corpus data behavior changes.

**Tech Stack:** Dart source, Python pytest architecture/regression tests, existing Flutter project structure.

**Spec:** `docs/superpowers/specs/2026-09-12-language-ready-architecture-design.md`

## Global Constraints

- Keep German canonical content and stable IDs unchanged.
- Keep learning algorithms behaviorally unchanged.
- Do not place language-specific rules back into shared services.
- Do not claim Flutter build/analyze success when Flutter is unavailable.
- Use TDD for every production behavior/interface change.

---

### Task 1: Migrate SearchIndex to the language normalizer

**Files:**
- Modify: `lib/services/search_index.dart`
- Modify: `lib/main.dart`
- Test: `tests/test_v372_search_index_language_dependency.py`

**Interfaces:**
- Consumes: `LanguageTextNormalizer` from `LanguagePack.textNormalizer`.
- Produces: `SearchIndex<T>(items, verbIndex, textNormalizer)` with all existing search behavior preserved.

- [x] **Step 1: Write the failing architecture tests**

```python
def test_search_index_accepts_injected_language_normalizer():
    text = Path("lib/services/search_index.dart").read_text()
    assert "LanguageTextNormalizer" in text
    assert "SearchIndex(this._items, this._verbIndex, this._textNormalizer);" in text


def test_search_index_does_not_import_legacy_text_normalizer():
    text = Path("lib/services/search_index.dart").read_text()
    assert "import 'text_normalizer.dart';" not in text


def test_composition_root_injects_language_normalizer():
    text = Path("lib/main.dart").read_text()
    assert "SearchIndex(corpus, contentPack.verbIndex, languagePack.textNormalizer)" in text
```

- [x] **Step 2: Run the focused tests and verify RED**

Run: `pytest -q tests/test_v372_search_index_language_dependency.py`
Expected: FAIL because the constructor and Composition Root still use the legacy normalizer dependency.

- [x] **Step 3: Implement the minimal migration**

Add `LanguageTextNormalizer` to `SearchIndex`, store it as `_textNormalizer`, replace every `TextNormalizer.answer(...)` call with `_textNormalizer.answer(...)`, remove the legacy import, and update `main.dart` to pass `languagePack.textNormalizer`.

- [x] **Step 4: Run focused tests and full regression**

Run: `pytest -q tests/test_v372_search_index_language_dependency.py`
Expected: PASS.

Run: `pytest -q`
Expected: all tests PASS with no failures.

- [x] **Step 5: Commit**

```bash
git add lib/services/search_index.dart lib/main.dart tests/test_v372_search_index_language_dependency.py docs/superpowers/plans/2026-09-12-shared-service-language-dependency-injection.md
git commit -m "refactor: inject language normalization into search index"
```

### Task 2: Migrate WordProfileService and ReadingPractice

**Files:**
- Modify: `lib/services/word_profile_service.dart`
- Modify: `lib/services/reading_practice.dart`
- Test: `tests/test_v372_shared_service_language_projection.py`

**Interfaces:**
- Consumes: `LearningContent`, `LanguageTextNormalizer`, and `LanguageContentQuality` contracts.
- Produces: shared services without direct German `ContentItem`/legacy normalizer/quality dependencies.

- [x] **Step 1: Write failing tests**

```python
def test_word_profile_uses_neutral_content_and_injected_normalizer():
    text = Path("lib/services/word_profile_service.dart").read_text()
    assert "LanguageTextNormalizer" in text
    assert "item.german" not in text
    assert "item.sentence" not in text
    assert "TextNormalizer" not in text


def test_reading_practice_uses_language_quality_and_neutral_content():
    text = Path("lib/services/reading_practice.dart").read_text()
    assert "LanguageContentQuality" in text
    assert "item.german" not in text
    assert "item.sentence" not in text
    assert "ContentQuality" not in text
```

- [x] **Step 2: Run focused tests to verify RED**

Run: `pytest -q tests/test_v372_shared_service_language_projection.py`
Expected: FAIL on the existing direct dependencies.

- [x] **Step 3: Implement the minimal migration**

Change `WordProfileService.build` to accept `LearningContent`, inject `LanguageTextNormalizer`, and use `sourceText`/`exampleText`. Change `ReadingPractice.build` to accept `LearningContent` and `LanguageContentQuality`, using the injected quality contract and neutral projections.

- [x] **Step 4: Update callers and run tests**

Update Composition Root or service call sites to pass `languagePack.textNormalizer` and `languagePack.contentQuality` where required. Run the focused tests, then `pytest -q`.

- [x] **Step 5: Commit**

```bash
git add lib/services/word_profile_service.dart lib/services/reading_practice.dart tests/test_v372_shared_service_language_projection.py
git commit -m "refactor: remove German content dependencies from shared services"
```

### Task 3: Run the architecture closure audit

**Files:**
- Modify: `tests/test_v372_shared_service_language_projection.py` only if the audit exposes a concrete false positive.
- Create: `docs/V372_SHARED_SERVICE_LANGUAGE_DEPENDENCY_INJECTION.md`

**Interfaces:**
- Consumes: migrated shared-service contracts.
- Produces: evidence showing remaining German references are either language-owned or compatibility-only.

- [x] **Step 1: Run targeted architecture scans**

Run searches for `ContentItem`, `TextNormalizer`, `.german`, `.arabic`, `.sentenceAr`, `.article`, and `.plural` under shared services.

- [x] **Step 2: Run the full regression**

Run: `pytest -q`
Expected: all tests PASS.

- [x] **Step 3: Run content/compiler checks**

Run the existing content validation, audio validation, compiler/parity, security, privacy, accessibility, architecture, quality, and weakness gates exactly as available in the repository.

- [x] **Step 4: Document evidence**

Record the migrated files, remaining justified compatibility references, test counts, content cardinality, and unavailable Flutter commands without claiming unsupported results.

- [x] **Step 5: Create the verified V372 archive**

Archive the verified project tree only after all checks pass and compute SHA-256 from the final archive.
