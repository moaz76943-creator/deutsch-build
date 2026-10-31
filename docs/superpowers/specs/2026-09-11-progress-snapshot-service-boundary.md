# Progress Snapshot Service Boundary

## Goal
Keep `ProgressSnapshot` as a passive output model and move learner-progress calculations into an application service.

## Boundary
- `ProgressSnapshot`: immutable DTO only.
- `ProgressSnapshotService`: owns derivation from `Attempt` and `AssessmentHistory`.
- UI reads the service output and does not calculate persistence or mastery itself.
- No changes to stored learner-state schema.

## Compatibility
The existing calculation formula, skill keys, level labels, weakest-skill behavior, and assessed-count behavior remain unchanged.
