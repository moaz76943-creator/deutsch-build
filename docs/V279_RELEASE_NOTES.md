# Deutsch بالعربي — V279 Session Integration

## Status

IMPLEMENTED / TESTED (source-level and Python regression). Flutter/Dart runtime verification remains blocked by the available environment.

## Changes

- Added `AuthSessionController`.
- Wired the controller into application startup and app dependency boundaries.
- Kept authentication independent from learner state.
- Authentication failures fail closed.
- Logout does not delete or mutate learner progress.
- Session lifecycle hardening rejects expired restoration, clears stale authentication failures after valid restoration, and keeps restart-like initial state unauthenticated.
- No password, OTP, access token, refresh token, payment data, or credential persistence was added.
- No dependency changes.

## Verification

- Full Python regression: 301 passed.
- Session lifecycle hardening tests: 5 passed.
- The earlier focused V278/V279 baseline remains part of the full regression suite.
- Flutter/Dart tests: NOT RUN — toolchain unavailable.
- Android/APK build: NOT RUN.
