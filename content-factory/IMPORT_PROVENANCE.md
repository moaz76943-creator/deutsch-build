# Content factory (imported source)

This directory is the **history-preserving import** of the source content-factory
repository [`moaz76943-creator/-offline-packs-store`](https://github.com/moaz76943-creator/-offline-packs-store)
into the unified public target repository `deutsch-build`.

## Provenance

| Field | Value |
|---|---|
| Source repository | `moaz76943-creator/-offline-packs-store` |
| Source branch | `main` |
| Source HEAD at import | `ca821e59ac39a75db37a094e0cb6af112566006f` |
| Import commit | two-parent merge commit, tree imported under `content-factory/` |
| Imported files | 877 (≈6.2 MB) |
| Target branch at import | `main` |

The import is a **merge commit**, not a copy: the source commit is a real parent
of the import, so `git log --follow` and `git blame` keep the original history
for every imported file.

## What lives here

| Path | Contents |
|---|---|
| `packs/` | Pack manifests and language pack artifacts |
| `tools/` | Factory, validation and ingestion tooling |
| `standards/` | Schema and standards definitions |
| `legal/` | Licence ledger and attribution evidence |
| `catalog/` | Organisation and concept-graph catalogs |
| `community/` | Community corpus and review material |
| `tests/` | Source-repository test suite |
| `.github/` | Source-repository CI definitions (inert, see below) |

## Rules for this directory

1. **Nothing here is deleted to reduce noise.** Content is absorbed into the
   application tree (`assets/`, `tools/`, `lib/`) only through a separate,
   reviewable change that proves the target copy is equivalent or better.
2. **`content-factory/.github/` never runs.** GitHub Actions only executes
   workflows from the repository-root `.github/`. The imported definitions are
   kept for provenance only.
3. **The source repository is not retired** until the owner explicitly
   authorises it, per the preservation rule in `AGENTS.md`.
4. **No secrets.** A scan for private-key blocks and common token prefixes is
   part of the import check; the source repository is public but this must stay
   true.
