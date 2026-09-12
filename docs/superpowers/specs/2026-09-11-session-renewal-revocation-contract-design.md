# V285 — Session Renewal & Revocation Contract Design

## Status

APPROVED FOR IMPLEMENTATION — scope approved by the user's continuation instruction.

## Goal

Define provider-neutral session renewal and revocation semantics before any production token format, HTTP implementation, or platform secure-storage implementation is selected.

## Contract

The backend remains authoritative for session validity. Renewal accepts an opaque stored credential and returns a canonical `AccountSession` plus optional replacement credentials. Revocation invalidates the backend session and local credential state is cleared regardless of backend failure.

## Fail-closed rules

- Missing, expired, rejected, or malformed credentials never create an authenticated session.
- A renewal response without a valid authenticated `AccountSession` is rejected.
- A renewal response without replacement credentials clears the existing credential rather than retaining an unverifiable one.
- Backend rejection clears local credentials.
- Logout remains idempotent and clears local state in `finally`.

## Non-goals

No JWT/opaque-token format, TTL, refresh-token format, HTTP client, endpoint URL, provider SDK, billing, entitlement, learner synchronization, or concrete secure-storage package.
