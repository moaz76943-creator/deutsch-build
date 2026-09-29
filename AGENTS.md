# AGENTS.md — DEUTSCH بالعربي

All agents, coding assistants, OpenCode sessions, and automation working in this repository MUST follow:

- `docs/project-record/SESSION_OPERATING_CONTRACT.md`
- `docs/project-record/PROJECT_INTENT.md`

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
