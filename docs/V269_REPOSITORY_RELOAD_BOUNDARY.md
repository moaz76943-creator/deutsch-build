# V269 — Repository Reload Boundary

## Goal

Provide an explicit persistence-truth boundary for `LearnerRepository` when another
persistence actor may have changed the underlying local store after the repository
cache was populated.

## Change

Added `LearnerRepository.reload()`:

1. invalidate `_cachedState`;
2. delegate to the existing `load()` path;
3. return the freshly loaded normalized state.

Normal `load()` remains cached, preserving existing runtime behavior and avoiding
unnecessary local-storage reads. Callers that explicitly need storage truth can use
`reload()` without reaching into the persistence adapter or cache internals.

## TDD evidence

Focused test before implementation:

- `tests/test_v269_repository_reload_boundary.py`
- Result: **1 failed, 1 passed**
- Decisive failure: `LearnerState reload()` did not exist.

After the minimal implementation:

- Focused result: **2 passed**

## Verification

- Full regression: **265 passed**
- Content: **14,813** entries
- Unique IDs: **14,813**
- Unique German entries: **14,813**
- Verbs: **11,718**
- Privacy audit: PASS
- Security audit: PASS
- Quality audit: PASS
- Accessibility audit: PASS — 0 warnings
- Architecture audit: PASS
- Weakness gate: PASS
- Python compileall: PASS
- Bash syntax: PASS
- Content compiler command validation: PASS

Flutter/Android/APK/AAB were not built because the current execution environment
does not provide the required Flutter/Android toolchain.

## Test-maintenance note

Five historical tests contained hard-coded paths to obsolete `/mnt/data/work_v238`
or `/mnt/data/work_v240/work_v238` workspaces. They were changed to derive the
current repository root from `__file__`. No production behavior was weakened.
