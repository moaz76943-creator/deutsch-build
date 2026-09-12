# V172 — Language Feedback Hardening

- Built directly on V171.
- Added conservative offline `WritingAnalyzer` for empty input, punctuation, sentence capitalization, common subject/verb position, and adjacent repetition.
- Reused the analyzer in the V35 writing coach instead of duplicating fragile regex checks.
- Strengthened conversation scoring with normalized token matching, conservative stem/prefix similarity, and keyword order scoring.
- Kept exact accepted answers at full credit; soft matching is only used for partial/contextual responses.
- Bumped app version to 1.84.0+94.

Verification:
- V172 focused tests: PASS.
- Full Python regression suite: 114 passed.
- Security audit: PASS.
- Quality audit: PASS (14,793 entries; unique IDs and German entries).
- Architecture audit: PASS (0 oversized UI files).
- Accessibility audit: PASS (0 warnings).
- Flutter/Android build: not locally verifiable because Flutter/Android SDK is unavailable in this environment.
