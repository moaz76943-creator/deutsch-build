# Plan — V299 Model Boundary Reconciliation

## Checklist

- [x] Add a failing architecture test first.
- [x] Move learner-owned history models out of the content model.
- [x] Remove duplicate `MasteryEvidence` model from content.
- [x] Update stale tests to follow the new ownership boundary.
- [x] Run focused tests.
- [x] Run full regression.
- [x] Archive a clean release snapshot.

## Scope

No UI, authentication, subscription, content data, or persistence schema changes beyond model ownership refactoring.
