# V360 — Content Authoring Schema

V360 adds a human-friendly authoring format above the existing V359 reviewable batch contract. It is designed for preparing large vocabulary and verb additions without forcing the author to reproduce the internal compiler schema.

## Authoring shape

```json
{
  "version": 1,
  "languageCode": "de",
  "entries": [],
  "verbs": []
}
```

### Vocabulary entries

Entries use readable fields:

- `id` — required stable content ID.
- `word` and `translation` — required.
- `sentence`, `sentenceTranslation`, `topic`, `article`, `plural` — optional and default to empty strings.
- `skill` — defaults to `recall` when omitted.
- `accepted` — defaults to the word when omitted.
- `audio` — optional object containing `word`, `sentence`, and/or `pronunciation` relative paths.

IDs are never auto-generated or rewritten. This keeps stable IDs explicit and reviewable.

### Verbs

Verb header data is written once, while conjugations are grouped under `forms`:

```json
{
  "infinitive": "sein",
  "arabic": "يكون",
  "group": "1. الأفعال الأساسية",
  "forms": [
    {
      "person": "ich",
      "personAr": "أنا",
      "form": "bin",
      "past": "bin gewesen",
      "pastArabic": "كنتُ",
      "example": "Ich bin müde.",
      "exampleAr": "أنا متعب.",
      "pastExample": "Ich bin müde gewesen.",
      "pastExampleAr": "كنتُ متعبًا."
    }
  ]
}
```

## Workflow

```text
authoring.json
    ↓
content_authoring.py prepare
    ↓
reviewable V359 batch.json
    ↓
review
    ↓
content_ingestion.py publish-batch
```

Preparation is read-only with respect to canonical content. It rejects duplicate IDs, duplicate verb rows, unsupported fields, and unsafe audio paths before writing the review output.

## Command

```bash
python3 tool/content_authoring.py prepare \
  --source content/german/batches/my_authoring.json \
  --output /tmp/german-batch-review.json
```

The generated file intentionally uses the existing V359 batch contract, so V360 does not create a second publishing pipeline.
