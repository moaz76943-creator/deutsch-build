# V297 — Learning Core Repository Ownership Plan

## Goal
Restore the architectural boundary between learning-domain logic and persistence.

## Steps
- [x] Add failing architecture test proving `LearningCore` must not import `repository.dart`.
- [x] Remove the stale unused repository import.
- [x] Run the targeted test.
- [x] Run the full Python regression suite.
- [x] Record verification and archive the source tree without unnecessary generated artifacts.
