# Canonical vocabulary ingestion (Track 4)

Offline Python 3.10+ utility. Run from the repository root:

    python tools/ingestion/build_canonical_lexicon.py --check
    python tools/ingestion/build_canonical_lexicon.py
    python -m unittest discover -s tools/ingestion -p 'test_*.py'

By default, the script writes **12 original editorial starter entries per language**
(8 tagged A1, 4 tagged A2) for `en`, `fr`, `es`, `tr`, and `ar`.
These are illustrative linguistic data **not official/complete CEFR wordlists**.
The script never downloads data, calls AI APIs, or installs dependencies.

For a production-sized dataset, use reviewed, redistribution-licensed JSON or
JSONL input (repeat `--input` as needed):

    python tools/ingestion/build_canonical_lexicon.py --input licensed_words.jsonl --languages fr --check
    python tools/ingestion/build_canonical_lexicon.py --input licensed_words.jsonl --languages fr

Each line/entry has these fields (including the required `cefr` level):

    {
      "id": "fr-a1-bonjour",
      "surface": "bonjour",
      "partOfSpeech": "interjection",
      "languageCode": "fr",
      "textDirection": "ltr",
      "definitions": [{"languageCode": "fr", "text": "Formule de salutation"}],
      "translations": [{"languageCode": "ar", "text": "مرحبًا"}],
      "examples": [{"text": "Bonjour !", "translationLanguageCode": "ar", "translation": "مرحبًا!"}],
      "cefr": "A1",
      "sourceRef": "your-reviewed-corpus",
      "license": "your-redistribution-license"
    }

JSON input may be an array or an object containing `entries`; JSONL has one
object per line. A1/A2 tags and provenance are provided by the source; the
factory validator checks structural correctness, **not lexical correctness,
license compliance, or CEFR accreditation**. No automatic pivot translation
is performed. Definitions are in the source language, and all translations
identify their explicit language.

Output files, produced on local execution, follow:

    assets/content/packs/<lang>/canonical/<lang>-1.0.0.json

The eight ingestion record keys are normalized into the existing factory source
envelope (`schemaVersion`, `pack`, `requiredLocalizationKeys`,
`localization`, `lexicon`, `grammar`). The canonical information lives in
each lexicon entry's `fields`, and the pack source is checked twice using the
repository's actual `validate_source_document()`: in memory and after JSON
round-trip. Failed validation prevents all writes. UTF-8 deterministic output,
stable starter IDs, duplicate-ID rejection, direction/fallback gates, atomic
single-file replacement, and SHA-256 output reporting are built in.

Existing files with identical bytes are left alone; different existing files
are never overwritten without explicit `--force`. Use `--check` to verify
without writing. No asset files are committed by this track, to preserve the
strict repository modification scope of `tools/ingestion/`.

The local focused tests inject a lightweight shape stub to exercise ingestion
logic; they are *not* a substitute for running `--check` against the actual
factory in the full checkout before merge/promotion.
