# DEUTSCH بالعربي — Universal Session / Chat / Agent Operating Contract

## Status
OWNER APPROVED / PERMANENT CROSS-CHAT OPERATING CONTRACT

## Why this exists
A chat, scheduled worker, OpenCode process, or coding agent is disposable. Its private conversation context is not project state.

The permanent unit is:

**TASK_ID + OWNER + MUTABLE_SCOPE + STATE + EVIDENCE + CHECKPOINT + NEXT_ACTION**

No session is allowed to rely on “I remember what I was doing” as the only continuity mechanism.

## Mandatory boot — before any project mutation
Every chat/agent/worker that will change code, documentation, Notion state, CI, PRs/issues, automation, or another durable project surface MUST:

1. Read the current durable state:
   - GitHub live branch/PR/issue relevant to the task.
   - actual CI/test/checkpoint evidence.
   - CURRENT PROJECT RECORD.
   - ENGINEERING_STATE when engineering is involved.
   - CONTINUITY_PROTOCOL.
   - CENTRAL ORCHESTRATION LEDGER when ownership/parallel work matters.
2. Reconcile existing ownership before writing.
3. Determine or reuse a stable TASK_ID.
4. Record/confirm:
   - OWNER
   - BRANCH/PR
   - MUTABLE_SCOPE
   - current STATE
   - NEXT_ACTION
5. If ownership, branch, or state is ambiguous: **READ-ONLY / RECONCILE**.

## Mandatory movement capture
Meaningful project movement MUST become durable outside the current conversation.

Approved movement states:

**CLAIM → DELTA → BLOCKER / HANDOFF → COMPLETE / FAILED / SUPERSEDE**

Record a movement when any of these changes:
- task ownership;
- mutable scope;
- branch/PR/issue target;
- implementation state;
- verified evidence;
- blocker/root cause;
- next action;
- completion/failure/supersession;
- an approved decision changes an existing contract.

Do NOT log every chat message or speculative thought. Log every meaningful state transition.

Minimum record:

**TASK_ID | SOURCE | OWNER | BRANCH/PR | MUTABLE_SCOPE | STATE | EVIDENCE | NEXT_ACTION | BLOCKER | LAST_SEEN**

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
A confirmed reusable problem is added/updated in the Troubleshooting Registry:

**Symptom → Root Cause → Solution/Workaround → Verification → Reuse Rule → Status → Evidence → Last verified**

Do not create duplicate entries for the same root cause.

## Locator rule
If finding the correct file, command, page, workflow, issue, PR, or contract takes meaningful time, add/update one entry in the Central Source / Agreement / Activity Locator.

## Collision prevention
- one mutable scope = one owner;
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
