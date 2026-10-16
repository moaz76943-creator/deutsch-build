# DEUTSCH بالعربي — Project Intent & Plan

## Purpose

This file is the durable human/agent-maintained definition of why the project is being built, the current goal, and the current approved plan.

Automation MUST NOT invent or rewrite the goal or plan from commit activity. It may report evidence, detect drift, and flag reconciliation.

## Ultimate goal

Build DEUTSCH بالعربي as a robust, quality-first, multilingual language-learning platform with durable state, reliable verification, safe recovery, and progressively higher automation of engineering operations.

## Current goal

Establish a reliable project-operating system in which a new chat/session can determine the current project position from durable evidence, preserve the approved goal/plan, detect gaps or changes, and continue from the next safe task without repeating completed work.

## Current approved execution plan

1. Previous-Work Reconciliation FIRST.
2. Inspect live GitHub/code truth before claims about implementation.
3. Preserve the verified OpenCode native hook + project-record bridge evidence; do not repeat that proof unless regression evidence appears.
4. Finish the active Flutter analyzer root-cause repair and restore a trustworthy Engineering CI baseline.
5. Reconcile and verify the stacked Universal Failure Control / release-workflow integration without weakening tests or security contracts.
6. Implement and verify stable task-level STARTED / COMPLETED / FAILED semantics with a durable task_id.
7. Run the prepared Mission Mode end-to-end interruption/recovery canary.
8. Verify automatic continuation/recovery from durable task state and checkpoints.
9. Maintain one central human decision surface for decisions that genuinely require the owner.
10. Verify scheduler/automation telemetry without creating a fourth worker or duplicate architecture.
11. Update this intent file whenever an approved goal or plan changes; mark older execution positions as superseded rather than silently reusing them.

## Universal session contract

Every chat, scheduled worker, OpenCode process, and coding agent that performs project mutation must follow:

`docs/project-record/SESSION_OPERATING_CONTRACT.md`

Repository agents also receive the root `AGENTS.md` pointer.

The session is never the source of truth. Meaningful movement must become durable through CLAIM / DELTA / BLOCKER / HANDOFF / COMPLETE / FAILED / SUPERSEDE evidence before the session stops or hands off.

## Planning rules

- A code event is evidence of what happened, not proof of why it happened.
- A plan change is an explicit decision and must be recorded as such.
- Historical plans remain historical until explicitly superseded.
- Verified runtime capabilities are not reclassified as unverified without regression evidence.
- No task is considered complete solely because architecture documentation says it is approved.
- Unknown critical state => STOP / RECONCILE.
- Correct Progress > Architecture Accumulation.

## Current execution position

**Current phase:** Cross-Chat / Project Record Reliability — integration and verification.

**Current task:** Finish Issue #10 / draft PR #13 Flutter root-cause repair, then verify the stacked CI/release/failure-control integration before Mission Mode.

**Completed in this phase:**
- GitHub-backed project record is active on the canonical repository.
- Goal/plan are stored separately from machine-generated runtime evidence.
- Main-branch commits are recorded automatically.
- Engineering CI and Recovery Checkpoint outcomes are captured as separate evidence.
- History/lineage gaps can force RECONCILIATION_REQUIRED instead of silent continuation.
- OpenCode 1.18.31 native hook runtime was verified on the owner device.
- OpenCode session lifecycle events were bridged into the project record and persisted durably to GitHub.
- Recovery Checkpoint succeeded after the durable hook-evidence commit.
- The original Python setup/cache blocker in Engineering CI was fixed; live CI now reaches pytest.
- Mission Mode canary plan and acceptance checklist are prepared.

**Still UNVERIFIED / OPEN:**
- Flutter analyzer/tests and complete Engineering CI green baseline.
- Final integration/verification of Universal Failure Control and the hardened release-workflow contract.
- Stable task-level STARTED / COMPLETED / FAILED event semantics with task_id.
- End-to-end Mission Mode interruption/recovery canary.
- Direct automatic writes from GitHub Actions into Notion.

**Next safe step:** Let the active OpenCode repair finish on `fix/flutter-analyzer-root-causes`; verify its durable commit/evidence, then reconcile the stacked branch with the current main CI/release requirements before any merge.
