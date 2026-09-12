# Deutsch بالعربي — V276 Account Boundary Design

## Status
Design approved at the product-direction level; implementation intentionally not started until the written specification is reviewed.

## Goal
Introduce an optional account boundary that supports Email OTP, Google, and Apple authentication without making an account mandatory for core learning.

## Product rules
1. First-run learning works without authentication.
2. Authentication is required only for account-dependent capabilities such as cloud sync and paid features.
3. Local learning state remains owned by `LearnerRepository`.
4. Authentication never directly mutates learner progress.
5. Logout does not delete local learning progress.
6. Account deletion is a separate future operation from logout and local-data deletion.
7. Paid entitlement is never authoritative in `SharedPreferences` or another client-local flag.
8. Paid authorization is enforced by the backend using a trusted entitlement source.
9. No backend secret, service credential, private signing key, or privileged API credential is embedded in the APK.
10. Google, Apple, and Email OTP are authentication methods for one account identity, not three separate account types.

## Authentication model
The client-facing authentication boundary exposes provider-neutral operations:

- `AuthenticationService.currentSession`
- `AuthenticationService.signInWithEmailOtp(...)`
- `AuthenticationService.signInWithGoogle(...)`
- `AuthenticationService.signInWithApple(...)`
- `AuthenticationService.signOut()`

The exact provider SDKs and backend implementation are implementation choices and must remain behind this boundary.

A successful provider authentication resolves to one canonical backend user identity. Provider identities are linked server-side. The client must not decide that two provider identities represent the same person based only on email strings.

## Data flow

```text
Core learning
    │
    ▼
LearnerRepository ───────────────► Local learner state
    │
    │ optional authenticated sync
    ▼
SyncService
    │
    ▼
Backend API ──► User Identity
              ├─► Subscription / Entitlement
              └─► Cloud learner state

AuthenticationService
    ├─ Email OTP
    ├─ Google
    └─ Apple
             │
             ▼
        canonical User ID
```

Authentication/session state is separate from learner state. Sync is the only future boundary allowed to translate authenticated cloud state into local learner state, under an explicit conflict policy.

## Security boundary
- Access tokens/session credentials are not stored in the learner-state JSON.
- The existing local persistence boundary remains limited to learner-owned data.
- The server is authoritative for account identity, paid entitlement, and protected operations.
- Client UI may hide or show features based on session state, but protected backend operations must independently authorize the request.
- Authentication failure is fail-closed: the user remains able to use offline/core learning, while account-dependent operations are unavailable.
- Provider callbacks/deep links must validate the expected state/nonce according to the selected provider implementation.

## Subscription boundary
`SubscriptionService` remains a trusted-entitlement interface rather than a local payment database. The current fail-closed implementation stays intact until a real billing/store-verification backend exists.

Future paid flow:

```text
Store / billing provider
        │
        ▼
Trusted backend verification
        │
        ▼
Server entitlement
        │
        ▼
Authorized API response
        │
        ▼
Client capability state
```

The client must never grant premium access merely because a local value says `premium=true`.

## Local-state compatibility
Existing learner progress, favorites, review data, and other canonical local state remain intact. Adding authentication must not require a content migration or learner-state rewrite.

Logout preserves local progress. Account sign-in does not silently replace local progress with cloud progress. A later sync phase will define explicit import/merge behavior and will be separately tested.

## Failure behavior
- Invalid/expired OTP: authentication remains unauthenticated; core learning continues.
- Provider cancellation: no learner-state mutation; core learning continues.
- Provider/network outage: no authenticated session is fabricated; core learning continues.
- Session expiry: protected operations fail closed and session state becomes unauthenticated/re-authentication-required.
- Backend entitlement unavailable: paid operation fails closed rather than granting access.
- Sign-out failure: local learner state is preserved; session clearing behavior must be explicitly reported rather than pretending success.

## Testing strategy
Before implementation, each authentication boundary gets focused tests for:
- provider success and canonical user identity mapping;
- provider cancellation/failure;
- invalid and expired OTP;
- session expiry;
- sign-out without learner-state deletion;
- no premium grant from local storage;
- protected-operation denial when entitlement is absent/unavailable;
- preservation of the existing learner persistence tests.

Real provider login and Android/iOS callbacks require platform-capable environments and will not be claimed from the current environment, which lacks the Flutter/Android toolchain.

## Staged implementation
1. **Account contract stage:** provider-neutral interfaces, immutable session model, and tests; no real provider login yet.
2. **Authentication provider stage:** Email OTP, Google, and Apple adapters behind the contract, with platform/backend integration.
3. **Session integration stage:** connect authentication state to account UI without coupling it to learner progress.
4. **Entitlement stage:** trusted backend entitlement contract and server authorization; client remains fail-closed.
5. **Sync stage:** authenticated cloud synchronization with an explicit conflict/data-ownership policy.

No stage may remove existing learning content or replace the current local persistence model wholesale.

## Explicitly deferred
- Account deletion workflow.
- Cloud sync conflict resolution.
- Billing-provider implementation and store verification.
- Provider-specific UI details.
- Backend infrastructure/vendor selection.

These are separate stages and will not be silently invented during the contract stage.
