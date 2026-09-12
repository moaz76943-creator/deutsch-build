# V242 — SearchIndex via ContentEngine

## Goal

Move exactly one real runtime consumer, `SearchIndex`, from a direct dependency on
`a1` to the existing `ContentEngine` boundary without changing the default source.

## Change

- `SearchIndex` now builds from `ContentEngine.instance.items`.
- The direct `a1` import was removed from `search_index.dart`.
- `ContentEngine` still defaults to `LegacyContentSource`, so the current runtime
  behavior remains unchanged unless `DEUTSCH_JSON_CONTENT=true` is explicitly used.
- Added `tests/test_v242_search_index_content_engine.py` as a structural behavioral
  boundary test.

## Safety boundary

No content rows were edited, deleted, reordered, or migrated in this stage.
The JSON/generated source remains opt-in and the legacy source remains the default.

## Verification

Focused V242 test: PASS after an observed red failure.
Existing SearchIndex/performance tests: PASS.
