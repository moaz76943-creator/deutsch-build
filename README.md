# Deutsch بالعربي

Private source repository for the **DEUTSCH بالعربي** application.

## CANONICAL ACTIVE REPOSITORY

**This repository is the active and canonical development repository.**

Use:

`sali97m-cpu/deutsch-bilarabi`

for:
- all new engineering work
- bug fixes and repairs
- architecture implementation
- tests and verification
- content work
- checkpoints and recoverable state
- release preparation
- current code truth

### Legacy repository — DO NOT USE

`sali97m-cpu/Deutsch_belarabi_` is a **legacy / non-canonical repository**.

It is retained only as historical material. Do not use it as a development target, release source, checkpoint source, or migration target unless an explicit future reconciliation decision changes this policy.

## Current validated baseline

**V384 / release evidence 3.3.10+133**

**Repository metadata note:** the current `pubspec.yaml` still declares `3.3.9+132`. Do not claim a release-version change until this metadata discrepancy is explicitly reconciled and verified.

## Recovery / preservation

The repository includes an automatic GitHub Actions recovery-checkpoint workflow:

`.github/workflows/recovery-checkpoint.yml`

It creates a unique recovery Git tag:
- automatically after every push to `main`;
- every **6 hours** on the scheduled cadence;
- or manually through workflow dispatch.

Important distinction:
- GitHub can only preserve work that has reached the repository as a commit.
- Uncommitted changes inside a local/session worktree cannot be captured by a scheduled GitHub workflow.
- Therefore meaningful work must be committed/checkpointed before it is considered durable.
- Destructive history rewriting remains prohibited: no reset, clean, revert, delete, or force-push as an automatic recovery mechanism.

See `docs/REPOSITORY_POLICY.md` for the complete repository and recovery rules.
