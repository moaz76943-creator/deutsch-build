# V349 — German Content Namespace Migration

**Baseline:** V348 — German Language Pack at Composition Root

## Change

German runtime content sources were moved to the canonical language-specific namespace:

```text
content/german/
content/german/generated/
```

The legacy `lib/data` paths remain as compatibility-only export shims so existing package consumers do not break during the staged migration.

All runtime imports were migrated to the canonical German namespace. Build-time content tooling now reads the canonical source location.

## Integrity

- 14,813 content entries preserved.
- 14,813 unique IDs preserved.
- 14,813 unique German entries preserved.
- No content values or IDs were intentionally changed.
- SRS, Mastery, search behavior, and learning behavior were not changed.

## Verification

- Focused V349 tests: PASS.
- Full pytest regression: **505 passed**.
- Content quality audit: **PASS** (14,813 entries / IDs / German entries).
- Flutter/Dart analyze and APK build: not run because Flutter/Dart is unavailable in the execution environment.

## Compatibility

The move is deliberately staged. Legacy exports are retained until downstream consumers no longer require the old path. They contain no canonical content tables.
