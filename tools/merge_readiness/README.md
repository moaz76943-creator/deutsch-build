# Read-only merge readiness inventory

This utility reviews **live** pull-request metadata from both DEUTSCH بالعربي repositories without modifying GitHub, CI/CD configuration, branches or learner data.

## Running from Termux or another authenticated development machine

Run from the **private** repository root, using an already authenticated GitHub CLI:

    gh auth status
    python3 -m unittest -v tools.merge_readiness.test_audit
    python3 -m tools.merge_readiness.audit --max-prs 250 --output merge_readiness.json

For a smaller phone-friendly preview use --max-prs 25; the output explicitly marks limited inventory and must not be presented as a complete audit.

The full scan requires approximately one GitHub API changed-file call per open PR, plus pagination. It is bounded to six listing pages and three file pages per PR. Run as needed, not every minute.

## Interpreting results

- WRONG_BASE_OR_STACKED_PR: private integration should normally target live staging/v2-full-platform, not less advanced main. Retarget only after owner review; stacked PRs may deliberately use an intermediate base.
- DRAFT_REQUIRES_OWNER: the work's owner has not marked it ready.
- POTENTIAL_FILE_OVERLAP: different open PRs touch an identical path. This is NOT proof of a Git merge conflict. Select a canonical implementation and reconcile with owners.
- PACK_BYTES_AT_RISK: packaged language assets are deleted/replaced. Never merge without content preservation and migration review.
- WORKFLOW_CHANGE_REQUIRES_OWNER / SHARED_ROOT_FILE: special review needed; nothing modified.
- FILES_UNVERIFIED: GitHub file evidence cannot be read completely; fail closed.
- READY_FOR_INDEPENDENT_PREFLIGHT_ONLY: basic filename/base/draft hazards absent. NOT approval to merge.

This tool does not prove merge-tree compatibility, dependencies, Flutter compilation, CI status, signing/rights compliance or release readiness. Use existing tools/agents/conflict_arbiter.py and tools/automation/rebase_healer.py with verified refs to simulate integration without changing shared branches.

## Recommended non-destructive merge order

1. Fetch canonical HEAD and confirm file ownership.
2. Resolve private #96 versus #97, #95 versus #99 versus #104, and public #100 versus #101.
3. Reconcile Jules PRs based on main into scoped staging-based integration branches; do not bulk-retarget Draft PRs.
4. Run isolated merge-tree preflight and focused regressions.
5. Fetch target HEAD again before each verified squash merge; record merge SHA.
6. Leave failed or unrun checks, uncertain rights, unsigned releases and destructive pack changes unmerged.

Read-only GET requests run through gh api. No automated merge, edit, workflow dispatch or other GitHub write operation is implemented.
