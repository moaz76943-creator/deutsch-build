# SearchIndex Dependency Isolation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Isolate `SearchIndex` from global content and verb singletons while preserving a temporary compatibility facade.

**Architecture:** `SearchIndex` becomes a dependency-explicit engine. `LegacySearchIndex` owns composition of `ContentEngine.instance` and `VerbIndex.instance`, so legacy callers can migrate gradually without reintroducing global coupling into the engine.

**Tech Stack:** Flutter/Dart source, Python pytest architecture/regression tests.

**Spec:** `docs/superpowers/specs/2026-09-11-search-index-dependency-isolation-design.md`

## Global Constraints

- No search behavior changes.
- No content schema changes.
- No subscription/auth changes.
- No new package dependencies.
- Keep the migration incremental; do not rewrite all UI construction in one step.

---

### Task 1: Isolate SearchIndex construction and verb dependency

**Files:**
- Modify: `lib/services/search_index.dart`
- Create: `lib/services/search_index_legacy.dart`
- Create: `tests/test_v337_search_index_dependency_isolation.py`
- Modify: `tests/test_v242_search_index_content_engine.py`

**Interfaces:**
- `SearchIndex(List<ContentItem> items, VerbIndex verbIndex)` becomes the explicit engine constructor.
- `LegacySearchIndex.instance` returns one compatibility `SearchIndex` built from the current `ContentEngine.instance.items` and `VerbIndex.instance` sources.

- [ ] **Step 1: Write the failing tests**

```python
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SEARCH = ROOT / "lib/services/search_index.dart"
LEGACY = ROOT / "lib/services/search_index_legacy.dart"


def test_search_index_has_no_global_content_or_verb_singletons():
    text = SEARCH.read_text(encoding="utf-8")
    assert "content_engine.dart" not in text
    assert "ContentEngine.instance" not in text
    assert "VerbIndex.instance" not in text


def test_search_index_requires_explicit_dependencies():
    text = SEARCH.read_text(encoding="utf-8")
    assert "SearchIndex(this._items, this._verbIndex)" in text
    assert "final VerbIndex _verbIndex;" in text


def test_legacy_facade_owns_singleton_composition():
    text = LEGACY.read_text(encoding="utf-8")
    assert "ContentEngine.instance.items.toList(growable: false)" in text
    assert "VerbIndex.instance" in text
    assert "SearchIndex(" in text
```

- [ ] **Step 2: Run the focused test to verify RED**

Run: `pytest tests/test_v337_search_index_dependency_isolation.py -q`

Expected: FAIL because the current `SearchIndex` imports and resolves the global singletons and no legacy facade exists.

- [ ] **Step 3: Implement the minimal engine/facade split**

Change `SearchIndex` so the constructor is:

```dart
SearchIndex(this._items, this._verbIndex);

final List<ContentItem> _items;
final VerbIndex _verbIndex;
```

Remove the `content_engine.dart` import and the `static instance` implementation from `SearchIndex`. Replace the verb lookup with:

```dart
final verbInfinitives = _verbIndex.infinitivesFor(q);
```

Create `search_index_legacy.dart`:

```dart
import '../models/content.dart';
import 'content_engine.dart';
import 'search_index.dart';
import 'verb_index.dart';

final class LegacySearchIndex {
  LegacySearchIndex._();

  static SearchIndex? _instance;

  static SearchIndex get instance => _instance ??= SearchIndex(
        ContentEngine.instance.items.toList(growable: false),
        VerbIndex.instance,
      );
}
```

- [ ] **Step 4: Update callers from `SearchIndex.instance` to `LegacySearchIndex.instance` without changing behavior**

Replace only the existing application-level singleton references in `lib/ui_v35/pages/core_pages.dart` and `lib/ui_v35/progress_pages.dart`. Do not change search queries, limits, or result handling.

- [ ] **Step 5: Update the old architectural test to assert the new boundary**

Replace the obsolete V242 assertion requiring `ContentEngine` inside `SearchIndex` with assertions that the direct corpus literals remain absent and the legacy facade owns source composition.

- [ ] **Step 6: Run focused tests to verify GREEN**

Run: `pytest tests/test_v337_search_index_dependency_isolation.py tests/test_v242_search_index_content_engine.py -q`

Expected: PASS.

- [ ] **Step 7: Run the full regression suite**

Run: `pytest -q`

Expected: all collected tests pass with zero failures.

- [ ] **Step 8: Re-scan architecture and secret boundaries**

Run:

```bash
python3 tools/security_audit.py
python3 tools/privacy_audit.py
python3 tools/content_quality_audit.py
python3 tools/accessibility_audit.py
python3 tools/architecture_audit.py
```

Expected: every audit reports PASS; no secret-bearing data is introduced.

- [ ] **Step 9: Create a non-destructive release archive and SHA-256**

Create the archive under `v337_release_archive/` while excluding prior release archive directories, then compute SHA-256 with `sha256sum`.

---
