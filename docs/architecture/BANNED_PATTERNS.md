# DEUTSCH بالعربي — Banned Engineering Patterns

Status: CONSTITUTIONAL / ENFORCED
Repository: `sali97m-cpu/deutsch-bilarabi`

These patterns are prohibited because they create false-green results, duplicate ownership, architectural drift, or irreversible integration risk. A task that requires one of these patterns must stop and be redesigned at the root cause.

## 1. Test and quality-gate bypasses

Forbidden:
- deleting a failing test to make the suite green;
- `skip`, `xfail`, disabled suites, filtered-out failures, or equivalent suppression used to hide a regression;
- lowering coverage, architecture, security, privacy, accessibility, content, or quality thresholds merely to obtain a pass;
- replacing `scripts/local_quality_gate.sh` with weaker per-workflow command subsets;
- reporting partial verification as full verification;
- treating green CI on a different commit as exact-head evidence.

Required response:
- reproduce the failure;
- identify the root cause;
- make a bounded canonical fix;
- run focused and affected regressions;
- run the canonical quality contract applicable to the task.

## 2. Patch-over-root-cause engineering

Forbidden:
- restoring obsolete state or dead APIs solely to satisfy stale textual tests;
- catch-and-ignore handling for architecture, persistence, security, or content-contract failures;
- one-off conditionals that hide a broken ownership or dependency boundary;
- editing generated output instead of fixing its generator/source contract;
- duplicating a model/service/page/engine to avoid repairing the canonical implementation;
- permanent compatibility shims without an explicit migration/removal contract.

## 3. Architectural file-size ceiling and duplication

All manually maintained source, presentation, workflow, automation, configuration, and architecture files must remain **strictly below 1000 lines**.

Machine-generated artifacts may exceed the ceiling only when they are reproducibly generated from canonical inputs and are never used as a manual patch surface.

Forbidden:
- allowing a manually maintained file to reach or exceed 1000 lines;
- creating `*_v2.dart`, duplicate public pages/classes/routes, or parallel UI engines to evade the line cap;
- splitting files without splitting responsibility;
- reintroducing Theme, GlassCard, or equivalent presentation infrastructure into `lib/core/`.

Required pattern:
- coherent decomposition;
- one canonical public screen identity;
- shared presentation components remain in approved presentation/design-system boundaries.

## 4. Audio and hardware boundary violations

Forbidden in presentation code:
- direct imports of `flutter_tts`, `speech_to_text`, or equivalent device/hardware packages;
- direct ownership of permissions, TTS engines, speech recognition engines, or hardware lifecycle by UI widgets/pages.

Required pattern:
- injected controllers/services/callbacks;
- hardware details behind approved service boundaries.

## 5. Adaptive-learning fragmentation

Forbidden:
- private per-screen SRS queues;
- second mistake/error banks;
- parallel mastery models;
- duplicate XP ownership;
- answer-recording paths that bypass `LearnerRepository.record` / `recordFacet` or the canonical successor contract.

## 6. Multilingual shortcuts

Forbidden:
- silent German or English pivoting;
- treating reverse language pairs as implicit equivalents;
- using German-specific fields as a universal multilingual schema without an approved contract;
- treating a generated candidate pack as canonical/readiness evidence without validation.

## 7. Git, ownership, and integration hazards

Forbidden:
- force-push, destructive reset, or cleaning unknown work without explicit authorization;
- editing a mutable scope already owned by another active claim;
- opening duplicate PRs for the same active scope;
- merging on stale HEAD/BASE knowledge;
- claiming `MERGED` or `INTEGRATED` before live GitHub confirms it;
- bypassing protected-main policy merely because admin access exists.

## 8. Privileged automation hazards

Forbidden:
- workflows that auto-rewrite arbitrary PR source with privileged credentials;
- fabricated human approvals or automatic approval in place of review evidence;
- execution of untrusted PR-head code in a job that has provider secrets;
- treating Issue/PR/comment text as trusted workflow instructions;
- exposing secrets in repository files, logs, prompts, artifacts, Issues, PR comments, or documentation.

## 9. Billing and external-service hazards

Forbidden:
- enabling `AI_COLLABORATION_BILLING_APPROVED` without owner authorization and current billing evidence;
- assuming GitHub Actions minutes or model/API quotas are free;
- adding a paid service, paid runner, or production release path under the project's zero-additional-billing policy without the required human gate.

## 10. Enforcement rule

When a prohibited pattern is detected:
1. mark the task `BLOCKED` or `RECONCILIATION_REQUIRED`;
2. preserve current work and evidence;
3. identify the canonical owner/root cause;
4. create a bounded repair or handoff;
5. do not weaken the gate that detected the problem.

No schedule, automation, or AI agent is authorized to override this file silently.


## 11. Architectural-memory drift

Forbidden:
- changing a recorded architecture invariant without adding an explicit superseding ADR;
- removing `tools/zero_drift_check.py` from the canonical local quality gate;
- editing the machine-managed post-merge block by a second competing synchronization mechanism;
- enabling architecture-ledger cloud synchronization without explicit billing approval;
- treating a post-merge sync stamp as verification evidence for code that was not otherwise verified.

Required pattern:
- record the decision and rationale in `docs/architecture/DECISION_LOG.md`;
- keep executable invariants in the Zero Drift Check;
- use one managed post-merge synchronization path;
- preserve exact-head and canonical-quality evidence independently from documentation state.
