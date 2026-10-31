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

---

# Kaikki / Wiktionary bulk lexicon harvester

`fetch_kaikki_lexicon.py` creates **candidate** canonical source files for
`tools/language_pack_factory.py`. It does not certify linguistic quality,
translation accuracy, licensing compliance, or CEFR coverage.

Run from the repository root (Python 3.10+, standard library only):

```sh
python tools/ingestion/fetch_kaikki_lexicon.py \
  --lang en --limit 5000 --input /path/to/english.jsonl.gz \
  --frequency-file /path/to/english_frequency.csv \
  --output-dir assets/content/packs
```

To download an explicit HTTPS URL instead of using an existing local dump:

```sh
python tools/ingestion/fetch_kaikki_lexicon.py \
  --lang fr --limit 5000 --url 'https://kaikki.org/.../download.jsonl.gz' \
  --max-download-mb 4096 --output-dir assets/content/packs
```

Use source files from the **English-language Wiktionary edition** as extracted
by Kaikki/Wiktextract: its glosses are English, enabling the requested fallback.
The `--gloss-lang none` option disables English gloss fallback when using
other Wiktionary editions (unless English translations are explicitly present).
The utility accepts JSONL, JSON arrays, `.jsonl.gz`, and `.json.gz`. JSONL
is streamed; single large JSON arrays are loaded in memory. Bulk downloads
can be several gigabytes; `--url` is explicit and capped by default at 1024 MiB.

Frequency data is optional but strongly recommended: CSV with `word,rank`,
optionally `cefr,lang`. Rank 1 is the most frequent. CEFR labels must be
source-backed (A1, A2, B1); higher levels are excluded. If the input has no
ranking or CEFR evidence, selection is deterministic but **not** a beginner
vocabulary frequency list. Kaikki does **not** guarantee CEFR/rank annotations.

Outputs are written atomically in 250-entry batches by default under:

```
assets/content/packs/<lang>/canonical/<lang>-1.0.0.json
```

The document has `schemaVersion=1`, pack metadata, localized pack title,
`lexicon` entries, and an empty `grammar` list, matching the current
`language_pack_factory.py` input contract. Each lexical item includes a
canonical CEFR field (or `unknown`), language-labelled translation with
provenance (`ar` preferred, otherwise `en`), source attribution, and stable ID.
No machine translation is synthesized. For a release-ready pack, independently
review senses, translations, CEFR, coverage, offensive usages, and attribution.

Wiktionary content is subject to attribution/share-alike obligations; review
the current source's license terms before distributing generated packs. Kaikki
and Wiktextract should be credited; original Wiktionary contributors should be
attributed as required by the applicable license. This script only produces
candidate data and deliberately does not publish or sign it.

Focused offline test:

```sh
python -m unittest discover -s tools/ingestion -p 'test_*.py' -v
```

No GitHub Actions or paid services are required for harvesting or tests.

---

# SQLite pack schema 2.0.0 (post-materialization)

`inject_schema_v2.py` upgrades an existing SQLite pack **without changing the
source**, after normal SQLite materialization but **before** computing package
hashes, signing the archive, or updating the store manifest.

```sh
python tools/ingestion/inject_schema_v2.py \
  --source /path/to/content.sqlite \
  --output /path/to/content-v2.sqlite

python -m unittest discover -s tools/ingestion -p 'test_inject_schema_v2.py' -v
```

The new SQLite file includes `lexicon.cefr_level` (TEXT),
`lexicon.frequency_rank` (INTEGER), `lexicon.sort_key` (TEXT),
`idx_lexicon_cefr_freq`, a standalone `lexicon_fts` (FTS5 trigram) with
Arabic-only translation indexing, and the `verbs`, `verb_conjugations`,
`idioms`, `nominals`, `nominal_declensions` tables. Morphology definitions
mirror the existing language-neutral verb and declension schemas.

Unknown CEFR and frequency information remains NULL; it is never invented.
Unicode sort keys use NFKC + casefold (not locale-aware ICU collation).
Trigram substring matches require at least three characters; an ordinary
NOCASE index exists for supported prefix fallbacks.

The injector rejects missing or conflicting schema, unsupported FTS5, malformed
metadata, or output overwrite. Run it only on a **new pack destination**;
repackage and recalculate SHA-256/size afterward. Older entrypoints that call
`tools/language_pack_sqlite.py` directly still create their historical schema
until their callers are explicitly routed through this v2 step. Do not label
those unconverted artifacts schema 2.0.0.

---

# Tier-1 Kaikki pilot fetch → deterministic SQLite pack build

Work from the `tools/ingestion` directory (Python 3.10+, stdlib only):

```sh
cd tools/ingestion
python3 fetch_kaikki_pilot.py
python3 build_pilot_packs.py build --input-dir inputs --out-dir production
```

The fetcher streams bounded candidate records for `en`, `de`, `es`, `fr`,
and `tr` from the *English Wiktionary edition* as served by Kaikki.org.
It stops after at most 100,000 source lines or 6,000 accepted entries per
language (256 MiB decompressed scan limit); it does **not** download entire
multi-gigabyte dictionaries. It writes `inputs/<lang>.jsonl` and refuses to
overwrite differing existing data. The generator writes `.pack.gz` and
`manifest.json` under `production/` and similarly refuses destructive
overwrites. Neither script publishes to the offline store or triggers CI.

For **network-free** input harvesting, place Kaikki-derived `en.jsonl[.gz]`,
`de.jsonl[.gz]`, etc. in a separate local directory, then run:

```sh
python3 fetch_kaikki_pilot.py --source-dir /path/to/licensed/dumps
python3 build_pilot_packs.py build --input-dir inputs --out-dir production \
  --rankings-dir /path/to/verified/frequency-csv
```

The optional CSVs use `word,rank[,cefr]`; frequency ranks and CEFR labels
must come from independently reviewed evidence. Source-order truncation is
**not** a frequency-ranked/core vocabulary. These are unreviewed **pilot
candidates**, not certified or release-ready packs; the maximum 3,000 built
entries are not guaranteed to be the most common 3,000 words. The command
`build` is optional for backwards compatibility with older callers.
Inspect sources and recording obligations in
`assets/data/licensing_ledger.json` before redistributing data. Wiktionary
material may require attribution and CC BY-SA share-alike compliance.

Local focused checks, no CI or APK build:

```sh
python3 -m unittest test_fetch_kaikki_pilot.py test_build_pilot_packs.py
```
