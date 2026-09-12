# V130 — Global Resilience & UI Recovery

Version 1.76.0+86 / Android versionCode 86.

## Changes
- Global `runZonedGuarded` async error containment.
- Global Flutter `ErrorWidget.builder` recovery surface.
- Lifecycle-safe home refresh.
- Speech callback boundary catches consumer exceptions and resets initialization after plugin failure.
- Speech practice stop path is lifecycle-safe.
- Legacy verb favorite actions are guarded against disposed widgets and failed persistence.

## Verification
- Python test suite: 145 passed.
- Static quality/security/content audits and Python compile checks are part of the release gate.
- Real Android build/device QA remains required because Flutter SDK is unavailable in this environment.
