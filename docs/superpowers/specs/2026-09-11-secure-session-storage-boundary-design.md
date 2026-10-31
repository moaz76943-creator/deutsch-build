# V283 — Secure Session Storage Boundary Design

## Status

PROPOSED — architecture approved by the user's continuation instruction; implementation follows the plan after this design artifact is recorded.

## Goal

Define a credential-safe storage boundary for future authenticated sessions without adding a concrete secure-storage dependency or persisting credentials in this stage.

## Ownership

`AuthenticationService` and `AuthSessionController` own authentication lifecycle semantics. A future `SecureSessionStorage` owns only opaque session credentials needed for restoration. `LearnerRepository` remains unrelated. Subscription/entitlement remains backend-authoritative.

## Contract

The boundary exposes only transient storage operations such as save, read, and clear for an opaque credential bundle. `AccountSession` remains credential-free. The concrete storage mechanism is deliberately deferred.

## Security rules

- Never use SharedPreferences for authentication credentials.
- Never log, serialize, expose, or place credentials in learner state, content, tests, screenshots, or documentation.
- Missing, malformed, expired, or rejected stored credentials fail closed.
- Logout clears stored authentication credentials even when backend logout reports failure.
- No device fingerprinting or unnecessary account metadata.
- No production credential values are introduced.

## Non-goals

No secure-storage package selection, platform implementation, token format, refresh-token policy, backend endpoint, provider SDK, billing, or learner synchronization is introduced by V283.
