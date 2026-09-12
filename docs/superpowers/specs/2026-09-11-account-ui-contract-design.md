# Account UI Contract Design

## Purpose

Provide a small account surface for authentication without making an account a prerequisite for local learning and without allowing the UI to become an authority for subscription or learner state.

## Boundaries

`AccountPage` receives only `AuthSessionController`. It reads transient account state and invokes controller methods. It does not access `LearnerRepository`, `SubscriptionService`, persistence adapters, credentials, or network transports.

## Authentication flows

- Email OTP: enter email, request OTP, then submit OTP through the controller.
- Google: invoke the existing provider-neutral controller action.
- Apple: invoke the existing provider-neutral controller action.
- Sign out: invoke controller sign-out and render unauthenticated state.

The current adapters remain unavailable/fail-closed, so the UI must not imply that provider authentication is active when it is not.

## Privacy and security

The page must not display or persist OTP values, passwords, tokens, payment data, or raw authentication exceptions. Only the non-secret internal user ID and provider label may be displayed for an authenticated session.

## Subscription separation

The account page never reads or mutates Premium entitlement. Subscription remains a separate authority boundary and remains fail-closed until a trusted backend/billing integration exists.

## Verification

Focused source-contract tests cover the dependency boundary and secret exclusions. The full Python regression suite and repository security/privacy/quality/accessibility/architecture audits are required. Flutter compilation remains an environment-dependent verification step when the toolchain is available.
