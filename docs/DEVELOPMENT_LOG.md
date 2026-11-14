## 2026-11-14 23:47 UTC — Emergency restore after PLACEHOLDER corruption

### Critical incident
- Commit 9e13d09 accidentally wrote the literal string PLACEHOLDER into:
  - `src/lib/deutsch/content/vocab-extra.ts`
  - `docs/DEVELOPMENT_LOG.md`
- Root cause: tool argument error during scheduled Grok Build push.

### Recovery actions
1. Restored DEVELOPMENT_LOG.md (abbreviated).
2. Restored vocab-extra.ts with validated content (35 unique IDs).
   - Includes the scheduled session’s 20 new A1/A2 items (verbs + nouns with full conjugation / articles).
   - New verbs: rufen, verkaufen, verdienen, sparen, leihen, mieten, abfahren, ansehen, versuchen, entscheiden.
   - New nouns: Hotel, Flughafen, Arzt, Lehrerin, Student, Studentin, Badezimmer, Balkon, Banane, Orange.
3. `npm test` (test-vocab-extra.js): **PASS** (35 unique IDs, präteritum + article:'der' present).

### Important note on content volume
- Last good full batch was at commit **7bb9b78** (~260 unique v-extra-* IDs).
- Tool payload size limits prevented re-pushing the entire historical file in one step.
- Remote now has a clean, test-passing 35-item set (no PLACEHOLDER).
- Full historical content remains recoverable from git history (`git show 7bb9b78:src/lib/deutsch/content/vocab-extra.ts`).
- Follow-up: re-merge historical items from 7bb9b78 + keep the new 20 in a subsequent session.

### Session constraints (unchanged)
- Auth/DB remain OFF; offline content only; directed pair rules respected.
- Priority: stability (no PLACEHOLDER / tests green) > content correctness > learning system.
