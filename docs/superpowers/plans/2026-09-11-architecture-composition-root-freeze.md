# Architecture Composition Root & Freeze Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Close remaining global dependency leaks and freeze the canonical dependency direction around one composition root.

**Architecture:** `main.dart` constructs the canonical content/index graph. `AppDependencies` carries immutable explicit dependencies into UI/services. Legacy facades remain only where backward compatibility requires them.

**Tech Stack:** Flutter/Dart source, Python pytest architecture tests, existing security/privacy/quality/accessibility/architecture/weakness audit scripts.

**Spec:** `docs/superpowers/specs/2026-09-11-architecture-composition-root-freeze-design.md`

## Global Constraints

- No change to learning/content/search/mastery algorithms.
- No new package dependency.
- No content-data mutation.
- No secrets or learner state in dependency containers.
- Legacy facades remain only as compatibility boundaries until explicitly retired.
- Flutter/Dart toolchain availability must be reported accurately.

---

### Task 1: V341 Legacy UI composition isolation

**Files:**
- Modify: `lib/ui/app.dart`
- Test: `tests/test_v341_legacy_ui_composition.py`

**Interfaces:**
- `DeutschApp` accepts `AppDependencies dependencies`.
- `Home`, `LearningSession`, `VocabularyPage`, `VerbPage`, and `MasteryDashboardPage` consume the corresponding explicit dependencies.

- [x] **Step 1: Write the failing test**

```python
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / 'lib/ui/app.dart'


def test_legacy_ui_uses_explicit_composition_dependencies():
    text = SRC.read_text(encoding='utf-8')
    assert "import '../services/content_engine.dart';" not in text
    assert "import '../services/verb_index.dart';" not in text
    assert 'final AppDependencies dependencies;' in text
    assert 'ContentEngine.instance' not in text
    assert 'VerbIndex.instance' not in text
```

- [x] **Step 2: Run the test to verify RED**

Run: `pytest tests/test_v341_legacy_ui_composition.py -q`
Expected: FAIL on existing global references.

- [x] **Step 3: Implement the minimal migration**

Import `AppDependencies`, add required dependency fields/constructors, pass `dependencies.corpus` into learning/vocabulary/mastery pages, and `dependencies.verbIndex` into verb pages. Do not alter algorithms or UI text.

- [x] **Step 4: Run focused test to verify GREEN**

Run: `pytest tests/test_v341_legacy_ui_composition.py -q`
Expected: PASS.

- [x] **Step 5: Run full regression**

Run: `pytest -q`
Expected: zero failures.

---

### Task 2: V342 MasteryDashboard dependency isolation

**Files:**
- Modify: `lib/services/mastery_dashboard.dart`
- Modify: `lib/ui_v35/progress_pages.dart`
- Modify: `lib/ui/app.dart`
- Test: `tests/test_v342_mastery_dashboard_dependency_isolation.py`

**Interfaces:**
- `MasteryDashboard.build(LearnerState state, {required List<ContentItem> corpus, DateTime? now})`.

- [x] **Step 1: Write the failing test**

```python
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DASH = ROOT / 'lib/services/mastery_dashboard.dart'
PROGRESS = ROOT / 'lib/ui_v35/progress_pages.dart'


def test_mastery_dashboard_has_no_content_engine_fallback():
    text = DASH.read_text(encoding='utf-8')
    assert "import 'content_engine.dart';" not in text
    assert 'ContentEngine.instance' not in text
    assert 'required List<ContentItem> corpus' in text


def test_progress_page_passes_corpus_to_mastery_dashboard():
    text = PROGRESS.read_text(encoding='utf-8')
    assert 'MasteryDashboard.build(repo.load(), corpus: corpus)' in text
```

- [x] **Step 2: Run RED**

Run: `pytest tests/test_v342_mastery_dashboard_dependency_isolation.py -q`
Expected: FAIL because the fallback still exists.

- [x] **Step 3: Implement minimal change**

Remove the `ContentEngine` import and fallback. Make `corpus` required. Update every caller to provide the already-composed corpus. Preserve calculations unchanged.

- [x] **Step 4: Run focused GREEN**

Run: `pytest tests/test_v342_mastery_dashboard_dependency_isolation.py -q`
Expected: PASS.

- [x] **Step 5: Full regression**

Run: `pytest -q`
Expected: zero failures.

---

### Task 3: V343 composition-root consolidation

**Files:**
- Modify: `lib/main.dart`
- Modify: `lib/services/app_dependencies.dart`
- Test: `tests/test_v343_composition_root_consolidation.py`

**Interfaces:**
- `AppDependencies` remains a passive immutable dependency container.
- `main()` remains the only production composition root for app-wide content/index construction.

- [x] **Step 1: Write failing test**

```python
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LIB = ROOT / 'lib'
MAIN = ROOT / 'lib/main.dart'


def test_modern_ui_does_not_construct_search_or_content_services():
    offenders = []
    for path in (LIB / 'ui_v35').rglob('*.dart'):
        text = path.read_text(encoding='utf-8')
        for token in ('SearchIndex(', 'VerbIndex(', 'ContentEngine('):
            if token in text:
                offenders.append((str(path), token))
    assert offenders == []


def test_main_is_composition_root_for_content_and_indexes():
    text = MAIN.read_text(encoding='utf-8')
    assert 'final corpus = ContentEngine.instance.items.toList(growable: false);' in text
    assert 'final searchIndex = SearchIndex(corpus, VerbIndex.instance);' in text
    assert 'final dependencies = AppDependencies(' in text
```

- [x] **Step 2: Run RED**

Run: `pytest tests/test_v343_composition_root_consolidation.py -q`
Expected: FAIL only for any remaining modern UI construction.

- [x] **Step 3: Implement minimal consolidation**

Remove only direct construction found by the test from modern UI. Pass existing dependencies through constructors/navigation. Do not broaden into legacy UI or service refactors beyond the offending construction.

- [x] **Step 4: Run GREEN**

Run: `pytest tests/test_v343_composition_root_consolidation.py -q`
Expected: PASS.

- [x] **Step 5: Full regression**

Run: `pytest -q`
Expected: zero failures.

---

### Task 4: V344 global singleton audit

**Files:**
- Create: `tests/test_v344_global_singleton_audit.py`
- Create: `docs/ARCHITECTURE_SINGLETON_AUDIT_V344.md`

**Interfaces:**
- Produces a stable classification of global singleton references in `lib/`.

- [x] **Step 1: Write the failing audit**

```python
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]


def test_singletons_are_classified_not_uncontrolled():
    refs = []
    for path in (ROOT / 'lib').rglob('*.dart'):
        text = path.read_text(encoding='utf-8')
        for m in re.finditer(r'([A-Za-z0-9_]+)\.instance', text):
            refs.append((str(path.relative_to(ROOT)), m.group(0)))
    audit = (ROOT / 'docs/ARCHITECTURE_SINGLETON_AUDIT_V344.md').read_text(encoding='utf-8')
    assert refs
    for path, ref in refs:
        assert ref in audit, f'unclassified singleton: {path} {ref}'
```

- [x] **Step 2: Run RED**

Run: `pytest tests/test_v344_global_singleton_audit.py -q`
Expected: FAIL because the audit does not yet classify all refs.

- [x] **Step 3: Write classification**

Classify every `*.instance` reference as `COMPOSITION_ROOT`, `LEGACY_COMPATIBILITY`, `INTENTIONAL_GLOBAL`, or `MIGRATION_CANDIDATE`, with an explicit reason and next action. Do not change code solely to improve the report.

- [x] **Step 4: Run GREEN**

Run: `pytest tests/test_v344_global_singleton_audit.py -q`
Expected: PASS.

---

### Task 5: V345 architecture freeze contract

**Files:**
- Create: `docs/ARCHITECTURE_BASELINE_V345.md`
- Create: `tests/test_v345_architecture_freeze.py`

**Interfaces:**
- Produces a machine-checkable baseline for dependency direction.

- [x] **Step 1: Write failing freeze tests**

```python
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_architecture_baseline_exists():
    baseline = ROOT / 'docs/ARCHITECTURE_BASELINE_V345.md'
    assert baseline.exists()
    text = baseline.read_text(encoding='utf-8')
    for token in ('Composition Root', 'Core', 'Content', 'Learner State', 'Authentication', 'Subscription', 'Transport', 'UI'):
        assert token in text


def test_core_and_v35_have_no_singleton_lookup():
    targets = [ROOT / 'lib/core', ROOT / 'lib/ui_v35']
    for root in targets:
        for path in root.rglob('*.dart'):
            text = path.read_text(encoding='utf-8')
            assert '.instance' not in text, str(path)
```

- [x] **Step 2: Run RED**

Run: `pytest tests/test_v345_architecture_freeze.py -q`
Expected: FAIL until the baseline and any remaining forbidden lookups are closed.

- [x] **Step 3: Implement baseline/final cleanup**

Document canonical dependency directions, allowed singleton locations, compatibility exceptions, and prohibited dependencies. Close only the `.instance` lookups in Core/V35 that the test identifies; leave intentional composition-root globals alone.

- [x] **Step 4: Run GREEN**

Run: `pytest tests/test_v345_architecture_freeze.py -q`
Expected: PASS.

- [x] **Step 5: Full regression and all project gates**

Run: `pytest -q`

Run: `python tool/security_audit.py`
Run: `python tool/privacy_audit.py`
Run: `python tool/quality_audit.py`
Run: `python tool/accessibility_audit.py`
Run: `python tool/architecture_audit.py`
Run: `python tool/weakness_gate.py`

Expected: all pass. Record Flutter/Dart availability accurately.
