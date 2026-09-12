# Deutsch بالعربي — V347b LearningCore Language-Neutral Boundary

## Status

V347b is the staged follow-up to V347a. It changes only the integration boundary of `LearningCore`.

## Goal

Make `LearningCore` consume `LearningContent` rather than the German-shaped `ContentItem`, while preserving learning behavior and leaving language-specific quality policy outside Core.

## Implemented boundary

- `lib/core/learning_core.dart` imports `content_contract.dart` instead of `models/content.dart`.
- Content-dependent operations are generic over `T extends LearningContent`.
- Learnability is supplied explicitly as `bool Function(T item)`.
- `ContentQuality` is no longer imported or referenced by `LearningCore`.
- German UI remains responsible for selecting the German quality policy via `ContentQuality.isLearnable`.
- `ContentItem` remains the compatibility model and continues implementing `LearningContent`.

## Preserved behavior

No SRS, Mastery, learner-state, content-data, stable-ID, search-ranking, or learning algorithm changes were introduced by this stage.

The existing weakest-item selection and due-item selection logic remains structurally equivalent; only the content type and learnability dependency were inverted.

## Verification

Focused V347b contract tests: 5 passed.
Full pytest regression: 493 passed (V347b baseline).

Flutter/Dart verification was not run because the execution environment does not contain the Flutter/Dart toolchain.
