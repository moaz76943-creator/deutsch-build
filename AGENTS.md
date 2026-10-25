# AGENTS.md — DEUTSCH بالعربي

All agents, coding assistants, OpenCode sessions, and automation working in this repository MUST follow:

- `docs/project-record/SESSION_OPERATING_CONTRACT.md`
- `docs/project-record/PROJECT_INTENT.md`

## Commit and CI policy (updated 2026-10-24)

- Commit messages may include `[skip ci]`, `[ci skip]`, `[no ci]`, `[skip actions]`, `[actions skip]` or `skip-checks: true` when chosen by the author. Their presence alone does not reject a PR or invalidate tested code.
- GitHub may suppress automatic `push` and `pull_request` workflow runs for these markers. Never misreport an absent, skipped or stale required check as PASS; use an eligible manually verified or non-skipping integration tip when GitHub needs to run a required check, preserving original commits.
- Keep existing branch protection, relevant exact-SHA quality tests, signing, learner data and licensing checks. Do not bypass them or authorize paid services; use focused testing to conserve time.
- Preserve history without force-pushing merely to remove a message marker. Keep PR and SHA receipts in the existing workflow, avoiding duplicate approval paperwork.

Before any mutation:
1. verify this is the private application repository `moaz76943-creator/deutsch-build` (integration target `staging/v2-full-platform`); use `moaz76943-creator/-offline-packs-store` only for the separate public content factory (`main`);
2. inspect live branch/PR/CI state;
3. reconcile task ownership and mutable scope;
4. reuse the existing TASK_ID when work is already active;
5. treat another owner’s branch/PR/path as READ-ONLY until durable handoff.

After meaningful movement:
- leave durable evidence;
- record CLAIM / DELTA / BLOCKER / HANDOFF / COMPLETE / FAILED / SUPERSEDE as applicable;
- do not let the chat/session be the only record of work.

Never use destructive reset/clean/revert/delete/force-push for recovery.
Unknown critical state => STOP / RECONCILE.
Evidence > Claim.

MULTILINGUAL ARCHITECTURE & CONTENT SPECIFICATION
DEUTSCH بالعربي is built on a tripartite multilingual model:
[Shared Core] + [Language Intelligence] + [Directed Pair Intelligence]

1. DIRECTED PAIR RULES:
- USER_LANGUAGE != SOURCE_LANGUAGE != TARGET_LANGUAGE.
- Direction matters: (A -> B) is NOT identical to (B -> A).
- German (DE) is our initial reference implementation, NOT a universal schema.
- NEVER silently pivot through German or English when processing other language pairs.
- The platform targets 100 registered languages with language-specific intelligence and directed A→B pair isolation; a registered language is not a verified installed pack, and directed pairs must not be pre-materialized as an O(N²) matrix.

2. LINGUISTIC & CONTENT INTEGRITY:
- German Grammatical Metadata:
  * Noun genders and articles must remain intact: der (maskulin), die (feminin), das (neutral).
  * Preserve complete case inflections: Nominativ, Akkusativ, Dativ, Genitiv.
  * Preserve verb inflection rules, including separable prefixes (trennbare Verben) and auxiliary verbs for Perfekt (haben vs. sein).
- Arabic Explanations:
  * Maintain culturally and grammatically accurate Modern Standard Arabic explanations for German linguistic phenomena.
  * Candidate content remains unverified until backed by automated validation checks.

3. ANDROID APPLICATION INTEGRATION (TRACK D):
- Code changes must preserve clean architecture separation: Data Layer, Domain/Core, and UI/Presentation.
- Keep Gradle dependency configurations clean and verify that data models match the schema defined in the Shared Core.
