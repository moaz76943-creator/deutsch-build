# Backend Authentication Contract Design

## Status

PROPOSED — architecture approved in conversation at the option level; implementation remains blocked until this design is reviewed.

## Goal

Define a provider-neutral backend authentication boundary that can support Email OTP, Google, and Apple while keeping the mobile client non-authoritative for identity, subscription, and protected resources.

## Architecture

The mobile application communicates with one backend authentication boundary. Provider-specific verification occurs behind that boundary. After successful verification, the backend maps the provider identity to an internal immutable `userId` and establishes an application session. The client exposes only the resulting provider-neutral `AccountSession` through `AuthSessionController`.

The backend is the authority for identity and future protected operations. The client must never infer paid access, entitlement, account ownership, or authorization from local flags or provider identifiers.

## Components and ownership

### Mobile Core / Integration-Sensitive
- `AuthenticationService`: provider-neutral application contract.
- `AuthSessionController`: transient presentation/application session state.
- `AccountSession`: minimal session model.
- Provider adapters: transport/platform integration only; no learner-state ownership.

### Backend / Security-sensitive
- Provider verification boundary.
- Internal account identity mapping.
- Application session issuance.
- Session expiration and revocation.
- Authorization checks for protected endpoints.

### Explicitly separate
- LearnerRepository / learner progress.
- Subscription and entitlement verification.
- Payment data.
- Static language content.

## Identity contract

The backend owns the canonical internal `userId`.

Provider identities are external references and must not become the application's canonical identity. Email addresses are identifiers used for authentication flows only and are not the canonical account key.

Minimum authenticated identity returned to the client:

- `userId`
- optional session expiry metadata

No provider access token, refresh token, OTP value, password, payment credential, or provider secret is part of `AccountIdentity`.

## Authentication flows

### Email OTP

1. Client requests OTP using the email input.
2. Backend generates and sends the OTP through the configured delivery system.
3. Client submits the OTP to the backend.
4. Backend validates the OTP, expiry, attempt limit, and replay protection.
5. Backend resolves or creates the internal account.
6. Backend issues the application session.
7. Client accepts the session only when the response is structurally valid.

OTP values are never persisted in the client and should be short-lived server-side secrets with strict attempt/rate limits.

### Google / Apple

1. Native/provider adapter completes provider-specific authentication.
2. The resulting provider credential/assertion is sent to the backend over authenticated transport.
3. Backend validates the provider assertion against the provider's verification mechanism.
4. Backend resolves the internal `userId`.
5. Backend issues the application session.
6. Client stores only what the approved secure session-storage contract permits.

Provider tokens must not be treated as application authorization.

## Session contract

The application session must be:
- short-lived enough to limit compromise impact;
- revocable server-side;
- renewable through a controlled refresh mechanism;
- invalidated on explicit logout;
- rejected after expiry;
- rejected when the backend reports revocation or invalidity.

The exact token format, refresh mechanism, secure-storage technology, and TTL are deliberately deferred to the implementation plan/backend platform decision rather than invented here.

## Authorization boundary

A successful login does not imply premium access.

Protected operations must be authorized server-side. Future subscription checks must be independent from authentication and must not be represented by a local APK boolean.

## Error handling

The backend must expose stable, non-secret error categories sufficient for the client to distinguish:
- invalid/expired authentication;
- rate limiting;
- provider rejection;
- unavailable service;
- invalid session;
- generic retryable failure.

Detailed provider errors, OTP values, credentials, tokens, internal identifiers, stack traces, and security-sensitive diagnostics must not be returned to ordinary clients.

## Abuse and security controls

Required backend controls before production authentication:
- rate limiting for OTP requests and verification attempts;
- OTP expiration and replay prevention;
- provider assertion validation;
- session revocation;
- input validation;
- audit/security events without sensitive credential values;
- TLS-only transport;
- server-side authorization;
- abuse detection appropriate to the authentication surface.

No client-side mechanism is treated as a complete defense against a modified APK.

## Privacy and data minimization

The authentication backend stores only fields required for account identity, authentication, security, and legally required operational records. Avoid storing duplicate provider profile data, unnecessary email copies, device fingerprints, or learner content in the authentication subsystem.

Learner progress remains owned by the learning-data subsystem.

## Compatibility with Deutsch بالعربي

Reusable concepts:
- provider-neutral `AuthenticationService`;
- minimal `AccountIdentity`;
- transient `AuthSessionController`;
- fail-closed session semantics;
- separation of account identity from learner state.

Do not copy provider SDK code, backend implementation, or security configuration blindly. Compatibility is limited to the stable conceptual contract unless the other project independently validates an adaptation.

## Migration and recovery

Because V279 has no production credential persistence, this stage does not require migration of stored authentication credentials.

Future secure-session persistence must define:
- fresh install behavior;
- upgrade behavior;
- invalid/corrupt secure-storage recovery;
- server-side revoked-session recovery;
- logout cleanup;
- account deletion handling when that feature is separately designed.

## Testing contract

Before production:
- fresh install;
- no existing session;
- valid session;
- expired session;
- revoked session;
- malformed backend response;
- provider rejection;
- OTP expiry;
- OTP replay;
- OTP rate limit;
- repeated authentication attempts;
- logout;
- network unavailable;
- slow network;
- backend 5xx;
- client restart;
- secure-storage corruption;
- subscription boundary remains independent.

Flutter/Dart integration and Android runtime tests are required before any release claim.

## Explicit non-goals

This design does not implement:
- a production backend;
- real Google authentication;
- real Apple authentication;
- real Email OTP delivery;
- payment processing;
- subscription entitlement verification;
- learner synchronization;
- account linking;
- account deletion UI;
- multi-language runtime.

## Self-review

- No provider-specific identity is made canonical.
- No secret or credential is modeled in the client contract.
- Learner state remains outside authentication ownership.
- Subscription authority remains outside the client.
- No unnecessary data fields are introduced.
- Token format and TTL are not invented without platform evidence.
- Production claims remain blocked until real integration and runtime verification.
