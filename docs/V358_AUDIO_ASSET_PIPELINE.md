# V358 — Audio Asset Pipeline

V358 adds a read-only validation boundary between a language-owned audio manifest and the physical audio assets under `content/german/audio`.

## Contract

- Each audio manifest entry is keyed by an existing `contentId`.
- Every declared audio path is relative and must resolve inside the language audio root.
- Every declared asset must exist as a regular file.
- The same physical asset cannot be silently represented by an unsafe path.
- Unreferenced files are rejected as orphan assets so content packs stay auditable.
- Validation never rewrites the manifest, content, generated Dart, or audio files.

## Validation

```text
python3 tool/content_ingestion.py validate-audio
```

An empty audio catalog is valid during the migration period. Existing audio files are not moved or rewritten by V358.

## Future bulk workflow

A later stage can stage audio files beside a reviewed content batch and copy them into this language-owned root only after validation. V358 deliberately does not perform that copy so asset ingestion and asset publishing remain separate, reviewable operations.
