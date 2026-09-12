# Service Dependency Injection Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remove hidden singleton dependencies from `WordProfileService` while preserving current behavior and incremental compatibility.

**Architecture:** `WordProfileService.build` receives `SearchIndex` and `VerbIndex` explicitly. Current UI composition supplies the existing singleton instances at the outer boundary; the service itself no longer resolves globals.

**Tech Stack:** Dart/Flutter, Python pytest regression suite, static architecture audits.

**Spec:** `docs/superpowers/specs/2026-09-11-service-dependency-injection-design.md`

## Global Constraints

- Offline-first learning behavior remains unchanged.
- `WordProfileService` must not access `SearchIndex.instance` or `VerbIndex.instance`.
- Existing singleton entry points remain valid for outer composition in this stage.
- No dependency is added.
- No content data is changed.
- No learning formulas or profile scoring behavior is changed.
- TDD is mandatory: the focused architecture test must fail before the refactor.
- No destructive cleanup of prior release archives.
- Flutter/Dart verification is reported only when the toolchain exists.

---

### Task 1: Establish the explicit service dependency contract

**Files:**
- Create: `tests/test_v336_service_dependency_injection.py`
- Modify: `lib/services/word_profile_service.dart`

**Interfaces:**
- `WordProfileService.build` consumes `SearchIndex searchIndex` and `VerbIndex verbIndex` as required named parameters.
- The service produces the same `WordProfile` values as before for identical inputs and dependency instances.

- [x] **Step 1: Write the failing test**

```python
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SERVICE = ROOT / "lib/services/word_profile_service.dart"
CORE_PAGE = ROOT / "lib/ui_v35/pages/core_pages.dart"
PROGRESS_PAGE = ROOT / "lib/ui_v35/progress_pages.dart"


def test_word_profile_service_requires_explicit_catalog_dependencies():
    text = SERVICE.read_text(encoding="utf-8")
    assert "required SearchIndex searchIndex" in text
    assert "required VerbIndex verbIndex" in text
    assert "SearchIndex.instance" not in text
    assert "VerbIndex.instance" not in text


def test_current_callers_pass_explicit_catalog_dependencies():
    core_pages = CORE_PAGE.read_text(encoding="utf-8")
    progress_pages = PROGRESS_PAGE.read_text(encoding="utf-8")
    assert "searchIndex: SearchIndex.instance" in core_pages
    assert "verbIndex: VerbIndex.instance" in core_pages
    assert "searchIndex: SearchIndex.instance" in progress_pages
    assert "verbIndex: VerbIndex.instance" in progress_pages
```

- [x] **Step 2: Run test to verify it fails**

Run:

```bash
pytest tests/test_v336_service_dependency_injection.py -q
```

Expected: FAIL because `WordProfileService` currently resolves both singleton dependencies internally and its callers do not supply them.

- [x] **Step 3: Write the minimal implementation**

Change the service signature to add:

```dart
required SearchIndex searchIndex,
required VerbIndex verbIndex,
```

Replace only these internal references:

```dart
VerbIndex.instance.rowsFor(item.german)
```

with:

```dart
verbIndex.rowsFor(item.german)
```

and:

```dart
SearchIndex.instance.topicGroups
SearchIndex.instance.skillGroups
```

with:

```dart
searchIndex.topicGroups
searchIndex.skillGroups
```

Do not alter mastery calculations, attempt filtering, ordering, limits, or `WordProfile` construction.

Update the two current callers to pass:

```dart
searchIndex: SearchIndex.instance,
verbIndex: VerbIndex.instance,
```

using the existing imports. The callers remain the composition boundary for the legacy singleton instances.

- [x] **Step 4: Run the focused test to verify it passes**

Run:

```bash
pytest tests/test_v336_service_dependency_injection.py -q
```

Expected: PASS.

- [x] **Step 5: Run the full regression suite**

Run:

```bash
pytest -q
```

Expected: zero failures.

---

### Task 2: Verify architecture and release hygiene

**Files:**
- Modify only if the focused tests reveal a real contract mismatch: `tests/test_v336_service_dependency_injection.py`
- No further production changes are planned unless verification identifies a direct regression.

**Interfaces:**
- Consumes: the explicit dependency contract from Task 1.
- Produces: verified service-level dependency direction without singleton lookup inside `WordProfileService`.

- [x] **Step 1: Run all project gates**

```bash
python tool/security_audit.py
python tool/privacy_audit.py
python tool/quality_audit.py
python tool/accessibility_audit.py
python tool/architecture_audit.py
python tool/weakness_gate.py
```

Expected: every gate reports PASS.

- [x] **Step 2: Check Flutter/Dart availability**

```bash
command -v flutter || true
command -v dart || true
```

Record absence if either executable is unavailable; do not replace a missing Flutter build with a Python claim.

- [x] **Step 3: Run the complete regression suite again after all gates**

```bash
pytest -q
```

Expected: zero failures.
