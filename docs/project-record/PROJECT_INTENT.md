# DEUTSCH بالعربي — Project Intent & Plan

## Purpose

This file is the durable human/agent-maintained definition of why the project is being built, the current goal, and the current approved plan.

Automation MUST NOT invent or rewrite the goal or plan from commit activity. It may report evidence, detect drift, and flag reconciliation.

## Ultimate goal

Build DEUTSCH بالعربي as a robust, quality-first, multilingual language-learning platform with durable state, reliable verification, safe recovery, and progressively higher automation of engineering operations.

## Current goal (owner update 2026-10-15)

Deliver a verifiably working Android offline German→Arabic learning slice: installable APK from canonical staging, bounded offline startup, usable search/translation, and persistent isolated SRS. Then admit the first rights-verified SQLite v2 pack. The project operating system is a supporting tool, **not** the product milestone. Minimize owner intervention, coordination duplication and unnecessary PR creation.

## Current approved execution plan (supersedes the older operations-first plan)

1. Reuse the existing GitHub CI, canonical task ledger and staging merge path; do not build replacements.
2. Resume from the verified HEAD and current active PRs, not stale chat or old branch snapshots.
3. Select the smallest **user-visible functionality blocker**; reuse or repair existing work rather than creating more backlog.
4. Establish one reproducible Android APK artifact on canonical staging, with exact SHA and no automatic release publication.
5. Verify offline startup, directed de→ar search, SRS persistence and restart on Android; report what is and is not exercised.
6. Reconcile the existing 1,000-row de→ar TSV and compiler without claiming legal source approval; publish only after source rights, integrity and provenance are verified.
7. Let separate independent file scopes advance concurrently; serialize only real collisions and all merges.
8. Use risk-proportional tests, preserve required CI/reviews, protect learner data and keep additional billing at zero.
9. A blocked owner decision must specify one actionable decision; other independent safe work continues.
10. Measure weekly progress by working capabilities and blockers removed, not agents, checklists or PR counts.

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

**Current phase:** Android offline learning vertical slice — evidence pending for APK/device usability.

**Immediate engineering action:** Reconcile existing Android build workflows and owner scopes, reuse the existing safe artifact builder, prove APK on canonical staging, then run the offline/SRS acceptance path.

**Source and production gate:** Public source ledger has no approved entries at the last observed snapshot; never imply production pack readiness from demo fixtures or an existing release title.

## Historical execution position (superseded; retained for provenance)

**Historical phase:** Cross-Chat / Project Record Reliability — integration and verification.

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
