# V338 Composition Root Search Dependencies Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Move creation of `SearchIndex` and `VerbIndex` dependencies into the V35 composition root and inject them into migrated UI pages without changing search behavior.

**Architecture:** `main.dart` creates the explicit search graph once and stores the shared references in `AppDependencies`. V35 pages consume `AppDependencies`-derived services directly; `LegacySearchIndex` remains only as a compatibility facade for unmigrated callers.

**Tech Stack:** Flutter/Dart source, Python pytest architecture/regression tests, repository security and architecture audits.

**Spec:** `docs/superpowers/specs/2026-09-11-v338-composition-root-search-dependencies-design.md`

## Global Constraints

- No change to search scoring, limits, sorting, tokenization, morphology, or fuzzy behavior.
- No content data changes.
- No new package dependency.
- No removal of `LegacySearchIndex` in this stage.
- No secrets, credentials, or learner state in `AppDependencies`.
- Migration remains incremental; only current V35 search consumers are migrated.

---

### Task 1: Establish composition-root dependency contract

**Files:**
- Create: `lib/services/app_dependencies.dart`
- Modify: `lib/main.dart`
- Modify: `lib/ui_v35/app.dart`
- Test: `tests/test_v338_composition_root_search_dependencies.py`

**Interfaces:**
- Produces `AppDependencies({required SearchIndex searchIndex, required VerbIndex verbIndex})`.
- `DeutschAppV35` consumes `AppDependencies dependencies` as a required constructor argument.

- [x] **Step 1: Write the failing architecture test**

```python
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MAIN = ROOT / "lib/main.dart"
APP = ROOT / "lib/ui_v35/app.dart"


def test_main_owns_explicit_search_composition():
    text = MAIN.read_text(encoding="utf-8")
    assert "SearchIndex(" in text
    assert "VerbIndex.instance" in text
    assert "SearchIndex.instance" not in text
    assert "final dependencies = AppDependencies(" in text
    assert "runApp(DeutschAppV35(repo, auth: auth, dependencies: dependencies))" in text


def test_app_receives_search_dependencies_instead_of_legacy_facade():
    text = APP.read_text(encoding="utf-8")
    assert "final AppDependencies dependencies;" in text
    assert "required this.dependencies" in text
    assert "search_index_legacy.dart" not in text
    assert "LegacySearchIndex" not in text
```

- [x] **Step 2: Run the focused test to verify RED**

Run:

```bash
pytest tests/test_v338_composition_root_search_dependencies.py -q
```

Expected: FAIL because the composition root and V35 constructors do not yet expose the explicit dependency container.

- [x] **Step 3: Implement the minimal composition contract**

Create `AppDependencies` with only:

```dart
final class AppDependencies {
  const AppDependencies({
    required this.searchIndex,
    required this.verbIndex,
  });

  final SearchIndex searchIndex;
  final VerbIndex verbIndex;
}
```

In `main.dart`, construct `SearchIndex(ContentEngine.instance.items.toList(growable: false), VerbIndex.instance)`, create `AppDependencies`, and pass it to `DeutschAppV35`.

In `DeutschAppV35` and `HomeV35`, accept and forward `AppDependencies`.

- [x] **Step 4: Run the focused test to verify GREEN**

Run:

```bash
pytest tests/test_v338_composition_root_search_dependencies.py -q
```

Expected: PASS.

---

### Task 2: Migrate V35 search consumers

**Files:**
- Modify: `lib/ui_v35/pages/core_pages.dart`
- Modify: `lib/ui_v35/progress_pages.dart`
- Modify: `lib/ui_v35/app.dart`
- Test: `tests/test_v338_composition_root_search_dependencies.py`

**Interfaces:**
- `CategoriesPage`, `SearchDictionaryPage`, `ReadingPracticePage`, and `LearningDashboardPage` consume explicit `SearchIndex`/`VerbIndex` dependencies.
- `_NextStepCard` consumes the same explicit dependencies from its parent.

- [x] **Step 1: Extend the architecture test for consumer migration**

```python
CORE = ROOT / "lib/ui_v35/pages/core_pages.dart"
PROGRESS = ROOT / "lib/ui_v35/progress_pages.dart"


def test_core_pages_receive_explicit_search_dependencies():
    text = CORE.read_text(encoding="utf-8")
    assert "search_index_legacy.dart" not in text
    assert "LegacySearchIndex" not in text
    assert "final SearchIndex searchIndex;" in text
    assert "final VerbIndex verbIndex;" in text


def test_progress_pages_receive_explicit_search_dependencies():
    text = PROGRESS.read_text(encoding="utf-8")
    assert "search_index_legacy.dart" not in text
    assert "LegacySearchIndex" not in text
    assert "final SearchIndex searchIndex;" in text
    assert "final VerbIndex verbIndex;" in text
```

- [x] **Step 2: Run the test to verify RED**

Run:

```bash
pytest tests/test_v338_composition_root_search_dependencies.py -q
```

Expected: FAIL because V35 pages still import/call the legacy facade.

- [x] **Step 3: Pass dependencies from `HomeV35` into search consumers**

Use the existing `widget.dependencies.searchIndex` and `widget.dependencies.verbIndex` values for:

```dart
CategoriesPage(...)
SearchDictionaryPage(...)
ReadingPracticePage(...)
LearningDashboardPage(...)
```

Update `WordProfileService.build` calls to use the injected instances. Do not change query text, limits, result ordering, or profile arguments.

- [x] **Step 4: Remove V35 legacy facade references**

Remove only the `search_index_legacy.dart` imports and `LegacySearchIndex` calls from the migrated V35 pages. Keep `lib/services/search_index_legacy.dart` unchanged for compatibility callers.

- [x] **Step 5: Run focused architecture tests**

Run:

```bash
pytest tests/test_v338_composition_root_search_dependencies.py -q
```

Expected: PASS.

---

### Task 3: Full verification and release hygiene

**Files:**
- Create/modify only as required by a failing verification contract.

**Interfaces:**
- Consumes: V338 explicit composition graph.
- Produces: verified V35 dependency direction with legacy facade retained but unused by V35.

- [x] **Step 1: Verify all V35 references**

Run:

```bash
grep -RIn --exclude-dir='v*_release_archive' -E 'LegacySearchIndex|search_index_legacy.dart|SearchIndex\\.instance' lib/ui_v35 lib/main.dart || true
grep -RIn --exclude-dir='v*_release_archive' 'LegacySearchIndex' lib | head -n 100
```

Expected: no V35/main references; remaining references belong only to the compatibility facade and historical tests/docs.

- [x] **Step 2: Run full regression**

Run:

```bash
pytest -q
```

Expected: zero failures.

- [x] **Step 3: Run project gates**

Run:

```bash
python tool/security_audit.py
python tool/privacy_audit.py
python tool/quality_audit.py
python tool/accessibility_audit.py
python tool/architecture_audit.py
python tool/weakness_gate.py
```

Expected: all gates report PASS.

- [x] **Step 4: Check Flutter/Dart availability**

Run:

```bash
command -v flutter || true
command -v dart || true
```

Record the actual environment state; do not claim a Flutter build when the toolchain is absent.

- [x] **Step 5: Run the complete regression suite again**

Run:

```bash
pytest -q
```

Expected: zero failures.

- [x] **Step 6: Create a non-destructive V338 release archive and SHA-256**

Create the archive from the current project while excluding all `v*_release_archive/` directories and transient caches. Compute its SHA-256 with `sha256sum` and preserve previous archives.
