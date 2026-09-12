# V284 — Backend Session Credential Contract Design

## Status

APPROVED FOR IMPLEMENTATION — scope approved by the user's continuation instruction.

## Goal

Define the semantic contract for the opaque credential used to restore an authenticated application session, without selecting a concrete token format, storage package, or production backend.

## Contract

`SecureSessionCredentials` remains opaque to the application. A future backend/session adapter may issue, validate, renew, revoke, or reject it, but the mobile learning layer must never interpret its contents or derive authorization from it.

The lifecycle is:

1. Authentication succeeds and a credential may be returned to the session boundary.
2. The credential may be stored only through `SecureSessionStorage`.
3. Restoration reads the opaque credential and presents it to the backend session boundary.
4. Invalid, expired, revoked, malformed, or rejected credentials produce an unauthenticated state.
5. Logout clears local credentials regardless of remote logout outcome.
6. Credential replacement must overwrite the previous stored credential atomically at the storage abstraction boundary.

## Ownership

- Backend: authoritative issuer/validator/revoker of session credentials.
- Authentication service: owns authentication lifecycle and coordinates credential handling.
- SecureSessionStorage: owns credential persistence only.
- AccountSession: exposes identity/session state but never credential material.
- LearnerRepository: unrelated to authentication credentials.
- Subscription/entitlement: separate backend-authoritative subsystem.

## Security Rules

- Credential values are opaque and never parsed by learner/application code.
- No password, OTP value, provider assertion, payment data, or entitlement is stored as session credential metadata.
- No credential is placed in `AccountSession`, learner state, content, logs, screenshots, or user-facing diagnostics.
- No SharedPreferences storage for authentication credentials.
- No client-side Premium decision based on credential contents.
- Missing, malformed, expired, revoked, or rejected credentials fail closed.
- Logout clears local credentials even when remote sign-out fails.
- No unnecessary device fingerprinting or account metadata.

## Non-goals

No JWT decision, token format, refresh-token policy, TTL, endpoint URL, HTTP implementation, secure-storage package, provider SDK, billing, sync, account linking, or production backend is selected here.
