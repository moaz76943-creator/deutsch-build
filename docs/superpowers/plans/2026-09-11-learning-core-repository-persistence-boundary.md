# Learning Core ↔ Repository Persistence Boundary — Implementation Plan

## Goal

Separate physical learner persistence from canonical learner-state orchestration without changing behavior or data ownership.

## Checklist

- [x] Inspect Learning Core, Content, Repository, and UI boundaries.
- [x] Identify repository storage/serialization responsibility overload.
- [x] Add a failing architectural boundary test first.
- [x] Create `LearnerPersistence` with the existing bounded load/save/migration/cleanup behavior.
- [x] Keep storage keys owned by `LearnerRepository` and pass them explicitly.
- [x] Make repository cache lifecycle delegate physical persistence operations.
- [x] Update structural tests to assert the new responsibility boundary rather than obsolete implementation placement.
- [x] Update privacy audit ownership detection for explicit key passing.
- [x] Run full Python regression suite.
- [x] Run security, privacy, quality, accessibility, architecture, and weakness audits.
- [x] Record final verification and archive without embedding unnecessary prior release archives.
