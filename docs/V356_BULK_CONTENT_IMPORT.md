# V356 — Bulk Content Import Preparation

## Purpose

V356 turns the V355 ingestion boundary into a safe, reviewable bulk-content
workflow. It prepares vocabulary, verb, and audio batches without modifying
the canonical catalog.

## Command

```bash
python3 tool/content_ingestion.py prepare-batch \
  --source content/german/batches/example.json \
  --output /tmp/german-batch-review.json
```

The source batch has five top-level fields:

- `version`
- `languageCode`
- `contentItems`
- `verbConjugations`
- `audio`

Content IDs must be unique within the batch and must not collide with existing
German content IDs. Verb rows use the stable `(infinitive, person, form)` key
for duplicate detection. Audio is keyed by `contentId` and must reference a
content item from the same batch.

The operation writes only the requested review output. It does not append to or
rewrite the canonical content/verb sources. Applying a reviewed batch remains a
separate future operation so bulk ingestion cannot silently mutate learning
content.

## Verification

- Existing canonical content remains 14,813 items.
- Existing verb source remains 11,718 rows.
- Current audio manifest remains unchanged.
- Full Python regression is required before release.
