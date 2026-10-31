# V302 — Language-Agnostic Core Boundary

Status: VERIFIED

## Finding
`lib/core/learning_core.dart` contained `WordDepth` plus a hard-coded German/Arabic enrichment table. That content-specific data belonged to the language/content layer and made the core harder to reuse for another language.

## Change
Moved the language-specific enrichment contract and current German/Arabic entries to `lib/services/content_depth.dart` and updated the learning UI to consume that boundary directly.

No learner state, persistence, authentication, subscription, or content identifiers were changed.

## TDD
- Added `tests/test_v302_language_agnostic_core_boundary.py`.
- RED confirmed before production change.
- GREEN after the minimal move.

## Verification
- Focused V302 tests: 2/2 PASS
- Full Python regression: 386/386 PASS
- Security/privacy scan: PASS
- No embedded credentials or API secrets found in application source.
- No non-service SharedPreferences access found.
- Local premium entitlement mutation remains disabled and `isPremium()` remains fail-closed.
- Language-specific German enrichment is no longer owned by `LearningCore`.

## Known environment limitation
Flutter/Dart/Gradle/Android toolchains are not installed in the current execution environment, so Android/Flutter build verification was not claimed.
