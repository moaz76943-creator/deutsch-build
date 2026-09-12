# Backend HTTP Transport Design

## Goal
Provide a provider-neutral, injectable HTTPS transport for the existing backend authentication contract without introducing a production endpoint, provider SDK, billing logic, or client-side entitlement authority.

## Scope
V325 only establishes the network transport boundary. It serializes the existing semantic authentication requests, sends them to an externally supplied HTTPS base URI, enforces request/response size and timeout limits, decodes the existing typed transport response, and maps transport failures to `BackendTransportFailure`.

The existing authentication gateway remains responsible for session/credential validation and secure-storage lifecycle. The transport never persists credentials, learner data, subscriptions, or provider state.

## Non-goals
- No production backend endpoint is created or hardcoded.
- No Email OTP provider implementation.
- No Google/Apple SDK integration.
- No token parsing or JWT claims extraction.
- No refresh-token design change.
- No billing or premium entitlement implementation.
- No public endpoint or secret embedded in source.

## Request/response wire contract
The transport uses JSON over HTTPS with an operation envelope. Request JSON contains only fields relevant to the operation:

- `operation`: stable lowercase operation name.
- `email`: email for OTP operations.
- `otp`: transient OTP for verification.
- `provider`: provider enum name for provider authentication.
- `assertion`: transient provider assertion for provider authentication.
- `credential`: opaque credential value for current/renew/revoke.

Response JSON contains:

- `session`: nullable object with `isAuthenticated`, optional `userId`, and optional `expiresAt` ISO-8601 string.
- `credential`: nullable opaque credential string.

The parser is strict about top-level JSON shape but does not interpret credential contents.

## Safety bounds
- HTTPS base URI is required; non-HTTPS URIs are rejected.
- Request body is bounded to 32 KiB before network send.
- Response body is bounded to 64 KiB.
- Network timeout is bounded to 15 seconds and is configurable only within a safe range of 1–30 seconds.
- Empty success responses are invalid for operations that require a structured response.
- Unknown/malformed response fields do not create an authenticated session.

## Error mapping
- HTTP 401/403 → `invalidAuthentication` or `invalidSession` according to operation.
- HTTP 408/429 → `retryable` or `rateLimited`.
- HTTP 5xx → `retryable`.
- Network timeout/socket failures → `unavailable`.
- Invalid JSON/oversized response/protocol violation → `unavailable`.

No response body is copied into exception text or logs.

## Existing API reconciliation
`BackendAuthenticationApi.send()` must map every current `BackendAuthenticationOperation` to the matching `BackendTransportRequest`, including `renewSession` and `revokeSession`. This is a correctness fix required before a real transport can be used.

## Testing
Python contract tests verify wire serialization, operation coverage, bounds, HTTPS enforcement, timeout limits, response validation, and failure mapping. Existing regression, security, privacy, quality, accessibility, and architecture gates remain mandatory.
