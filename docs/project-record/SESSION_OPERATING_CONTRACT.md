# DEUTSCH بالعربي — Universal Session / Chat / Agent Operating Contract

## Status
OWNER APPROVED / PERMANENT CROSS-CHAT OPERATING CONTRACT

## Why this exists
A chat, scheduled worker, OpenCode process, or coding agent is disposable. Its private conversation context is not project state.

The permanent unit is:

**TASK_ID + OWNER + MUTABLE_SCOPE + STATE + EVIDENCE + CHECKPOINT + NEXT_ACTION**

No session is allowed to rely on “I remember what I was doing” as the only continuity mechanism.

## Minimal boot — risk-proportionate execution (owner update 2026-10-15)

Read-only inspection requires no CLAIM, task creation, or coordination writes.

Before a mutation, verify only the *relevant* current GitHub HEAD, task/PR, changed files, applicable CI, and ownership of overlapping paths. Reuse an existing TASK_ID and existing PR/Issue when available. Record OWNER, BASE_SHA, MUTABLE_SCOPE and acceptance criteria in that existing surface.

Consult CURRENT PROJECT RECORD, ENGINEERING_STATE, CONTINUITY_PROTOCOL or CENTRAL ORCHESTRATION LEDGER **when the task actually depends on their decisions, shared ownership or recovery state**, not as compulsory repeated reads for unrelated small changes. Never create another ledger, coordinator, or task solely to satisfy a process ritual.

Non-overlapping agents can work concurrently. A demonstrated mutable-file conflict means READ-ONLY / RECONCILE for *that scope only*; continue independent safe work. Missing critical security, rights, loss-prevention, or branch-protection evidence remains blocking.

Tests follow risk: documentation-only gets applicable docs/policy gates; small code change gets affected tests and blocking analyzer; Android/offline/release gets its build, integrity and integration checks. Required GitHub checks/reviews remain mandatory; NOT_RUN/SKIPPED are never PASS.

## Movement capture without duplicate bureaucracy

Keep durable evidence of meaningful transitions: **CLAIM → DELTA → BLOCKER / HANDOFF → COMPLETE / FAILED / SUPERSEDE**.

A GitHub commit, PR, required check or Issue comment is already durable evidence: do not manually copy it into extra ledgers. Add a checkpoint only when ownership, recovery, acceptance, an unrecoverable blocker, or a decision cannot be reconstructed from existing evidence. Update the existing authoritative project record where a cross-project decision truly changes.

Minimum *when a separate checkpoint is needed*: **TASK_ID | OWNER | BRANCH/PR | SCOPE | STATE | EVIDENCE | NEXT_ACTION**. Add BLOCKER and LAST_SEEN only when relevant. Do not record every command, chat turn, or speculative thought.

## Write-before-exit law
A session that made a meaningful mutation may not finish with its only evidence inside the chat.

Before it stops, hands off, or reports completion, it must leave durable evidence in at least one authoritative surface:
- GitHub commit/PR/issue/CI evidence;
- Project Record event/checkpoint;
- Notion CURRENT PROJECT RECORD / relevant state page for coordination or decisions.

For code work, GitHub evidence is mandatory. Notion alone never proves code state.

## Resume law
At the start of a new session:
- same TASK_ID + no terminal state = **RESUME**;
- COMPLETED = **DO NOT REPEAT**;
- FAILED = classify/reconcile before retry;
- BLOCKED = continue independent work or handoff;
- ambiguous ownership = **READ-ONLY**.

Changing chat, model, device, or hour does not create a new task.

## Cross-chat rule
No chat may assume it can read another chat's internal context.

Instead:
- every chat reads durable state;
- every chat writes meaningful movement to durable state;
- the Central Orchestrator reconciles only durable evidence;
- invisible/unrecorded claims are treated as **UNVERIFIED**.

## Problem-learning rule
Only a confirmed *recurring* root cause that is not already documented should update the existing Troubleshooting Registry:

**Symptom → Root Cause → Solution/Workaround → Verification → Reuse Rule → Status → Evidence → Last verified**

Do not create duplicate entries for the same root cause.

## Locator rule
Use the existing locator only when a repeatedly costly discovery justifies it. A one-off lookup does not require another record.

## Collision prevention
- one *overlapping* mutable scope = one owner; unrelated scopes may advance concurrently;
- another owner’s branch/PR/path = READ-ONLY until handoff;
- shared file mutations are serialized;
- no reset/clean/revert/delete/force-push against unknown work;
- unknown critical state = STOP / RECONCILE.

## Evidence hierarchy
1. live canonical GitHub code/branch/PR;
2. actual CI/tests/build/audit evidence;
3. verified checkpoint/project-record evidence;
4. CURRENT PROJECT RECORD / ENGINEERING_STATE;
5. approved Notion decisions/architecture;
6. conversation text is temporary context only.

## Automation boundary
Technical GitHub movements should be captured automatically where existing Project Record workflows/hooks already support them.
OpenCode uses the verified local bridge/hook when available.
Chat-only decisions cannot be captured by GitHub automatically; therefore any chat that changes a decision/state must write the durable coordination record before exit.

## Completion rule
No chat/agent may claim a task COMPLETE unless:
- acceptance criteria are satisfied;
- required verification is real;
- evidence is durable;
- next action or terminal state is recorded;
- no conflicting ownership remains unresolved.

**Evidence > Claim. Correct Progress > Architecture Accumulation.**
