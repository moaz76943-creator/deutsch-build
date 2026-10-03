# DEUTSCH بالعربي — Living Architectural Decision Ledger

Status: **CANONICAL / LIVING**
Repository: `sali97m-cpu/deutsch-bilarabi`

This file is the durable architectural memory of the project. A decision recorded here remains
binding until a later ADR explicitly supersedes it. Live GitHub state and exact-head verification
remain authoritative for implementation state; this ledger defines *why* the architecture is shaped
as it is and which alternatives were deliberately rejected.

Every ADR uses the same three-part structure so a future human or automation agent can recover the
decision without reconstructing historical conversations.

## Post-merge memory

The block below is machine-managed by `tools/post_merge_decision_sync.py`. Decision bodies are
human-reviewed and are never rewritten by the sync tool.

<!-- BEGIN POST_MERGE_SYNC -->
- Last synced main SHA: `54a6dffce64c63e55453ac8ea5f9d4999c7f6c53`
- Last merged PR: #242
- Last merge title: chore(automation): complete autonomous engine unification and e2e validation (AE-001, AE-003, AE-005)
- Synced at: bootstrap from integrated main
<!-- END POST_MERGE_SYNC -->

## ADR-001 — Shared Core + Language Intelligence + Directed Pair Intelligence

### Context and motivation
The product began with German/Arabic as the reference path, but its architecture is intended to
support multiple user languages and directed language pairs. Treating German as a universal schema,
or silently routing every pair through German or English, would make directionality ambiguous and
would create hidden coupling between content and presentation.

### Accepted decision
The stable product model is `Shared Core + Language Intelligence + Directed Pair Intelligence`.
`USER_LANGUAGE`, `SOURCE_LANGUAGE`, and `TARGET_LANGUAGE` are separate concepts. `A → B`
is not interchangeable with `B → A`. German remains a reference implementation, not a silent
universal pivot.

### Rejected alternatives
- A German-only schema extended with language-specific conditionals: rejected because it makes
  German assumptions leak into every future language.
- Silent German or English pivoting: rejected because it changes semantic direction without an
  explicit contract.
- Treating reverse pairs as equivalent: rejected because learning intent, grammar, examples, and
  directionality metadata differ by direction.

## ADR-002 — Presentation is separated from audio and device services

### Context and motivation
UI screens need audio controls, TTS, and speech recognition, but direct plugin ownership inside
presentation code couples widgets to hardware lifecycle, permissions, and plugin failure modes.
That coupling previously made presentation harder to test and encouraged service logic inside pages.

### Accepted decision
Presentation may receive callbacks, controller state, and approved service abstractions, but it must
not import or own device-facing audio packages such as `flutter_tts` or `speech_to_text`.
Audio/TTS/speech behavior stays behind services/controllers/adapters. The canonical UI control
(`AppAudioButton`) remains presentation-only.

### Rejected alternatives
- Direct plugin imports inside pages/widgets: rejected because hardware lifecycle and presentation
  become inseparable.
- A second UI-specific audio engine: rejected because it duplicates ownership and state.
- Passing plugin objects through the widget tree: rejected because it hides rather than removes the
  dependency violation.

## ADR-003 — Manually maintained presentation files stay strictly below 1000 lines

### Context and motivation
Large presentation files accumulated unrelated responsibilities, became difficult to review, and
encouraged local patches instead of coherent decomposition. A line ceiling is useful only when it
forces responsibility boundaries rather than cosmetic file splitting.

### Accepted decision
Every authored presentation file under the canonical UI roots must remain **strictly below 1000
lines**. Complex screens are decomposed by coherent responsibility while retaining one canonical
public page/screen identity. Machine-generated data is handled by its generator contract, not by
manual line-count workarounds.

### Rejected alternatives
- Raising the line ceiling when a page grows: rejected because it defers decomposition.
- Creating `*_v2.dart`, duplicate routes, or parallel screens: rejected because it evades the
  limit while multiplying ownership.
- Mechanical splitting without responsibility boundaries: rejected because file count changes but
  architectural complexity does not.

## ADR-004 — Root-cause repair and canonical quality gates replace patching

### Context and motivation
False-green fixes can hide defects by weakening tests, restoring obsolete APIs, mutating generated
outputs, or duplicating services. They reduce short-term noise while increasing long-term
architectural drift.

### Accepted decision
The repair sequence is evidence/reproduction → root cause → bounded canonical fix → focused
regression → affected regression → canonical quality gate → exact-head evidence. The canonical gate
is `scripts/local_quality_gate.sh`; CI delegates to it rather than reproducing weaker command
subsets. Tests and architecture/security/privacy thresholds are not weakened to obtain a pass.

### Rejected alternatives
- Skip/xfail/delete failing tests: rejected because it removes evidence instead of fixing behavior.
- Catch-and-ignore around architecture or persistence failures: rejected because it converts a real
  fault into silent corruption.
- Editing generated output instead of its source/generator: rejected because regeneration restores
  the defect.
- Parallel replacement services/pages/models: rejected because they hide ownership problems and
  create competing sources of truth.

## ADR-005 — Adaptive learning uses one error-bank, SRS, mastery, and persistence path

### Context and motivation
Exercises are useful only when learner outcomes feed future review. Per-screen mistake stores or SRS
queues fragment learner history and make mastery inconsistent across sessions.

### Accepted decision
Every answer-recording path feeds the canonical adaptive-learning persistence model.
`UniversalSessionOrchestrator` coordinates session flow, while
`LearnerRepository.record` / `recordFacet` remain the canonical persistence/SRS/XP boundary
until explicitly superseded by a later ADR. Mistakes feed the existing error bank; retrieval
success/failure updates canonical spaced repetition.

### Rejected alternatives
- Private per-screen mistake banks: rejected because errors disappear outside that screen.
- Separate SRS queues per feature: rejected because scheduling and mastery diverge.
- Duplicate XP/mastery ownership: rejected because totals become inconsistent and difficult to
  reconcile.

## ADR-006 — Automation has one canonical execution router and bounded mutation paths

### Context and motivation
The repository contains complementary automation roles: planning, atomic dispatch, state ledger,
quarantine, and orchestration. Calling each implementation through independent ad-hoc paths risks
duplicated control planes and inconsistent state transitions.

### Accepted decision
`tools/automation/runtime.py` is the canonical CLI router for planner, dispatch, and state
operations. `dispatcher.py`, `autonomous_daemon.py`, and `state_manager.py` remain specialized
implementation modules rather than competing engines. Bounded one-cycle execution is preferred;
polling loops are not required for verification or integration.

### Rejected alternatives
- A second dispatcher or ledger: rejected because one mutable scope would gain multiple owners.
- Re-implementing state transitions inside orchestration code: rejected because the ledger would
  cease to be authoritative.
- Continuous polling as the default validation mechanism: rejected because bounded deterministic
  execution is safer and easier to verify.

## ADR-007 — Living architectural ledger + Zero Drift Check are mandatory architecture memory

### Context and motivation
Architecture rules spread across conversations and historical documents are easy to forget. A future
change can be locally correct yet violate a decision whose motivation is no longer visible to the
implementer.

### Accepted decision
`docs/architecture/DECISION_LOG.md` is the durable decision ledger. New decisions or explicit
supersessions are added here using the same three-section ADR structure. `tools/zero_drift_check.py`
turns the current decisions into executable repository invariants and is called by the canonical
quality gate, so incoming PRs are checked without creating a second quality pipeline.

After a merge to `main`, `tools/post_merge_decision_sync.py` updates only the managed post-merge
memory block. The repository workflow `.github/workflows/architectural_memory_sync.yml` provides
automatic post-merge synchronization, but its runner job is fail-closed behind explicit
`ARCHITECTURE_LEDGER_SYNC_ENABLED=true` and
`ARCHITECTURE_LEDGER_BILLING_APPROVED=true` repository variables so the project never assumes
free runner capacity or creates additional billing without owner authorization.

### Rejected alternatives
- Keeping decisions only in chat history: rejected because chat is not the project source of truth.
- A prose-only ledger with no executable checks: rejected because documentation can drift silently
  from code.
- A second CI quality pipeline for architecture memory: rejected because it duplicates the
  canonical gate and can create extra execution cost.
- Unconditionally running a post-merge cloud job: rejected because repository policy forbids
  assuming free GitHub Actions capacity.
