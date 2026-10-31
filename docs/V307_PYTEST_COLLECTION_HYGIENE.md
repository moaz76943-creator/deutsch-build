# V307 — Pytest Collection Hygiene

## Problem

The repository had no pytest configuration, so invoking `pytest` from the project root also discovered tests embedded inside historical release archives. That caused duplicate-module/import-mismatch collection errors even though the live project test suite was healthy.

## Change

Added `pytest.ini` with:

```ini
[pytest]
testpaths = tests
```

This makes the live `tests/` tree the default pytest collection root while preserving the explicit `python -m pytest -q tests` command used by the build/test gates.

## Verification

- Focused V307 regression: PASS.
- Root `pytest --collect-only -q`: 391 tests collected, 0 collection errors.
- Full live regression: 391 passed.

No Flutter/Android build was run because the current environment does not contain the Flutter/Dart/Gradle toolchain.
