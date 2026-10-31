# Deutsch بالعربي — Editable Content Packs

These JSON files are the **editable, reviewable content representation** introduced in V237.

- `content_items.json` — vocabulary/content items.
- `verb_conjugations.json` — verb conjugation rows.
- `content_pack.schema.json` — schema definitions for both datasets.

## Safe migration rule

V237 does **not** switch the running app to read JSON directly. The existing Dart data remains the runtime source for this stage, and the JSON packs are an extracted, validated representation. This avoids risking the existing learning catalogue while the new content engine is introduced incrementally.

Before changing a JSON pack, run:

```bash
python3 tool/content_pack.py validate
```

To refresh the packs from the current Dart catalogue:

```bash
python3 tool/content_pack.py export
```

The CI gate will be able to validate the packs before any later stage makes them runtime-canonical.

## Canonical JSON/CSV ingestion

New vocabulary authoring should use `tools/content_ingestion_engine.py`.
It accepts UTF-8 JSON or CSV and compiles the rows into the existing canonical
language-pack document consumed by `tools/language_pack_factory.py`.

Raw JSON/CSV is a **build-time authoring format**. Production runtime remains the
admitted indexed SQLite corpus, so large datasets are not decoded into the UI
isolate.

Required fields:

- `id`
- `level` — `A1`, `A2`, `B1`, or `B2`
- `german`
- `arabic`

Optional fields:

- `partOfSpeech`, `article`, `plural`
- `exampleGerman`, `exampleArabic`
- `topic`, `skill`, `register`
- `accepted` — JSON array or `|`-delimited CSV cell

Example:

```bash
python3 tools/content_ingestion_engine.py \
  --input content/german/batches/core_a1.csv \
  --output content/german/generated/core_a1.pack-source.json \
  --pack-id de-core-a1 \
  --version 1.0.0
```

The compiler writes CEFR into `fields.canonical.cefr` and maps the learner-facing
text fields to the existing SQLite migration contract
(`translation`, `example`, `exampleTranslation`, `topic`, `skill`,
`article`, `plural`, and `accepted`). Duplicate IDs, unsupported levels,
unknown columns/keys, malformed IDs, and unsupported register/article values
fail closed.

## Language-owned ingestion manifest (V355)

Each language may declare a small manifest under `content/<language>/` that
identifies its editable vocabulary, verb and audio sources. The manifest is a
build-time boundary; validation never rewrites the existing catalogue.

For German, validate it with:

```bash
python3 tool/content_ingestion.py validate
```

Audio is referenced by stable `contentId` in `audio_manifest.json`. Audio files
remain ordinary assets and are not embedded into Dart source or treated as
secrets. Future bulk imports can populate this manifest without changing the
learning engine.
