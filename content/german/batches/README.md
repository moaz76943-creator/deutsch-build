# German bulk content batches

A batch is an external, reviewable input to `tool/content_ingestion.py prepare-batch`.
Preparation is read-only with respect to the canonical catalog: it validates the
batch and writes only the requested review output.

## Shape

```json
{
  "version": 1,
  "languageCode": "de",
  "contentItems": [],
  "verbConjugations": [],
  "audio": []
}
```

`contentItems` use the existing editable content schema. Every content ID must
be new relative to the canonical catalog and unique within the batch.

`verbConjugations` use the existing editable verb schema.

`audio` entries are keyed by `contentId`; optional `word`, `sentence`, and
`pronunciation` values are safe relative paths. Audio references must point to a
content item included in the same batch.

## Prepare a batch

```bash
python3 tool/content_ingestion.py prepare-batch \
  --source content/german/batches/example.json \
  --output /tmp/german-batch-review.json
```

The command does not append records to the canonical catalog. A later stage can
add an explicit, separately reviewed apply/import operation.

## Human-friendly authoring

For large additions, use `authoring_template.json` and convert it into the
same reviewable batch contract before publication:

```bash
python3 tool/content_authoring.py prepare \
  --source content/german/batches/my_authoring.json \
  --output /tmp/german-batch-review.json
```

The authoring format keeps vocabulary fields readable and groups verb forms
under each infinitive. It does not replace the V359 batch/publishing contract.
