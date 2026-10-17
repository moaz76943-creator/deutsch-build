# AGENTS.md — DEUTSCH بالعربي

All agents, coding assistants, OpenCode sessions, and automation working in this repository MUST follow:

- `docs/project-record/SESSION_OPERATING_CONTRACT.md`
- `docs/project-record/PROJECT_INTENT.md`

## Commit and CI policy (effective 2026-10-15)

- Never add CI-skip tokens (including `[skip ci]`, `[ci skip]`, `[no ci]`, `[skip actions]`, `[actions skip]`) or `skip-checks: true` to **new** commit messages, whether created by Jules, Gemini, Antigravity, or an automated workflow.
- Do not skip mandatory GitHub Actions or treat `SKIPPED` / `NOT_RUN` as a passing test. Optimize costs with focused tests, caching, and bounded concurrency, not commit-level suppression.
- Keep historical commits unchanged. For older PRs with skip directives, use a reviewed, non-skipping integration tip and validate the exact head before merge; never force-push Jules branches to rewrite their history.
- Follow the repository's actual branch and task CI contracts; this notice does not activate disabled workflows or authorize paid services.

Before any mutation:
1. verify this is the canonical repository `sali97m-cpu/deutsch-bilarabi`;
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

