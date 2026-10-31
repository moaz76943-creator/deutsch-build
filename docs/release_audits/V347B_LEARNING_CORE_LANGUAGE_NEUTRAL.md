# V347b — LearningCore Language-Neutral Boundary

## Baseline

- Starting snapshot: V347a
- Scope: `LearningCore` content dependency inversion only

## Changes

- `LearningCore` now imports the language-neutral `LearningContent` contract.
- Content-dependent methods are generic over `T extends LearningContent`.
- Learnability is an explicit injected policy (`bool Function(T item)`).
- German-specific `ContentQuality` remains outside Core and is supplied by the German UI boundary.
- `ContentItem` remains unchanged as the compatibility implementation of `LearningContent`.
- Existing SRS, Mastery, learner state, IDs, content data, and learning-selection formulas were not intentionally changed.
- Existing stale static assertions were migrated to the new generic contract rather than weakening the architectural guarantees.

## Verification

```text
Focused V347b tests: 5 passed
Full pytest regression: 493 passed
Architecture audit: PASS
Quality audit: PASS
Security audit: PASS
Privacy audit: PASS
Accessibility audit: PASS
Weakness gate: PASS
```

Flutter/Dart `analyze` and APK build were not run because Flutter/Dart is not installed in the execution environment.
