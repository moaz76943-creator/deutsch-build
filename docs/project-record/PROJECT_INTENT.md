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
3. Verify OpenCode native capabilities locally before depending on them.
4. Implement and verify Mission Mode runtime behavior.
5. Implement and verify automatic continuation/recovery from durable task state and checkpoints.
6. Maintain one central human decision surface for decisions that genuinely require the owner.
7. Verify scheduler/automation telemetry without creating a fourth worker or duplicate architecture.
8. Run a real end-to-end automation test and record evidence.
9. Update this intent file whenever an approved goal or plan changes; mark the old decision as superseded rather than silently replacing history.

## Planning rules

- A code event is evidence of what happened, not proof of why it happened.
- A plan change is an explicit decision and must be recorded as such.
- Historical plans remain historical until explicitly superseded.
- Unverified runtime capabilities remain UNVERIFIED.
- No task is considered complete solely because architecture documentation says it is approved.
- Unknown critical state => STOP / RECONCILE.
- Correct Progress > Architecture Accumulation.
