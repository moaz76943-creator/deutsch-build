# DEUTSCH بالعربي — Live System State

Status: ACTIVE / INTEGRATED
Last structural checkpoint: 2026-10-03
Repository: `sali97m-cpu/deutsch-bilarabi`

This file is the compact live architectural memory for the repository. It records integrated state and verified evidence; it is not a substitute for live GitHub. When this file conflicts with live GitHub or exact verification evidence, live GitHub and exact verification win.

## 1. Source-of-truth order

1. Live GitHub state
2. Exact-head verification evidence
3. Verified checkpoints
4. This live system-state record
5. Architecture/policy documents
6. Historical handoffs and conversations

State labels are explicit: `PREP`, `IMPLEMENTED`, `VERIFIED`, `INTEGRATED`, `BLOCKED`, `SUPERSEDED`.

## 2. Integrated baseline

### PR #235 — Green CI liquidation

- Source head: `00fb58fd16ff4021a74dc0af9dc86721806f6c07`
- Integrated into `main`: `334518d0ed3de388279ea57c122e4f41ac645858`
- State: `INTEGRATED`
- Canonical gate: `scripts/local_quality_gate.sh`
- CI workflows delegate to the canonical gate instead of duplicating manual gate commands.
- PR workflows use exact PR-head checkout rather than relying on a synthetic merge commit.
- Core presentation leakage was removed: Theme/GlassCard presentation infrastructure lives under `lib/ui_v35/`, not `lib/core/`.
- `lib/ui_v35/learning_pages.dart` is decomposed into coherent parts and remains far below the 1000-line presentation cap.
- Conversation architecture checks are whitespace/format insensitive.

Historical baseline failures targeted by the liquidation work: **17**.
Current code/architecture regression count from the owner's exact-head local verification: **0**.

Owner-supplied final local verification evidence after OpenSSL was installed:
- `scripts/local_quality_gate.sh`: **FULL GREEN PASS**
- Python regression suite: **946 passed / 0 failed**
- Build-path and Gradle integrity: **PASS**
- Security, privacy, quality, and architecture audits: **PASS**
- Historical legacy contracts: **14/14 green**
- Accepted failures: **0**

The earlier 943+3 environment-limited run is superseded by this final 946/0 verification result.

### PR #238 — AI collaboration bridge

- Integrated into `main`: `999fc56f73925d5fac994d6c6fbb8b80a2c25e1d`
- State: `INTEGRATED`
- Canonical policy: `docs/architecture/PROJECT_VISION_AND_RULES.md`
- Bridge workflow: `.github/workflows/ai_collaboration_bridge.yml`
- The bridge treats Issue/PR/review/diff content as untrusted data.
- Secret-backed provider jobs do not execute PR-head code.
- The bridge never auto-approves and never mutates application source.
- Provider context truncation fails closed.
- OpenAI requests use `store: false`.

## 2.1 Foundation state baseline

`FOUNDATION_STATE_MAIN_SHA = 1c3794e52052dde2c5cd18d102d7e78f809f4f4a`

This SHA is the integrated `main` state containing PRs #235, #238, and the initial state/queue scaffold from PR #239. The commit that updates this record is its direct successor.

## 3. Current architecture invariants

- Product model: `Shared Core + Language Intelligence + Directed Pair Intelligence`.
- `USER_LANGUAGE != SOURCE_LANGUAGE != TARGET_LANGUAGE`.
- `A → B` is not interchangeable with `B → A`.
- German is a reference implementation, not a universal schema or silent pivot.
- Presentation files must stay strictly below 1000 lines.
- Presentation code must not import device/audio packages directly.
- Adaptive-learning writes go through the canonical learner/SRS/error-bank path.
- One mutable scope has one owner.
- Generated outputs are not edited to hide source/generator defects.
- Exact-head evidence is required for integration claims.
- `IMPLEMENTED != VERIFIED != INTEGRATED`.

## 4. Autonomous-operation safety state

The repository-side collaboration bridge is integrated, but provider calls remain cost-gated.

Provider calls require both:
- `AI_COLLABORATION_ENABLED=true`
- `AI_COLLABORATION_BILLING_APPROVED=true`

Required provider secrets:
- `OPENAI_API_KEY`
- `GEMINI_API_KEY`

The project policy remains **ZERO ADDITIONAL BILLING** unless explicitly superseded by the owner. No automation may infer free quota, enable billing approval, or weaken this guard.

## 5. Current risks / blockers

- OpenSSL availability can affect environment-specific local cryptography/tooling tests in Termux. This is an environment capability issue and must not be hidden by weakening tests.
- Server-side enforcement of `ai-architecture-review` must be reconciled with current branch protection/rulesets before it is treated as a hard merge prerequisite.
- Existing automation assets must be inventoried before any new dispatcher, ledger, claim, queue, or recovery engine is implemented. Duplicate autonomous engines are forbidden.

## 6. Continuation contract

Canonical autonomous work order is stored in `tasks/pipeline_queue.json`.

Before mutating any queued scope:
1. refresh live `main`, open PRs, branches, and claims;
2. reconcile any existing implementation for the same scope;
3. verify exact HEAD/BASE and dependencies;
4. claim one mutable scope;
5. execute the queue item's `exact_next_action`;
6. verify without weakening gates;
7. persist a short checkpoint with OWNER | HEAD | EVIDENCE | STATE | BLOCKER | NEXT_ACTION.

Do not convert a planning artifact into an implementation claim without live evidence.
