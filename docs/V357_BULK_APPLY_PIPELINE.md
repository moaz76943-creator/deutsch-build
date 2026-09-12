# V357 — Bulk Apply / Compiler Pipeline

V357 turns a reviewed bulk content batch into canonical editable JSON and deterministic generated Dart content.

## Workflow

1. Prepare and review a batch:

```text
python3 tool/content_ingestion.py prepare-batch --source <batch.json> --output <review.json>
```

2. Apply an approved review file:

```text
python3 tool/content_ingestion.py apply-batch --source <review.json>
```

The apply step validates the complete batch before changing canonical sources, writes the merged JSON and audio manifest, compiles the content with `tool/content_compiler.py`, and verifies row-for-row parity before publishing generated Dart files.

## Safety contract

- Existing content IDs and verb keys cannot be overwritten.
- Audio entries are keyed by `contentId` and cannot be duplicated.
- Audio paths must be relative and cannot traverse upward.
- Failed validation does not mutate canonical sources.
- Compilation/parity failure restores canonical sources from the transaction backup.
- Generated Dart remains a deterministic build artifact; editable JSON remains the source of truth.
- Existing learner IDs and learning state are not rewritten by the import pipeline.

## Scope

V357 prepares the pipeline for bulk vocabulary, verb, and audio ingestion. It does not activate dynamic multi-language runtime selection and does not migrate existing audio assets.
