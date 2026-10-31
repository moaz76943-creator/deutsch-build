# V303 — Learning Core Content Dependency Inversion

## Status

VERIFIED

## Purpose

Close the final language-boundary leak in the learning core by removing the runtime dependency on the German content singleton.

## Findings

`lib/core/learning_core.dart` directly imported and queried `ContentEngine.instance`. This made a reusable learning algorithm depend on the application's current content source and therefore weakened future language reuse.

## Change

Content-dependent operations now receive an explicit `Iterable<ContentItem>` corpus:

- `LearningCore.due(...)`
- `LearningCore.weakestItemForSkill(...)`

The `LearningCore` implementation no longer imports `ContentEngine` or queries its singleton.

The presentation layer passes the selected content boundary explicitly.

## Ownership

- Content source selection remains outside LearningCore.
- LearnerState ownership remains in LearnerRepository.
- Learning algorithms remain in LearningCore.
- No persistence schema changes.
- No authentication, subscription, or billing changes.
- No content data changes.

## Verification

- Focused V303 tests: PASS (3/3)
- Full Python regression: PASS (389/389)
- Security audit: PASS
- Quality audit: PASS
- Content: 14,813 entries / 14,813 unique IDs / 14,813 unique German entries
- Flutter/Android build: NOT RUN in this environment because Flutter/Dart/Android build tooling is unavailable.

## Compatibility

This change strengthens compatibility with a future second language project without introducing a multi-language runtime into Deutsch بالعربي.
