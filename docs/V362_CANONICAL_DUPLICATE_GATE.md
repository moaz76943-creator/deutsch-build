# V362 — Canonical Duplicate Gate

V362 strengthens the V361 content quality boundary by detecting normalized German headword collisions both inside a submitted batch and against the existing canonical German corpus.

## Normalization

German headwords are normalized with Unicode NFC, case folding, and whitespace collapsing. This catches editorial duplicates such as `lernen`, ` LERNEN `, and equivalent casing/spacing variants without attempting linguistic equivalence or fuzzy matching.

## Safety boundary

- The check is review-only and never edits canonical content.
- A collision is a publication-blocking error.
- Arabic translations are not used as a uniqueness key because multiple German words may legitimately share a translation.
- No fuzzy/semantic matching is claimed; linguistic review remains a human responsibility.
- Existing stable IDs are preserved.

## Flow

`Authoring → Batch → Quality Gate → Canonical Duplicate Gate → Publish`

`publish-batch` supplies the current canonical content file to the quality gate, so the same protection applies to direct publication.

## Commands

Review a batch against the canonical corpus:

```bash
python3 tool/content_quality_gate.py review \
  --source path/to/batch.json \
  --content content/content_items.json
```
