# V364 — Content Batch Diff & Preview

V364 adds a read-only preview boundary for reviewable content batches. It compares a batch with the current canonical content, verb-conjugation source, and audio manifest before publication.

The preview reports planned additions for content, verbs, and audio, and explicit conflicts for existing IDs, existing normalized German entries, existing verb rows, existing audio entries, and schema/canonical-source problems. It never mutates canonical sources.

## Usage

```bash
python3 tool/content_diff.py \
  --source path/to/batch.json \
  --content content/german/content_items.json \
  --verbs content/german/verb_conjugations.json \
  --audio-manifest content/german/audio_manifest.json
```

Use `--report path/to/preview.json` to save the structured preview.

A zero exit status means the batch has no detected preview conflicts. A non-zero exit status means publication should not proceed until the conflicts are resolved.

V364 is intentionally preview-only. It does not alter SRS, mastery, learner state, IDs, canonical content, generated Dart, or audio assets.
