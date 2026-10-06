# Deutsch بالعربي

Private source repository for the **DEUTSCH بالعربي** application.

## Local signed APK (no GitHub Actions minutes)

With the existing Termux keystore at `~/.gradle/release-key.jks`:

```bash
cd ~/deutsch-bilarabi && git switch main && git pull --ff-only origin main && bash scripts/local-release.sh
```

The script validates and configures signing, preserves build caches, builds an
ARM64 release, and verifies the APK signature. Java 17 and 21 are supported;
there is no minimum disk-space gate. See [local release setup](docs/LOCAL_RELEASE.md)
for Base64 import, first-time toolchain installation, and optional quality checks.

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

**V1.1 Feature Freeze / package 3.3.10+133**

**Repository metadata note:** V1.1 release preparation reconciles the package metadata and Android release metadata at `3.3.10+133`.

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
