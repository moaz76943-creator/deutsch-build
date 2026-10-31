# Language Boundary — Content Services Phase 1 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remove the first coherent cluster of remaining German-shaped dependencies from shared content services while preserving runtime behavior, stable IDs, and the V374 verification system.

**Architecture:** Keep `LearningContent` as the shared content contract and move German-specific content sourcing behind `LanguageContentPack`/language-layer boundaries. Shared services consume neutral contracts and receive language behavior explicitly from the composition root. Compatibility facades remain only where needed to avoid a broad breaking migration in one release.

**Tech Stack:** Dart/Flutter source tree, Python verification tooling, pytest regression suite, generated JSON→Dart content compiler.

**Spec:** `docs/2026-09-12-language-ready-architecture.md` and `docs/superpowers/plans/2026-09-12-development-acceleration-design.md`

## Global Constraints

- Canonical content remains JSON under `content/german/`; generated Dart remains derived and never becomes source of truth.
- Stable content IDs must not change.
- Shared/core code must not import German-specific content implementations.
- Language-specific normalization and quality behavior must remain in the language layer.
- Security, privacy, SRS, mastery, learner state, and entitlement behavior must not be weakened.
- Development verification must remain change-aware; release verification remains full and fail-closed.
- Every behavior-changing refactor gets a permanent regression test.
- Do not claim Flutter verification unless Flutter is actually available.

---

### Task 1: Lock the content-contract boundary

**Files:**
- Modify: `lib/core/content_contract.dart`
- Modify: `lib/services/app_dependencies.dart`
- Test: `tests/test_v374_language_boundary_phase1.py`

**Interfaces:**
- Consumes: existing `LearningContent` contract and `LanguagePack`.
- Produces: composition-root dependency types that expose neutral content instead of `ContentItem` in shared dependency declarations.

- [ ] **Step 1: Write the failing test**

Add a static boundary test that reads the two files and asserts `app_dependencies.dart` does not declare `ContentItem` for `corpus` or `SearchIndex<ContentItem>`, while `LearningContent` remains the shared contract.

```python
def test_app_dependencies_uses_language_neutral_content_contract():
    text = Path("lib/services/app_dependencies.dart").read_text()
    assert "SearchIndex<ContentItem>" not in text
    assert "List<ContentItem> corpus" not in text
    assert "content_contract.dart" in Path("lib/core/content_contract.dart").read_text()
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pytest tests/test_v374_language_boundary_phase1.py::test_app_dependencies_uses_language_neutral_content_contract -v`
Expected: FAIL because `AppDependencies` currently exposes `ContentItem`.

- [ ] **Step 3: Write minimal implementation**

Change `AppDependencies` to import `LearningContent` and declare:

```dart
final SearchIndex<LearningContent> searchIndex;
final List<LearningContent> corpus;
```

Keep `VerbIndex` and `LanguagePack` unchanged in this task. Do not change persisted models.

- [ ] **Step 4: Run test to verify it passes**

Run: `pytest tests/test_v374_language_boundary_phase1.py::test_app_dependencies_uses_language_neutral_content_contract -v`
Expected: PASS.

- [ ] **Step 5: Run the directly affected Dart-boundary tests**

Run: `pytest tests/test_v373_content_intelligence_language_boundary.py tests/test_v372_shared_service_language_projection.py -q`
Expected: PASS; if a compile-level Dart test fails, stop and correct the type migration before proceeding.

---

### Task 2: Neutralize ContentEngine's source contract

**Files:**
- Modify: `lib/services/content_engine.dart`
- Test: `tests/test_v374_language_boundary_phase1.py`

**Interfaces:**
- Consumes: `LearningContent` and the existing generated/legacy source implementations.
- Produces: `ContentSource` returning `Iterable<LearningContent>` and `ContentEngine.byId` returning `LearningContent?`.

- [ ] **Step 1: Write the failing test**

Add a static test:

```python
def test_content_engine_exposes_learning_content_not_content_item():
    text = Path("lib/services/content_engine.dart").read_text()
    assert "import '../core/content_contract.dart';" in text
    assert "Iterable<ContentItem> get items" not in text
    assert "ContentItem? byId" not in text
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pytest tests/test_v374_language_boundary_phase1.py::test_content_engine_exposes_learning_content_not_content_item -v`
Expected: FAIL on the current `ContentItem` return types.

- [ ] **Step 3: Write minimal implementation**

Import `../core/content_contract.dart`, make `ContentSource.items` return `Iterable<LearningContent>`, and make `ContentEngine.items`/`byId` return `LearningContent` types. Keep `LegacyContentSource` and `JsonGeneratedContentSource` backed by the existing German data; this task changes the interface, not the source-of-truth location.

- [ ] **Step 4: Run test to verify it passes**

Run: `pytest tests/test_v374_language_boundary_phase1.py::test_content_engine_exposes_learning_content_not_content_item -v`
Expected: PASS.

- [ ] **Step 5: Run targeted content/compiler regression tests**

Run: `pytest tests/test_v356_bulk_content_import.py tests/test_v357_bulk_apply.py tests/test_v374_content_compile_cache.py -q`
Expected: PASS.

---

### Task 3: Neutralize ContentDepth lookup input

**Files:**
- Modify: `lib/services/content_depth.dart`
- Test: `tests/test_v374_language_boundary_phase1.py`

**Interfaces:**
- Consumes: `LearningContent` IDs.
- Produces: `WordDepth depthFor(LearningContent x)` without a model-specific import.

- [ ] **Step 1: Write the failing test**

```python
def test_content_depth_uses_neutral_content_contract():
    text = Path("lib/services/content_depth.dart").read_text()
    assert "import '../core/content_contract.dart';" in text
    assert "import '../models/content.dart';" not in text
    assert "depthFor(ContentItem x)" not in text
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pytest tests/test_v374_language_boundary_phase1.py::test_content_depth_uses_neutral_content_contract -v`
Expected: FAIL.

- [ ] **Step 3: Write minimal implementation**

Replace the model import with the neutral contract import and change only the lookup signature to `depthFor(LearningContent x)`. Preserve every existing depth entry and Arabic/German enrichment string byte-for-byte.

- [ ] **Step 4: Run test to verify it passes**

Run: `pytest tests/test_v374_language_boundary_phase1.py::test_content_depth_uses_neutral_content_contract -v`
Expected: PASS.

- [ ] **Step 5: Run the focused learning tests**

Run: `pytest tests/test_v372_shared_service_language_projection.py tests/test_v373_content_intelligence_language_boundary.py -q`
Expected: PASS.

---

### Task 4: Neutralize ReadingPractice's public content surface

**Files:**
- Modify: `lib/services/reading_practice.dart`
- Test: `tests/test_v374_language_boundary_phase1.py`

**Interfaces:**
- Consumes: `List<LearningContent>` and `LanguageContentQuality`.
- Produces: `ReadingPassage` containing `List<LearningContent>`.

- [ ] **Step 1: Write the failing test**

```python
def test_reading_practice_uses_neutral_content_contract():
    text = Path("lib/services/reading_practice.dart").read_text()
    assert "import '../core/content_contract.dart';" in text
    assert "import '../models/content.dart';" not in text
    assert "List<ContentItem>" not in text
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pytest tests/test_v374_language_boundary_phase1.py::test_reading_practice_uses_neutral_content_contract -v`
Expected: FAIL.

- [ ] **Step 3: Write minimal implementation**

Change `ReadingPassage.sentences`, `ReadingPractice.build` input, and local collections from `ContentItem` to `LearningContent`. Keep the quality contract and all selection rules unchanged.

- [ ] **Step 4: Run test to verify it passes**

Run: `pytest tests/test_v374_language_boundary_phase1.py::test_reading_practice_uses_neutral_content_contract -v`
Expected: PASS.

- [ ] **Step 5: Run focused regression tests**

Run: `pytest tests/test_v372_shared_service_language_projection.py tests/test_v374_verify.py -q`
Expected: PASS.

---

### Task 5: Re-run the architecture gate and acceleration verification

**Files:**
- Modify: `docs/V375_ARCHITECTURE_PHASE1_REPORT.json`
- Modify: `docs/V375_FAST_REPORT.json`
- Modify: `docs/V375_CHANGE_LOG.json`

**Interfaces:**
- Consumes: the changed Dart files and V374 verification tooling.
- Produces: machine-readable evidence showing the architecture finding count and selected checks after the phase.

- [ ] **Step 1: Run the architecture gate**

Run: `python3 tool/v370_final_architecture_gate.py > docs/V375_ARCHITECTURE_PHASE1_REPORT.txt`
Expected: a real finding count; do not force PASS. The count should be lower than 47 if all four refactors are accepted by the gate.

- [ ] **Step 2: Run fast verification against the changed service files**

Run: `./scripts/check-fast.sh --changed lib/services/app_dependencies.dart --changed lib/services/content_engine.dart --changed lib/services/content_depth.dart --changed lib/services/reading_practice.dart --report docs/V375_FAST_REPORT.json`
Expected: targeted/content-related checks selected according to risk, unaffected checks explicitly marked `SKIPPED — unaffected`, and no hidden skips.

- [ ] **Step 3: Run focused acceleration tests**

Run: `pytest tests/test_v374_change_impact.py tests/test_v374_verification_cache.py tests/test_v374_verify.py tests/test_v374_parallel_plan.py tests/test_v374_content_compile_cache.py tests/test_v374_release_verification_contract.py tests/test_v374_cache_reporting.py tests/test_v374_language_boundary_phase1.py -q`
Expected: PASS.

- [ ] **Step 4: Record the change log**

Write `docs/V375_CHANGE_LOG.json` with `version`, `base_version`, `changed_files`, `architecture_findings_before`, `architecture_findings_after`, `tests`, and `status`. Set `status` to `PASS` only if every executed verification passes; otherwise record the actual failure.

- [ ] **Step 5: Run the complete Python regression suite**

Run: `pytest -q`
Expected: all existing tests pass. If the suite exposes a legitimate compatibility issue, add a regression test first and then make the smallest neutral-contract fix.
