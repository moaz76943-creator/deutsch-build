# Deutsch بالعربي — V278 Authentication Provider Stage

## Base
V277 — Account Contract Stage.

## Goal
Place Email OTP, Google, and Apple behind the approved provider-neutral authentication boundary without coupling authentication to learner data or creating client-side payment authority.

## Implemented
- Added explicit `AuthenticationFailure` codes.
- Added `EmailOtpProvider` and `SocialAuthenticationProvider` adapter contracts.
- Added `ProviderAuthenticationService` to orchestrate the three independent providers.
- Added fail-closed unavailable adapters for Email OTP, Google, and Apple until a production backend/provider contract is selected.
- Authenticated results are accepted only when they contain a canonical `AccountIdentity`.
- Session state is held in memory in this stage; no credential persistence was introduced.
- Expired sessions are cleared when `currentSession` is read.
- Sign-out clears authentication session state only.

## Data minimization
No password, OTP value, access token, refresh token, payment method, card data, or learner-progress field is modeled or persisted by the authentication provider stage.

## Boundaries preserved
- `LearnerRepository` unchanged.
- `LearnerState` unchanged.
- `pubspec.yaml` unchanged; no dependency added or upgraded.
- `SubscriptionService` remains fail-closed.
- No sync, billing, entitlement backend, provider-specific UI, or account deletion workflow was introduced.

## Explicit limitation
The current environment has no Flutter/Dart executable. Therefore real Google/Apple platform callbacks, Email OTP network exchange, Flutter tests, Android builds, and APK runtime behavior are not claimed by this source-only stage.

## Next stage
Session integration: expose authentication state to account UI while keeping learner progress and local persistence independent.
