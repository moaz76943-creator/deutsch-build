# Zero-Billing CI/CD Policy

## Canonical execution paths

The repository has three supported build/verification paths:

1. **Termux/local** — canonical zero-billing path. Use `scripts/local_quality_gate.sh` and `scripts/local-release.sh`.
2. **GitHub manual worker/release workflows** — explicit owner-triggered fallback only.
3. **Self-hosted runner** — optional future path when a trusted Android build host is available.

Automatic GitHub-hosted runners are disabled by default.

## Automatic workflow opt-in

Any non-release workflow that can run from `push`, `pull_request`, `pull_request_target`, `schedule`, or `workflow_run` must gate its hosted job before runner allocation with:

`vars.GITHUB_ACTIONS_NONESSENTIAL_AUTOMATION_ENABLED == 'true'`

Workflows that also expose `workflow_dispatch` keep manual execution available without enabling automatic runs.

Release-producing automation uses the separate fail-closed switch:

`vars.GITHUB_ACTIONS_RELEASE_AUTOMATION_ENABLED == 'true'`

The repository default is therefore zero hosted-runner consumption unless the owner explicitly opts in.

## Supply-chain rule

All active third-party GitHub Actions must be pinned to a full immutable 40-character commit SHA. Mutable tags such as `@v4`, `@v5`, `@main`, or `@master` are forbidden on active workflows.

The canonical local quality suite enforces both the zero-billing runner contract and immutable Action references.

## Required-check caveat

GitHub branch-protection/ruleset configuration is server-side state, not repository source. Historical required contexts may still name disabled workflows. Repository code must not fake successful checks to bypass that protection.

When administration access is available, replace stale required contexts with the canonical external/local verification policy rather than creating no-op success checks.

## Delivery rule

Normal engineering commits and PR merges use `[skip ci] [skip build]` unless a hosted build is explicitly desired. This prevents accidental release/provider triggers and preserves the zero-additional-billing baseline.
