# DEUTSCH بالعربي — Universal Failure Control & Fast Recovery

## Purpose

This document operationalizes the existing Reliability Assurance contract. It is **not a new scheduler, worker system, persistence database, session system, or regression-memory subsystem**.

The target is simple:

**FAILURE → FINGERPRINT → CLASSIFY → SAFE FAST PATH → VERIFY → CHECKPOINT → CONTINUE**

If the failure is unknown or the state is ambiguous at a critical boundary:

**UNKNOWN → STOP / RECONCILE**

## Non-negotiable project rules

- Source-of-truth hierarchy remains unchanged.
- **Evidence > Claim.**
- Approved architecture is not implementation evidence.
- Recovery is non-destructive.
- No automatic reset/clean/revert/delete/force-push.
- Retries are bounded and classified; never retry blindly.
- The smallest sufficient model/tool is preferred.
- A failed model/provider does not restart completed work from zero.
- Task state survives session/model/process loss.
- Human approval remains required for sensitive, destructive, irreversible, production, credential/auth/payment/security, legal/tax, or ambiguous decisions.
- Do not create a fourth worker or a parallel persistence/session architecture.
- Every meaningful failure produces a reusable lesson only after the cause is supported by evidence.

## Fast path

### Tier 0 — instant deterministic recovery

Use when the failure is known, low-risk, reversible, and the next state is unambiguous.

Examples:

- transient network timeout → bounded retry
- provider quota/rate limit → route to suitable alternative and resume
- stale generated runtime record → rerun reconciliation
- duplicate/no-op execution → stop duplicate work and continue the owner task
- recoverable session/process loss → resume from the last verified checkpoint
- known dependency/toolchain mismatch → use the pinned/approved toolchain when available

The action must be followed by a focused verification. A fast repair without proof is not a repair.

### Tier 1 — automatic bounded repair

Use when a known playbook requires several safe steps.

Sequence:

1. preserve current task state;
2. snapshot/checkpoint when required;
3. apply only an allowlisted repair path;
4. run focused verification;
5. record evidence;
6. continue only if the state is verified.

### Tier 2 — autonomous diagnosis + repair proposal

Use for a new but diagnosable failure.

The system collects:

- failure fingerprint;
- task/session/worker correlation;
- repository revision;
- relevant command/tool/model/provider;
- state before/after;
- last verified step;
- evidence;
- attempted repairs and outcomes.

Then it proposes the smallest safe repair. No speculative destructive action.

### Tier 3 — human decision

Required when the repair crosses a protected boundary or the state is materially ambiguous.

The centralized Human Approval / Decision Queue receives:

- task reference;
- requested decision;
- reason;
- mutable scope/impact;
- risk;
- evidence already collected;
- safe next action.

## Failure fingerprint

A fingerprint is derived from normalized, non-secret diagnostic information. It is used to recognize recurrence without copying secrets into logs.

Conceptually:

`fingerprint = SHA-256(failure_class + tool/domain + normalized_signature)`

Do not include credentials, tokens, PII, payment data, or full private payloads.

A recurrence should be handled as:

**KNOWN FAILURE → KNOWN PLAYBOOK → VERIFY → LEARN**

not as a fresh investigation.

## Failure classes and root response

| Domain | Typical failure | Root response | Proof |
|---|---|---|---|
| AI / model / quota | quota, rate limit, provider outage, context failure | route + bounded failover + durable task state | resume evidence |
| Session / context | session death, overflow, stale context | Task Capsule + Context Manifest + checkpoint | kill/resume test |
| Code correctness | wrong API, wrong logic, partial fix | contract + impacted tests + deterministic verification | test/analyzer + regression |
| Concurrency | race, duplicate worker/action | ownership + idempotency + one owner | duplicate/concurrency test |
| State / data | corrupt cache, partial write, schema drift | integrity guard + quarantine + known-good recovery | corruption/migration drill |
| Network / sync | timeout, offline, partial sync | bounded retry + idempotency + conflict policy | replay/reconnect test |
| Dependencies | vulnerable/transitive drift | lockfile + dependency review + provenance | dependency audit |
| Build / toolchain | Gradle/Java/ARM/CI mismatch | pinned toolchain + reproducible build path | clean build |
| Release / artifact | wrong revision, bad signing | release gate + hash + provenance | artifact verification |
| Security / auth | privilege/token/entitlement issue | least privilege + server authority + human gate when needed | security/abuse tests |
| Privacy / AI data | excessive context or secret leakage | least-context + redaction + retention | secret/PII/context scans |
| Content / language | wrong grammar/duplicate/false translation | provenance + validation + quarantine | content regression |
| Learning quality | bad feedback/adaptation | learning invariants + delayed verification | learning regression |
| Performance/resources | RAM/CPU/battery/network pressure | budgets + backpressure + lazy loading | budget/stress tests |
| Automation/scheduler | stale telemetry/duplicate schedule | reconcile durable evidence + idempotent execution | run-state reconciliation |
| Observability/unknowns | failure without clear cause | evidence ledger + correlation IDs + UNKNOWN=STOP | diagnostic drill |
| Legal/IP/compliance | license/store/privacy issue | provenance + human gate + jurisdictional verification | compliance record |
| Provider/business continuity | provider terms/price/outage | replaceable adapter + core independence | provider swap/cost check |

## Repair loop protection

Never allow:

`EDIT → TEST → SAME FAILURE → EDIT → TEST → SAME FAILURE ...`

The control is:

`EDIT → VERIFY → compare evidence → progress?`

If no meaningful progress is detected:

- stop the repair loop;
- preserve the state;
- classify the repeated failure;
- reassess scope/context/dependency;
- switch to a suitable alternative;
- or escalate.

Repair attempts and budgets are bounded.

## Recovery contract

For interruption:

`POWER / NETWORK / TERMUX / OPENCODE / PROVIDER LOSS`
→ preserve durable state
→ recover from verified checkpoint
→ verify integrity
→ continue or stop safely.

The permanent unit remains:

**TASK + STATE + EVIDENCE + CHECKPOINT**

A session may die. The task must not have to restart from zero.

## Learning contract

A real recurring failure results in one or more of:

1. fix + regression test;
2. guard;
3. documentation clarification;
4. explicit accepted risk with reason.

Lessons are recorded in the existing durable memory sources (PROJECT_STATE, ENGINEERING_STATE, CONTINUOUS ENGINEERING MEMORY, CHANGE & DECISION LOG, TASK_LOG) when supported by evidence.

No separate Regression Memory subsystem is introduced.

## Cross-chat contract

A new chat must not start a new investigation merely because the old chat disappeared.

Boot:

**PROJECT_INTENT → runtime evidence → latest events → PROJECT_STATE / ENGINEERING_STATE → latest verification/checkpoint → GitHub → current task**

Then:

**RECONCILE → CLASSIFY → SELECT NEXT SAFE ACTION → VERIFY → CHECKPOINT → CONTINUE**

Conversation history is temporary context only.

## OpenCode boundary

OpenCode native hooks may be used only after local runtime evidence proves support. External documentation is not runtime proof.

Until then, the existing local `project_record_event.py` bridge remains a callable bridge, not a claimed automatic hook.

## Current known evidence

As of 2026-09-20:

- canonical repository: `sali97m-cpu/deutsch-bilarabi`;
- project record runtime is current, with reconciliation not required;
- Recovery Checkpoint evidence was successful for the recorded run;
- Engineering CI currently has a recorded failure and therefore is **not** considered healthy;
- OpenCode 1.18.31 is installed locally and the local plugin package is present; hook execution still requires runtime proof.

## Implementation law

This playbook is a cross-cutting operational implementation of the already-approved Reliability Assurance amendment in Master Project Book v6.

It must not be used as a reason to accumulate architecture.

**CORRECT PROGRESS > ARCHITECTURE ACCUMULATION.**
