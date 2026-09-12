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
