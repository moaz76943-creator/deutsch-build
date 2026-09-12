# V114 — Mastery, Actionable Next Step & Content Expansion

- Restores per-word mastery metrics in `WordProfile` and derives them from `Mastery.forItem`.
- Adds an actionable next-step card to the Smart Teacher dashboard using the learner's weakest skill and lowest-mastery item in that skill.
- Cleans known Arabic generation defects while preserving existing item IDs.
- Adds 40 curated A1-level vocabulary items: 20 verbs and 20 supporting nouns/adjectives/adverbs.
- Keeps all learning state local and preserves existing progress IDs.

Verification: Python static suite and content uniqueness/quality checks must pass before release packaging. Flutter APK is not claimed unless Flutter SDK is available and a real build succeeds.

Release: 1.61.0+71.
