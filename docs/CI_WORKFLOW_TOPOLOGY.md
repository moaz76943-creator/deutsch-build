# CI/CD Workflow Topology — 2026-10-06

This inventory is the cost/ownership map for the 30 active `.github/workflows/*.yml` files at the Task 2 baseline. It does not change branch-protection required checks and does not authorize any external provider.

Classes: **A** manual release, **B** manual utility, **C** self-hosted, **D** automatic but explicitly opt-in, **E** retired/historical, **F** bounded staging self-check, **G** essential security audit.

| Workflow | Class | Owner | Purpose | Trigger | Cost boundary |
| --- | --- | --- | --- | --- | --- |
| `agents_pulse.yml` | D | Agent/orchestration engineering | Compile/run bounded headless agent pulse | manual + push/PR on agent/orchestration paths | automatic events require central nonessential opt-in plus both Agents Pulse local gates; manual still requires both local gates |
| `ai_collaboration_bridge.yml` | D | Architecture review | Deterministic/AI architecture review and ADR drafting | issues/comments/PR/PR-target/reviews | central nonessential opt-in before every hosted job; provider jobs also require AI activation + billing approval |
| `android_target_guard.yml` | D | Android release engineering | Enforce Google Play target-SDK floor | PR + push + schedule + manual | automatic events require central nonessential opt-in; manual remains explicit |
| `app_size_guard.yml` | D | Performance engineering | Guard repository/app asset size | PR | central nonessential opt-in |
| `architectural_memory_sync.yml` | D | Architecture governance | Synchronize managed decision ledger after main changes | push main | central nonessential opt-in plus architecture sync + billing approval |
| `auto-merge.yml` | D | Repository governance | Enable protected auto-merge for trusted same-repo PRs | PR-target | central nonessential opt-in; trusted association/same-repo checks |
| `auto-rebase.yml` | D | Repository governance | Rebase eligible PRs after main changes | push main + manual | automatic event requires central nonessential opt-in; manual remains explicit |
| `auto_release_tagger.yml` | D | Release engineering | Update changelog/tag/GitHub Release metadata | merged PR-target | separate release-automation opt-in; no binary build channel |
| `autonomous_arbiter_gate.yml` | D | Merge governance | Evaluate deterministic merge-arbiter contract | PR | central nonessential opt-in |
| `build.yml` | B | Android build engineering | Produce manual debug ARM64 APK artifact | manual | GitHub-hosted runner only after explicit dispatch |
| `build_aab.yml` | A | Release engineering | Produce signed production AAB | manual | GitHub-hosted runner and signing secrets only after explicit dispatch |
| `build_apk.yml` | A | Release engineering | Manual debug APK + web preview + `latest` release publishing | manual | GitHub-hosted runner only after explicit dispatch |
| `cleanup_old_artifacts.yml` | D | Repository maintenance | Delete expired workflow artifacts | schedule + manual | schedule requires central nonessential opt-in; manual remains explicit |
| `content_expansion_bot.yml` | D | Content engineering | Run bounded content expansion automation | schedule + manual | schedule requires central nonessential opt-in; manual remains explicit |
| `elastic-worker-factory.yml` | B | Worker control plane | Validate versioned worker dispatch/replay envelope | manual + workflow_call | no automatic repository caller; hosted compute only by explicit dispatch/call |
| `local_release.yml` | C | Release engineering | Build signed release on trusted Android build host | manual | self-hosted labels only; no GitHub-hosted default |
| `performance_guard.yml` | D | Performance engineering | Presentation performance checks on same-repo PR head | PR | central nonessential opt-in; same-repo head restriction |
| `pr_architectural_guard.yml` | D | Architecture governance | Inspect sensitive added diff lines through GitHub API | PR-target | central nonessential opt-in; no checkout/execution of PR head |
| `privacy_policy_health_check.yml` | D | Store/compliance | Check published privacy-policy endpoint | schedule + manual | schedule requires central nonessential opt-in; manual remains explicit |
| `project-record-engineering-ci.yml` | D | Project record | Capture `Engineering CI` workflow-run evidence if that producer exists | workflow_run | central nonessential opt-in; currently dormant while producer remains disabled |
| `project-record-recovery.yml` | D | Project record | Capture Recovery Checkpoint workflow-run evidence | workflow_run | central nonessential opt-in |
| `project-record-sync.yml` | D | Project record | Reconcile/update repository project record | push + schedule + manual | automatic events require central nonessential opt-in; manual remains explicit |
| `quality_gate_ci.yml` | B | Quality engineering | Manual hosted fallback for canonical quality gate | manual | GitHub-hosted runner only after explicit dispatch |
| `recovery-checkpoint.yml` | D | Recovery engineering | Capture bounded recovery checkpoint | push + schedule + manual | automatic events require central nonessential opt-in; manual remains explicit |
| `security_audit.yml` | G | Security engineering | Offline-first policy, OSV and fetched-history Gitleaks scan | PR + dependency-lock push | mandatory bounded Linux job, 15-minute cap; no paid runner, schedule or billing change; incomplete/skipped scans fail closed |
| `smart_triage_labeler.yml` | D | Repository triage | Apply changed-file labels through pinned labeler action | PR-target | central nonessential opt-in; metadata-only privileged operation |
| `sync_store_metadata.yml` | B | Store operations | Validate/generate metadata and optionally upload listings | manual | GitHub-hosted runner/service-account access only after explicit dispatch and upload input |
| `trigger_signed_build.yml` | D | Legacy release-provider bridge | Trigger Codemagic signed AAB after merged PR | merged PR-target | separate release-automation opt-in; dormant by default; Codemagic is noncanonical |
| `weekly_maintenance.yml` | D | Repository maintenance | Run bounded weekly maintenance checks/actions | schedule + manual | schedule requires central nonessential opt-in; manual remains explicit |
| `worker_release_apk.yml` | A | Release engineering | Build/verify/publish signed ARM64 APK in private worker repository | manual | explicit dispatch + private worker/main/enable gates; hosted default can later be replaced by self-hosted labels |

## Privileged `pull_request_target` pass

The active privileged set is exactly:

`ai_collaboration_bridge.yml`, `auto-merge.yml`, `auto_release_tagger.yml`, `pr_architectural_guard.yml`, `smart_triage_labeler.yml`, `trigger_signed_build.yml`.

Review result for this baseline:

- no workflow checks out `github.event.pull_request.head.*` in privileged context;
- AI inline review checks out the trusted base and fetches head files only as inert API data;
- auto-release checks out canonical `main`, not the PR head;
- Codemagic trigger and auto-merge do not check out PR source;
- PR title/body values are not interpolated directly into shell source;
- automatic cost gates appear before hosted `runs-on` allocation;
- token permissions are operation-scoped; no PR-target workflow requests `actions: write`, `checks: write`, or `id-token: write`.

## Non-active historical workflow files

Files ending in `.disabled` are outside the active 30-workflow inventory and are class E historical evidence. At this baseline they include `build-apk.yml.disabled`, `engineering-ci.yml.disabled`, and `quality.yml.disabled`. They must not be resurrected merely to manufacture a required-check status.

## Open-PR collision note

At Task 2 start, PR #497 proposed a new `deploy_to_play_store.yml` workflow but had not been merged. It is therefore not part of this 30-workflow inventory. If that PR is ever reconciled and merged, the workflow must receive an explicit class/cost owner before activation. PR #508 changes only `.circleci/config.yml` and is not modified by this task.
