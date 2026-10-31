# V99 — Vocabulary Intelligence

- Version: 1.47.0+57
- Base content: 14,520 entries
- Added `VocabularyCoach` to rank learnable vocabulary using due SRS cards, repeated errors, recent errors, hints, and unseen items.
- Improved `SearchIndex` with token-aware German/Arabic matching after exact and field-level matches.
- Integrated the vocabulary coach into `LearningEngine` so new/consolidation selections use the same learner-aware ranking.
- Existing content IDs remain unchanged.
- Flutter SDK was not available in this environment, so Android build verification remains pending.
