# V384 — Language Boundary Closure

## Goal
Move the remaining German-specific behavior out of generic service boundaries while preserving the current German runtime behavior.

## Changes
- Added neutral `LanguageContentDepth`, with `GermanContentDepth` owning the existing German enrichment data.
- Added neutral `LanguageWritingAnalyzer`, with `GermanWritingAnalyzer` owning the existing German structural checks.
- Added neutral `LanguageSpeechProfile`, with `GermanSpeechProfile` owning German TTS locale/error policy.
- Updated `SafeTtsController` to consume a language speech profile instead of hardcoding German locale selection.
- Neutralized search result match-type identifiers (`exactSource`, `containsSource`, `tokenSource`, etc.).
- Kept German compatibility facades isolated and prevented new active-runtime imports.
- Updated historical regression contracts that were superseded by the new ownership boundary.

## Data Safety
- Canonical content was not intentionally mutated.
- No credentials, learner data, signing material, or private repository data were added to source files.
- The GitHub repository remains private.

## Verification

Canonical content SHA-256: `e670c55dcc24cee45345d037707147f5e553b185bd4ddeebbcdde43f6b6971e8`

- Targeted V384/language-boundary tests: PASS.
- Architecture audit: PASS.
- Security audit: PASS.
- Privacy audit: PASS.
- Accessibility audit: PASS.
- Weakness gate: PASS.
- Content quality: PASS.
- Compiler parity: PASS — 14,813 content rows / 11,718 verb rows.
- Flutter/Android build: not executed locally because the Flutter SDK is unavailable.
