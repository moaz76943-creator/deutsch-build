# Design: Pytest Collection Hygiene

## Goal

Make a root-level pytest invocation deterministic and limited to the live project tests, without deleting historical release archives.

## Constraints

- Preserve all historical release archives.
- Do not alter application behavior.
- Keep existing explicit build/test commands valid.
- Prevent archive-contained tests from participating in default collection.

## Decision

Use standard pytest configuration with `testpaths = tests`.

## Rejected alternatives

- Deleting historical archives: unnecessary and destructive.
- Adding ignore patterns for every archive directory: brittle as releases accumulate.
- Changing only CI commands: does not fix local/root invocation behavior.

## Test-first evidence

`tests/test_v307_pytest_collection_hygiene.py` was written first and failed because `pytest.ini` did not exist. The configuration was then added and the test passed.
