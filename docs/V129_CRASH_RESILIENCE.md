# V129 — Crash Resilience 2.0 + Plugin Isolation

Version 1.75.0+85 / Android versionCode 85.

## Reliability hardening
- Centralized failure-safe TTS wrapper for UI speech paths.
- Failure-safe TTS stop and shutdown disposal.
- Speech recognition initialize/listen/stop now absorb platform/plugin failures and return safe states.
- Privacy settings reads fall back to `false`; writes are failure-safe.
- Voice conversation selects a valid scenario or a local fallback instead of assuming `.first`.
- Voice turns defensively clamp the current index and provide a safe fallback turn.
- AI writing gateway is closed from `finally`, including failed requests.
- AI conversation gateway is closed from `finally`, with safe local fallback on settings/network failures.
- Mistake repair checks lifecycle after persistence.
- Legacy UI TTS path is also isolated from plugin failures.

## Verification
Flutter SDK is not installed in this environment, so Android runtime/APK verification remains pending. Static and Python regression tests are used here.
