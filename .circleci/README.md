# Zero-cost CircleCI quality gate

This pipeline replaces the automatic GitHub Actions quality gate without changing the canonical repository gate. CircleCI runs `scripts/local_quality_gate.sh` directly, so there is one quality contract rather than a second CI-specific implementation.

## Required CircleCI setup

Use a **GitHub App** pipeline whose config path is `.circleci/config.yml`. Do not use an `All pushes` trigger: this repository intentionally includes `[skip ci]` in delivery commits, and CircleCI skips ordinary push-triggered pipelines when that token is present.

Create these GitHub App triggers for the pipeline:

1. `Non-draft PR opened`
2. `Pushes to open non-draft PRs`
3. `PR marked ready for review`

The workflow itself additionally fails closed to PRs whose base branch is not `main`. Manual/API pipeline runs are allowed for recovery and verification.

No CircleCI secret is required for the quality gate. The repository remains the source of truth and CircleCI receives read-only checkout access through its GitHub App integration.
