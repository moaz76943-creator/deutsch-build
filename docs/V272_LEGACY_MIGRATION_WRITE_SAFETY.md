# V272 — Legacy Migration Write Safety

## Goal
Ensure legacy verb favorites are never removed unless the canonical learner-state write succeeds.

## Finding
`PreferencesService.setString()` returns `Future<bool>`, but the repository previously ignored the result. A failed canonical write could therefore be followed by legacy cleanup, risking loss of the only surviving copy of favorites.

## Change
`LearnerRepository.save()` and `_saveNow()` now fail closed when `prefs.setString()` returns `false`. The legacy migration already performs canonical persistence before removing `verb_favorites_v1`, so a failed canonical write prevents legacy removal.

## Safety properties
- Canonical cache is updated only after a successful write.
- Legacy favorites remain available when canonical persistence fails.
- No content migration or destructive data cleanup was introduced.
- Existing persistence bounds remain in force.

## Verification
- Focused V272 tests: 2 passed after an observed red failure.
- Full regression: 270 passed.
- Privacy/security/quality/accessibility/architecture audits: PASS.
- Weakness gate: PASS.
- Content compiler + parity: PASS (14,813 content rows; 11,718 verb rows).
- Flutter/APK/AAB runtime build remains unverified because the environment lacks Flutter/Android SDK.
