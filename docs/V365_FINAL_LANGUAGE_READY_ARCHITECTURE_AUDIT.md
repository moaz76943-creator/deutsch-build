# V365 — Final Language-Ready Architecture Audit

## Status

**NOT COMPLETE — targeted closure required before declaring the language-ready architecture finished.**

This audit is based on the V364 source tree and the accepted language-ready architecture specification.

## Verification baseline

- Full pytest: **578 passed**
- Flutter/Dart build status: not claimed; Flutter toolchain is not available in this environment.
- Canonical content: 14,813 items
- Verb rows: 11,718
- Audio entries: 0

## Findings

### 1. Core still contains German-specific content quality logic — BLOCKER

`lib/core/content_quality.dart` imports `ContentItem` and contains explicit German/Arabic schema and German linguistic heuristics, including German sentence patterns, Artikel validation, separable-verb rules, German typo rules, and Arabic contamination checks.

**Required direction:** move the language-specific quality implementation behind a language-facing quality contract. Core must consume a language-neutral quality capability rather than German rules.

### 2. Core text normalization still contains German-specific behavior — BLOCKER

`lib/core/text_normalizer.dart` transliterates `ä/ö/ü/ß`. This is a German-language normalization policy, not a language-agnostic algorithm.

**Required direction:** introduce a language normalization contract and move German normalization into the German adapter while preserving answer-matching behavior byte/behaviorally where practical.

### 3. Shared services still depend directly on German-shaped fields — BLOCKER

Several services still reference `.german`, `.arabic`, `.sentenceAr`, `.article`, `.plural`, `TextNormalizer`, or `ContentQuality` directly. The largest remaining surfaces are `search_index.dart`, `content_intelligence.dart`, `verb_index.dart`, `word_profile_service.dart`, `reading_practice.dart`, `learning_engine.dart`, and `vocabulary_coach.dart`.

**Required direction:** migrate these services incrementally to language-neutral projections/capabilities supplied by the language boundary.

### 4. UI still contains direct German content assumptions — BLOCKER for a strict declaration

The UI contains direct German/Arabic field usage and German-specific labels/scenarios in shared surfaces.

Some language presentation work is already isolated, but the audit cannot declare the boundary complete while shared UI code still reads German-shaped fields directly.

**Required direction:** finish projection/presentation isolation without changing learner behavior.

### 5. Compatibility tests still encode old Core coupling — CLEANUP REQUIRED

Existing architecture tests deliberately preserve earlier migration checkpoints, including assertions that `LearningCore`/`services/quality.dart` use the old compatibility quality facade.

**Required direction:** replace checkpoint assertions with final-boundary assertions only after the production migration is completed, without weakening regression coverage.

## What is already complete

The audit confirms that the following architectural layers are in place:

- `LearningContent` neutral contract
- `LanguagePack`
- `GermanLanguagePack`
- German content namespace
- language-specific exercise strategy
- language-aware conversation presentation
- real-world presentation boundary
- placement presentation boundary
- language content pack
- bulk content ingestion/apply pipeline
- audio validation and atomic publication
- authoring schema
- content quality gate
- canonical duplicate gate
- review queue
- batch diff/preview

## Decision

The project is **architecturally close but not yet complete** under the original acceptance criteria.

The next implementation stages should focus only on closing the blockers above. No new content-management feature should be added until these final language-boundary leaks are addressed.

Recommended order:

1. V366 — Language Normalization Contract
2. V367 — Language Content Quality Contract
3. V368 — Shared-Service Content Projection Migration
4. V369 — Final UI Language Boundary Cleanup
5. V370 — Final Architecture Gate and regression freeze

A final completion claim should only be made when the final gate proves that Core and shared algorithms contain no German-specific implementation dependencies.
