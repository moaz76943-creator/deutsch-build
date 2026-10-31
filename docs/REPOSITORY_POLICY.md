# DEUTSCH بالعربي — Repository Policy

## 1. Canonical repository

The canonical active repository for all current DEUTSCH بالعربي engineering is:

`sali97m-cpu/deutsch-bilarabi`

The repository `sali97m-cpu/Deutsch_belarabi_` is legacy/non-canonical and must not receive current development work.

This policy does not delete or rewrite the legacy repository. Historical material remains preserved.

## 2. Source-of-truth boundary

GitHub is the code truth.

For current code decisions:
1. inspect `main` in `sali97m-cpu/deutsch-bilarabi`;
2. inspect direct verification evidence;
3. identify the latest verified checkpoint;
4. reconcile operational state in PROJECT_STATE / ENGINEERING_STATE;
5. use Notion and the Master Project Book as decision/context sources, not as substitutes for live code evidence.

## 3. Durability rule

A change is durable only after it exists as a Git commit in the canonical repository.

The normal safe flow is:

`PRECHECK → INSPECT → BACKUP → IMPLEMENT → VERIFY → COMMIT → CHECKPOINT → REPORT`

No destructive history rewrite is allowed as an automatic recovery method.

## 4. Automatic recovery checkpoints

`.github/workflows/recovery-checkpoint.yml` creates a recovery reference:
- automatically on every push to `main`;
- every **6 hours** on the scheduled cadence;
- manually through workflow dispatch.

Each run creates a unique timestamped tag:

`recovery/YYYYMMDD-HHMMSS-<short-sha>-<run-id>`

The tag points directly to the commit associated with that workflow run. The workflow never force-updates, deletes, or reuses a recovery tag.

Purpose:
- preserve a recoverable reference immediately after pushed work;
- provide regular recovery points even during quiet periods;
- reduce the chance of losing the ability to return to a known repository revision.

## 5. Critical limitation

A GitHub workflow cannot see uncommitted edits in another local/session worktree.

Therefore:

**Uncommitted work is not considered safely saved.**

Workers must commit meaningful completed work/checkpoints to the canonical repository before treating it as durable.

## 6. History protection

Do not use:
- `git reset --hard` as recovery
- `git clean` as recovery
- destructive revert/overwrite of newer work
- force-push
- history rewriting
- deletion of verified recovery history

If ownership, lineage, or repository state is ambiguous:

**STOP / RECONCILE.**

## 7. Verification

A recovery tag is a preservation reference, not proof that the tagged revision is correct or release-ready.

Verification remains separate and follows the project's normal evidence gates.

## 8. Operational rule

All future engineering instructions should target:

`sali97m-cpu/deutsch-bilarabi`

Do not silently return to the legacy repository.