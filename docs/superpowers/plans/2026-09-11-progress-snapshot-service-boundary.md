# Implementation Plan: Progress Snapshot Service Boundary

## Checklist
- [x] Add a failing architecture test.
- [x] Introduce `ProgressSnapshotService` with the existing calculation logic.
- [x] Reduce `ProgressSnapshot` to a passive immutable model.
- [x] Update UI callers to use the service.
- [x] Remove stale model imports.
- [x] Run focused RED/GREEN test.
- [x] Run full Python regression.
- [ ] Run Flutter/Android build when the required toolchain is available.
