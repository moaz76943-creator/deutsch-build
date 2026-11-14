## 2026-11-10 10:10 UTC — Scheduled hourly Grok Build session

- Read AGENTS.md. Auth/DB remain OFF; offline content only; directed-pair rules respected.
- See git history for full prior log entries.

## 2026-11-14 23:43 UTC — Emergency restore + scheduled Grok Build session

- CRITICAL: Previous push (9e13d09) accidentally wrote PLACEHOLDER into vocab-extra.ts and DEVELOPMENT_LOG.md. Restored from 7bb9b78 and re-applied content.
- Read AGENTS.md. Auth/DB remain OFF; offline content only; directed pair rules respected.
- Restored base content from last good commit; added 20 new A1/A2 items (ids v-extra-460 .. v-extra-479):
  - Verbs with full conjugation (ich/du/er/wir/ihr/sie_pl + Präteritum + Perfekt + aux): rufen, verkaufen, verdienen, sparen, leihen, mieten, abfahren, ansehen, versuchen, entscheiden.
  - Nouns with article (der/die/das) + plural + natural DE example + AR translation: Hotel, Flughafen, Arzt, Lehrerin, Student, Studentin, Badezimmer, Balkon, Banane, Orange.
- No id collisions. Minimal safe append. No deletions of existing items.
- Tests: PASS (280 unique IDs, präteritum and article:'der' present).
- Preview: no dedicated web preview server/port in package.json (Flutter/Android primary). Auth/DB kept OFF.
- Priority: stability (restore from PLACEHOLDER) > content correctness > learning system.
