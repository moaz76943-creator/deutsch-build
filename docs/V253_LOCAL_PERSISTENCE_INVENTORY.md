# V253 — Local Persistence Inventory

## Purpose

Make the local-storage privacy gate inventory complete for the current app without introducing a new persistence architecture.

## Canonical local keys

| Key | Owner | Purpose | Classification |
|---|---|---|---|
| `v34_state` | `LearnerRepository` | learner progress, attempts, review state, assessment history, favorites | learning data |
| `verb_favorites_v1` | `LearnerRepository` | legacy verb-favorites migration | legacy/migration only |
| `privacy_cloud_ai_v1` | `PrivacySettings` | user's cloud-AI opt-in | preference |
| `privacy_speech_v1` | `PrivacySettings` | user's speech-recognition opt-in | preference |
| `app_learning_preferences_v1` | `PreferencesSettingsLocalDataSource` | speech rate, text scale, translation visibility, cache-clear timestamp | learning preference |

## Boundary rules

- `SharedPreferences` remains behind `PreferencesService`.
- `LearnerRepository` owns learner-state persistence and deletion of learner-state keys.
- `PrivacySettings` owns privacy preference keys.
- `PreferencesSettingsLocalDataSource` owns the non-sensitive learning-preference record; application and presentation code do not access its storage key directly.
- Legacy `verb_favorites_v1` is read only through the repository migration boundary and is removed after successful migration and during learner-data deletion.
- New persistence keys must be explicitly added to the inventory and allowlist; otherwise the privacy audit fails.
- Simple `const`-backed keys are resolved by the audit so key inventory cannot silently disappear because a key is stored in a variable.

## Data-minimization boundary

The current learner-state limits remain unchanged: attempts are bounded, assessment history is bounded, collections are bounded, persisted payloads have a 4 MB safety limit, and malformed records are skipped individually where possible. This stage does not change those limits or discard existing valid user data.

## Verification

The V253 test asserts that the audit discovers all four current application persistence keys, including keys referenced through simple constants.
