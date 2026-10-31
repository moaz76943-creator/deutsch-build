# V279 — Session Integration

## Scope

V279 connects the provider-neutral authentication boundary to the application lifecycle without changing learner data ownership.

## Implemented

- Added `AuthSessionController` as the application-facing session state owner.
- Session state is transient and separate from `LearnerRepository` / `LearnerState`.
- Startup restores the current authentication state through `AuthenticationService`.
- Authentication failures fail closed to an unauthenticated state.
- Logout clears only authentication session state.
- Session lifecycle hardening keeps initialization fail-closed, rejects expired restored sessions, clears stale failure state after valid restoration, and guarantees unauthenticated state after logout failures.
- The app is wired with a fail-closed provider implementation until real provider/backend contracts are available.
- No credentials, OTPs, passwords, or tokens are persisted.

## Deferred

- Production Google authentication.
- Production Apple authentication.
- Production Email OTP backend.
- Secure credential/session persistence.
- Account linking and recovery.
- Sync.
- Billing and entitlement verification.

## Verification

- Session lifecycle hardening tests: PASS (5/5).
- Full Python regression: PASS (301/301).
- Flutter/Dart runtime tests: not run because the current environment does not provide Flutter/Dart.
- No claim of production provider authentication or APK verification.
