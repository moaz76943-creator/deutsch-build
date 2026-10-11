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
