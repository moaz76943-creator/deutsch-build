# Core Domain Isolation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make `lib/core/` independent of service implementation layers while preserving existing service import compatibility.

**Architecture:** Canonical deterministic domain primitives move under `lib/core/`. Existing `lib/services/*` entry points become compatibility facades that export those core implementations, so dependencies flow from services to core rather than core to services.

**Tech Stack:** Dart 3.x, Flutter project, Python pytest regression suite, static architecture audits.

**Spec:** `docs/superpowers/specs/2026-09-11-core-domain-isolation-design.md`

## Global Constraints

- Offline-first learning behavior remains unchanged.
- Core must not import service, UI, data, platform, network, authentication, or subscription implementation layers.
- Existing service import paths remain compatible through exports.
- No dependency is added.
- No generated content is edited.
- No secrets, credentials, tokens, or production endpoints are introduced.
- TDD is mandatory: the architecture test must fail before production refactoring.
- Flutter/Dart build commands are not claimed unless the toolchain exists in the execution environment.
- No destructive cleanup of prior release archives.

---

### Task 1: Establish the core dependency-direction test

**Files:**
- Create: `tests/test_core_domain_isolation.py`

**Interfaces:**
- Consumes: Dart source files under `lib/core/`.
- Produces: a regression test that rejects upward imports from core.

- [ ] **Step 1: Write the failing test**

```python
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CORE = ROOT / "lib" / "core"
FORBIDDEN_IMPORT_MARKERS = (
    "../services/",
    "../ui",
    "../data/",
    "package:flutter/",
    "dart:io",
)


def test_core_does_not_depend_on_upper_layers():
    violations = []
    for path in sorted(CORE.rglob("*.dart")):
        for line_no, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
            if line.strip().startswith(("import ", "export ")) and any(
                marker in line for marker in FORBIDDEN_IMPORT_MARKERS
            ):
                violations.append(f"{path.relative_to(ROOT)}:{line_no}: {line.strip()}")
    assert not violations, "Core layer has upward/platform dependencies:\n" + "\n".join(violations)
```

- [ ] **Step 2: Run the test to verify it fails**

Run:

```bash
pytest tests/test_core_domain_isolation.py -q
```

Expected: FAIL because `lib/core/learning_core.dart` currently imports service implementations.

---

### Task 2: Canonicalize text normalization and content quality in core

**Files:**
- Create: `lib/core/text_normalizer.dart`
- Create: `lib/core/content_quality.dart`
- Modify: `lib/services/text_normalizer.dart`
- Modify: `lib/services/quality.dart`
- Modify: `lib/core/learning_core.dart`
- Test: `tests/test_core_domain_isolation.py`

**Interfaces:**
- `TextNormalizer.answer(String value) -> String`
- `ContentQuality.issues(ContentItem) -> List<String>`
- `ContentQuality.validate(ContentItem) -> List<String>`
- `ContentQuality.isLearnable(ContentItem) -> bool`
- Existing service symbols remain available through exports.

- [ ] **Step 1: Implement minimal canonical core files**

Move the existing implementations without changing logic, imports, or validation rules except their relative model import paths.

- [ ] **Step 2: Replace service implementations with compatibility exports**

```dart
export '../core/text_normalizer.dart';
```

and:

```dart
export '../core/content_quality.dart';
```

- [ ] **Step 3: Change `LearningCore` to import the core primitives**

Use:

```dart
import 'text_normalizer.dart';
import 'content_quality.dart';
```

instead of service imports for those primitives.

- [ ] **Step 4: Run focused regression**

```bash
pytest tests/test_core_domain_isolation.py -q
```

Expected: PASS for the dependency rule.

---

### Task 3: Canonicalize SRS, memory, and mastery in core

**Files:**
- Create: `lib/core/srs.dart`
- Create: `lib/core/memory.dart`
- Create: `lib/core/mastery.dart`
- Modify: `lib/services/srs.dart`
- Modify: `lib/services/memory.dart`
- Modify: `lib/services/mastery.dart`
- Modify: `lib/core/learning_core.dart`
- Test: `tests/test_core_domain_isolation.py`

**Interfaces:**
- Preserve `Srs`, `MemoryQueue`, `MemorySnapshot`, `MemoryReviewReason`, `Mastery`, and `MasteryEvidence` exactly as currently consumed.
- Core implementations depend only on `dart:math` where needed and learner models.
- Existing service paths re-export canonical core symbols.

- [ ] **Step 1: Move `Srs` implementation to `lib/core/srs.dart`**

Retain the current schedule, update, priority, retrievability, and bounding behavior exactly.

- [ ] **Step 2: Move `MemoryQueue` and `MemorySnapshot` to `lib/core/memory.dart`**

Change only the SRS import to `core/srs.dart`.

- [ ] **Step 3: Move `Mastery` and `MasteryEvidence` to `lib/core/mastery.dart`**

Retain all formulas and thresholds exactly.

- [ ] **Step 4: Convert service files to compatibility exports**

```dart
export '../core/srs.dart';
export '../core/memory.dart';
export '../core/mastery.dart';
```

- [ ] **Step 5: Update `LearningCore` imports to local core primitives**

```dart
import 'memory.dart';
import 'mastery.dart';
```

- [ ] **Step 6: Run the full regression suite**

```bash
pytest -q
```

Expected: all tests pass with no import mismatch or behavior regression.

---

### Task 4: Verify architectural boundaries and release hygiene

**Files:**
- Modify only if required: `tests/test_core_domain_isolation.py`
- No production changes unless a test identifies a real boundary violation.

**Interfaces:**
- Consumes: canonical core primitives and compatibility service facades.
- Produces: verified one-way core dependency boundary.

- [ ] **Step 1: Run the architecture test**

```bash
pytest tests/test_core_domain_isolation.py -q
```

Expected: PASS.

- [ ] **Step 2: Run the full regression suite**

```bash
pytest -q
```

Expected: zero failures.

- [ ] **Step 3: Run project gates**

```bash
python tool/security_audit.py
python tool/privacy_audit.py
python tool/quality_audit.py
python tool/accessibility_audit.py
python tool/architecture_audit.py
python tool/weakness_gate.py
```

Expected: every gate reports PASS.

- [ ] **Step 4: Confirm Flutter toolchain availability**

```bash
command -v flutter || true
command -v dart || true
```

If unavailable, explicitly record that Flutter/Dart verification was not executable; do not substitute Python tests for a Flutter build claim.

- [ ] **Step 5: Create a non-destructive V335 architecture archive**

Archive the current workspace excluding all prior `v*_release_archive` directories and runtime/build caches. Verify the resulting archive is readable and contains the new core files and test.

- [ ] **Step 6: Calculate SHA-256**

```bash
sha256sum /mnt/data/work_v279/v279/v335_release_archive/deutsch_bilarabi_v335_core_domain_isolation_verified.zip
```

Record the exact output in the final report.
