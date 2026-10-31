# V359 — Audio + Content Batch Publication

V359 adds the publication boundary that combines a reviewed content batch with its physical audio assets.

## Batch layout

A publication directory contains a reviewed `batch.json` plus the audio files referenced by its audio entries:

```text
batch/
  batch.json
  pronunciation/de-100.mp3
  sentence/de-100.mp3
```

The paths in `batch.json` are relative to the batch directory. They must remain inside that directory and use a supported audio extension.

## Publication

```text
python3 tool/content_ingestion.py publish-batch --source <batch-directory>
```

Publication validates content, verbs, audio references, target collisions, compiles generated Dart, and then commits content, the audio manifest, generated Dart, and audio files as one transaction with backups for rollback.

Existing content IDs, verb rows, audio content IDs, and target audio paths are never overwritten by publication.

A failed validation or publication leaves the existing content, manifest, generated output, and audio tree unchanged.

## Scope

V359 does not migrate the existing corpus or invent audio files. The current German catalog remains unchanged until an actual reviewed batch is supplied.
