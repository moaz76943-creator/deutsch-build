# V111 — Targeted Repair + Content Expansion

Version: 1.58.0+68

## Implemented

- Mistake repair now maps the detected error dimension to a matching practice mode:
  - listening → listening
  - production/writing → production
  - translation/grammar/word order → transfer
  - article/vocabulary → recall
- CoreSession now preserves an explicitly planned session mode instead of replacing it with the item's base skill.
- Added a curated expansion file with 55 new content entries: 50 previously absent conjugated verb forms with source examples and Arabic meanings, plus 5 new nouns with Artikel and plural.
- Existing content IDs remain untouched; new IDs continue after the existing dataset.
- Quality audit was extended to include the V111 expansion file so future duplicate/corruption checks cover all content.
- Release metadata advanced to 1.58.0+68.

## Verification

- `pytest -q test/tool`: PASS
- Quality Audit: PASS
- Security Audit: PASS
- Flutter build: not run because the current execution environment has no Flutter SDK.
