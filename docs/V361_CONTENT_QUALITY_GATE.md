# V361 — Content Quality Gate

V361 adds a review-only editorial quality gate between the V360 authoring/batch format and publication.

## Flow

`Authoring → Batch → Quality Gate → Publish`

The gate does not mutate canonical content and does not rewrite the submitted batch.
A failed gate blocks `publish-batch` before any canonical source, generated output, or audio asset is changed.

## Checks

- Exact V359 batch schema.
- Required content fields: `id`, `german`, `arabic`, `skill`.
- Non-empty accepted forms, including the German headword.
- sentence/sentenceAr must be supplied together.
- Stable, unique content IDs inside the batch.
- Required verb identity fields: `infinitive`, `arabic`, `person`, `form`.
- Stable, unique verb rows keyed by infinitive/person/form.
- Example and Arabic example must be supplied together.
- Past example and Arabic past example must be supplied together.
- Audio references must point to content IDs in the same batch and must be unique.

Missing audio is a warning, not an error, because editorial review may happen before recordings are available.

## Human review boundary

The gate intentionally does **not** claim linguistic correctness. Grammar, translation quality, naturalness, and pedagogical suitability remain human/editorial review responsibilities.

The gate is `review_only`: it reports defects and never silently corrects, deletes, renumbers, or rewrites content.

## Commands

Review a prepared batch:

```bash
python3 tool/content_quality_gate.py review --source path/to/batch.json
```

Write the report to a file:

```bash
python3 tool/content_quality_gate.py review --source path/to/batch.json --report path/to/review.json
```

`publish-batch` invokes the same gate before mutation, so publication cannot bypass this boundary.
