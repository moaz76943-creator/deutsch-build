# Deutsch بالعربي — V277 Account Contract Stage

## Phase
P0 Security / Account Boundary — Stage 1: Account Contract.

## Base
V276 — Account Boundary Design.

## Implemented
- Added provider-neutral `AccountIdentity`.
- Added `AccountProvider` for Email OTP, Google, and Apple.
- Added immutable `AccountSession` with authenticated/unauthenticated state and optional expiry metadata.
- Added `AuthenticationService` interface with the V276 provider-neutral operations.
- Added focused Dart contract tests and Python source-boundary regression tests.

## Data minimization
The account/session models contain only the minimum identity/session metadata needed by this contract. No password, OTP value, provider token, payment data, or learner-progress field is modeled or stored.

## Boundaries preserved
- `LearnerRepository` is unchanged.
- No learner-state migration or rewrite.
- No `SharedPreferences` usage was added to the authentication boundary.
- `SubscriptionService` remains fail-closed.
- No real provider integration, backend, sync, billing, or provider UI was introduced.
- `pubspec.yaml` is unchanged; no dependency was added or upgraded.

## Verification
- Focused V277 contract tests: **6 passed**.
- Existing V251–V275 regressions + V277 contract tests: **47 passed**.
- Full Python regression suite: **282 passed**.
- Security audit: **PASS**.
- Privacy audit: **PASS**.
- Secret-pattern scan: **0 hits**.
- LearnerRepository source comparison against V276: **unchanged**.
- `pubspec.yaml` comparison against V276: **unchanged**.
- Flutter/Dart test execution: **BLOCKED** because the current environment has no `flutter` executable.
- Android/APK build and runtime verification: **not claimed**.
