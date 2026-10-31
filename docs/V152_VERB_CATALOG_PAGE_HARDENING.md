# V152 Verb Catalog & Page Hardening

## Goal
Reduce repeated verb-catalog work on the V35 verb pages and repair split-page structural corruption discovered during the audit.

## Changes
- `VerbConjugationPage` now consumes the cached `VerbIndex.instance.groups` and `VerbIndex.instance.infinitives` instead of rebuilding maps and unique-verb sets from the complete corpus on every `build()`.
- `VerbFavoritesPage` resolves favorite rows through `VerbIndex.instance.rowsFor()` instead of filtering the complete verb corpus.
- `SharedPreferences.getInstance()` is initialized once as a future in the verb page state and reused by load/toggle operations.
- `VerbIndex.groups` is materialized once and returned directly rather than allocating a new map on every getter access.
- Verb-index construction no longer creates a temporary spread list containing every verb row.
- Removed accidental duplicate `DeutschAppV35` declarations from split V35 page files and restored the TTS `dispose()` method to the verb page state instead of leaving it outside the class.

## Verification
- V152 focused tests: 6 passed.
- Affected historical tests: 20 passed.
- Full Python regression suite: 246 passed, 0 failed.
- `compileall` remains available for Python tooling; Flutter/Dart compilation and Android runtime verification require a Flutter SDK/emulator, which are not available in this environment.

## Non-goals
This version does not claim Android runtime correctness, TalkBack verification, or Dart analyzer/build success without those tools.
