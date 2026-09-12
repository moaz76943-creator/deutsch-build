# V141 — Runtime Memory Hardening

## Scope
Reduce avoidable runtime allocations around search, learning lookup, and speech helper lifecycle while preserving offline behavior.

## Changes
- SearchIndex exact and token indexes operate directly on `ContentItem` values; `_Entry` objects are created only for candidates that need detailed scoring.
- Removed the full `_entryById` mirror and replaced it with a bounded-by-use `_entryCache`.
- Fuzzy/trigram work remains explicitly deferred to fuzzy fallback paths.
- LearningCore's content ID map is lazy instead of eagerly allocated when the class is loaded.
- Fresh-learning selection uses bounded `focused` and `fallback` buffers instead of materializing the full unlearned corpus.
- Removed a duplicate `a1Part07` spread from the content catalog.
- VerbIndex singleton construction is lazy.
- Backward-compatible TTS helpers now share the serialized per-engine gate used by the hardened controller.

## Verification
- TDD runtime-memory contract tests: PASS
- Full Python regression suite: 218 passed, 0 failed
- Accessibility audit: PASS, 0 warnings
- Architecture audit: PASS, 0 oversized files
- Quality audit: PASS, 14,793 entries / 14,793 unique IDs / 14,793 unique German entries
- Security audit: PASS
- Weakness gate: PASS
- Content review queue remains review-only; no mutation performed

## Limitation
Flutter/Android SDK and emulator are not available in this environment, so Android startup/RAM/frame-time measurements are not claimed. The work is source-level and regression-test verified.
