# V282 — Backend API Authentication Protocol Design

**Status:** APPROVED FOR IMPLEMENTATION

## Goal
Define the semantic authentication API contract above the V281 transport boundary without selecting a production backend, HTTP stack, token format, or persistence mechanism.

## Boundary
The API protocol describes authentication operations and their transient inputs/outputs. `BackendTransport` remains responsible only for carrying provider-neutral requests. The protocol owns no learner state, subscription state, credentials, secrets, or persistence.

## Operations
1. Request Email OTP: email in; no session required in the response.
2. Verify Email OTP: email + OTP in; canonical `AccountSession` out.
3. Provider authentication: provider assertion in; canonical `AccountSession` out.
4. Current session: no application payload; canonical `AccountSession` out, or unauthenticated/failure semantics.
5. Sign out: no application payload; no session payload required.

## Error semantics
Stable authentication failure categories are mapped to the existing application failure categories. A successful authentication operation must contain an authenticated session with identity; missing/invalid sessions fail closed.

## Explicit non-goals
No real endpoint, base URL, HTTP implementation, serialization format, token format, refresh-token mechanism, secure credential storage, provider SDK, backend vendor, billing, account linking/deletion, or learner synchronization.
