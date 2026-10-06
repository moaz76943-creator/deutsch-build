# Zero-Billing CI/CD Policy

## Canonical execution paths

The repository has three supported build/verification paths:

1. **Termux/local** — canonical zero-billing path. Use `scripts/local_quality_gate.sh` and `scripts/local-release.sh`.
2. **GitHub manual worker/release workflows** — explicit owner-triggered fallback only.
3. **Self-hosted runner** — optional future path when a trusted Android build host is available.

Automatic GitHub-hosted runners are disabled by default. The complete active-workflow inventory, owner, trigger and cost class is recorded in `docs/CI_WORKFLOW_TOPOLOGY.md`.

## Workflow classes

Every active workflow belongs to exactly one class:

- **A — Manual release:** hosted release/build work starts only through explicit `workflow_dispatch`.
- **B — Manual utility:** hosted utility/validation work starts only through explicit `workflow_dispatch` or a deliberate reusable-workflow call.
- **C — Self-hosted:** jobs require self-hosted labels and never default to GitHub-hosted compute.
- **D — Automatic but explicitly opt-in:** automatic triggers exist, but runner allocation is blocked unless the appropriate repository opt-in variable is enabled.
- **E — Retired/historical:** retained evidence only; it must not be an active automatic execution path.

Class E is currently empty in the active 30-workflow inventory. Files ending in `.disabled` are historical source and are not active workflows.

## Automatic workflow opt-in

Any non-release workflow that can run from `push`, `pull_request`, `pull_request_target`, `schedule`, or `workflow_run` must gate its hosted job before runner allocation with:

`vars.GITHUB_ACTIONS_NONESSENTIAL_AUTOMATION_ENABLED == 'true'`

Workflows that also expose `workflow_dispatch` keep manual execution available without enabling global automatic automation. Their job condition must therefore use the manual event as an explicit bypass for the central *automatic* gate, not as an unconditional hosted-runner path.

Feature-specific safety switches may remain, but they are subordinate to the central policy for automatic events:

- `agents_pulse.yml` additionally requires `AGENTS_PULSE_ENABLED` and `AGENTS_PULSE_ZERO_COST_APPROVED`.
- `architectural_memory_sync.yml` additionally requires `ARCHITECTURE_LEDGER_SYNC_ENABLED` and `ARCHITECTURE_LEDGER_BILLING_APPROVED`.

Release-producing automation uses the separate fail-closed switch:

`vars.GITHUB_ACTIONS_RELEASE_AUTOMATION_ENABLED == 'true'`

`auto_release_tagger.yml` and the legacy Codemagic trigger bridge are therefore dormant by default. Codemagic is not a canonical build channel; retaining its fail-closed bridge does not make it part of the supported release path.

The repository default is zero hosted-runner consumption unless the owner explicitly opts in or manually dispatches a class A/B workflow.

## Pull-request-target security boundary

Every `pull_request_target` workflow is privileged and must satisfy all of these rules:

- the cost/release opt-in gate is evaluated before runner allocation;
- PR-head code is never checked out or executed;
- any PR-head files fetched through the API are treated strictly as inert review data;
- untrusted PR title/body text is not interpolated directly into shell source;
- secrets are unavailable until trust checks have succeeded;
- permissions are limited to the smallest operation-specific set;
- write operations target canonical base/main state or GitHub metadata, never arbitrary PR-head source.

The canonical quality contract enumerates every active `pull_request_target` workflow and fails closed if a new one appears without explicit review.

## Reusable workflows

`elastic-worker-factory.yml` is class B. It supports `workflow_call` as a validation harness, but there are currently no repository workflow callers. A future automatic caller must itself be class D and satisfy the central opt-in rule before allocating hosted compute.

## Supply-chain rule

All active third-party GitHub Actions must be pinned to a full immutable 40-character commit SHA. Mutable tags such as `@v4`, `@v5`, `@main`, or `@master` are forbidden on active workflows.

The canonical local quality suite enforces both the zero-billing runner contract and immutable Action references.

## Required-check caveat

GitHub branch-protection/ruleset configuration is server-side state, not repository source. Historical required contexts may still name disabled workflows. Repository code must not fake successful checks to bypass that protection.

When administration access is available, replace stale required contexts with the canonical external/local verification policy rather than creating no-op success checks.

## Delivery rule

Normal engineering commits and PR merges use `[skip ci] [skip build]` unless a hosted build is explicitly desired. This prevents accidental release/provider triggers and preserves the zero-additional-billing baseline.
