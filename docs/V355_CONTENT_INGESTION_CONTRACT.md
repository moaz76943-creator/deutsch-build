# V355 — Language Content Ingestion Contract

## Purpose

V355 establishes a language-owned, build-time manifest for editable learning
content. It is the first content-management boundary for the future goal of
adding or replacing a learning language without changing the learning core.

## Contract

Each learning language can own `content/<language>/content_manifest.json` with:

- `languageCode` — stable language identifier.
- `contentItems` — editable vocabulary/content source.
- `verbConjugations` — editable verb source.
- `audioManifest` — stable-ID references to optional pronunciation/sentence
  audio assets.

German currently keeps the existing validated JSON catalog untouched and uses a
manifest under `content/german/` to identify those sources. This is deliberate:
V355 establishes the boundary without moving or rewriting the 14,813 existing
records.

## Audio safety

Audio references are keyed by `contentId`, not by list position. Paths are
relative and cannot be absolute or escape the repository. The current audio
manifest is intentionally empty; future imports may populate it without
changing the learning engine or content IDs.

## Validation

```bash
python3 tool/content_ingestion.py validate
```

The gate verifies manifest structure, source existence, current catalog
cardinality, stable IDs, verb cardinality, and audio-entry shape. Validation is
read-only and does not rewrite content sources.

## Verification snapshot

- Content items: 14,813
- Unique content IDs: 14,813
- Verb rows: 11,718
- Audio entries: 0 (contract established, no audio migration yet)
- Full Python regression: 537 passed
- Security audit: PASS
- Privacy audit: PASS
- Accessibility audit: PASS (0 warnings)
- Architecture audit: PASS
- Quality audit: PASS
- Weakness gate: PASS
