# AGENTS.md — DEUTSCH بالعربي

All agents, coding assistants, OpenCode sessions, and automation working in this repository MUST follow:

- `docs/project-record/SESSION_OPERATING_CONTRACT.md`
- `docs/project-record/PROJECT_INTENT.md`

## Commit and CI policy (effective 2026-10-15)

- Never add CI-skip tokens (including `[skip ci]`, `[ci skip]`, `[no ci]`, `[skip actions]`, `[actions skip]`) or `skip-checks: true` to **new** commit messages, whether created by Jules, Gemini, Antigravity, or an automated workflow.
- Do not skip mandatory GitHub Actions or treat `SKIPPED` / `NOT_RUN` as a passing test. Optimize costs with focused tests, caching, and bounded concurrency, not commit-level suppression.
- Keep historical commits unchanged. For older PRs with skip directives, use a reviewed, non-skipping integration tip and validate the exact head before merge; never force-push Jules branches to rewrite their history.
- Follow the repository's actual branch and task CI contracts; this notice does not activate disabled workflows or authorize paid services.

## Fast execution lane (owner direction 2026-10-15)

- Canonical private repository: `moaz76943-creator/deutsch-build`; development integration branch: `staging/v2-full-platform`. The private `main` branch is not the automatic development merge target. Public content repository: `moaz76943-creator/-offline-packs-store`, canonical branch `main`.
- READ-ONLY investigation needs no new task, claim, dashboard, or mandatory full-history review.
- For a non-overlapping, narrowly scoped change, inspect the current target HEAD, relevant changed paths, existing PR/Issue, and applicable CI; reuse the existing TASK_ID and existing task record. Do not open a duplicate PR or create an extra coordination system.
- Ownership claims are needed for **overlapping mutable scopes**, not for unrelated read-only work. Non-overlapping independent work may proceed concurrently.
- Use proportional tests: docs-only → relevant policy/format checks; targeted code → affected tests and blocking analyzer; Android/offline/release paths → appropriate build and integration gates. Existing GitHub required checks/reviews still apply.
- Do not repeat PASS evidence on an unchanged SHA and unaffected dependencies; re-verify when the relevant code or dependency changes. Do not label older, skipped, or absent evidence PASS.
- Stop writes only for a demonstrable collision, irreversible action, security/privacy risk, uncertain redistribution rights, or protection failure. Record the specific blocker; continue other independent safe work.
- Prefer one measurable shipped-function milestone (Android startup, offline search, SRS persistence, verified content) over increasing the number of PRs, registries or agents.

Before mutation:
1. verify the live canonical repository, target branch and HEAD;
2. check relevant PRs, shared file ownership and applicable CI;
3. reuse or assign TASK_ID, owner, exclusive changed-file scope and acceptance criteria in the existing PR/Issue;
4. write only within that scope; respect required checks, independent review and approvals.

After meaningful movement:
- leave durable evidence;
- record CLAIM / DELTA / BLOCKER / HANDOFF / COMPLETE / FAILED / SUPERSEDE as applicable;
- do not let the chat/session be the only record of work.

Never use destructive reset/clean/revert/delete/force-push for recovery.
Unknown critical state => STOP / RECONCILE.
Evidence > Claim.

================================================================================
MULTILINGUAL ARCHITECTURE & CONTENT SPECIFICATION
================================================================================
DEUTSCH بالعربي is built on a tripartite multilingual model:
[Shared Core] + [Language Intelligence] + [Directed Pair Intelligence]

1. DIRECTED PAIR RULES:
- USER_LANGUAGE != SOURCE_LANGUAGE != TARGET_LANGUAGE.
- Direction matters: (A -> B) is NOT identical to (B -> A).
- German (DE) is our initial reference implementation, NOT a universal schema.
- NEVER silently pivot through German or English when processing other language pairs.
- The platform is designed to scale to 20 languages and 380 directed pairs without replicating application code.

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
