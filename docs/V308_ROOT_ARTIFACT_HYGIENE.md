# V308 — Root Artifact Hygiene

## Change

Removed the stray root-level `V297_RELEASE_NOTES.md` file.

Release notes belong under `docs/`, while the repository root remains reserved for active project entrypoints and canonical configuration.

## Safety

- No source code or learner/content data was changed.
- Historical release archives were not deleted or modified.
- The regression test `tests/test_v308_root_artifact_hygiene.py` prevents new `V*_RELEASE_NOTES.md` files from accumulating at the root.
