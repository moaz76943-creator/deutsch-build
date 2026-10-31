# V100 — Smart Word Profile

- Version: 1.48.0+58
- Content: 14,520 entries
- Added `WordProfile` model for dictionary learning context.
- Dictionary entries now expose Artikel/Plural, example, related verb forms, related topic words, and local learning state.
- Review state is derived from the learner SRS card; attempt and error counts are shown without changing saved IDs.
- Verb conjugation data is reused when the searched content entry matches an infinitive.
- Added static regression coverage for the profile contract and dictionary integration.

Flutter/Android build remains environment-dependent and must be verified in a Flutter-enabled CI/device environment.
