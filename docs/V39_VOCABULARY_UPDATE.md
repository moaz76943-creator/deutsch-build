# v39 — Vocabulary expansion and quality pass

- Total vocabulary records: 1000.
- Final validation: 1000 records, 1000 unique German headwords (case-insensitive), and 1000 unique IDs.
- Added 500 new unique German headwords to the 500-item base.
- Duplicate check performed on German headwords before insertion.
- Corrected the malformed `ellf` entry to `elf`.
- Corrected the malformed `nichts` record so it has no bogus plural field.
- Preserved Arabic translations, example sentences, topics, skills, articles and plurals where supplied.
- The added batch is curated educational vocabulary rather than generated placeholder strings.
- This pass does not claim that every lexical field has been externally corpus-verified; further linguistic QA is still appropriate before Play Store release.
