# V285 — Session Renewal & Revocation Contract

## Status

VERIFIED

## Scope

V285 defines provider-neutral renewal and revocation semantics above the existing backend authentication transport. It does not introduce a production backend, HTTP implementation, token format, TTL, provider SDK, or concrete platform secure-storage package.

## Security boundary

- `AccountSession` remains credential-free.
- Credentials remain opaque and are handled only through `SecureSessionStorage` and backend authentication boundaries.
- Renewal requires a valid authenticated session and a replacement credential; otherwise local credentials are cleared and authentication fails closed.
- Backend authentication failures during renewal clear local credentials.
- Revocation is attempted with the current opaque credential when available, while local credential state is cleared in `finally`.
- Learner state and subscription authority remain outside this subsystem.
- No authentication credentials are stored in `SharedPreferences`.

## Contract additions

`BackendTransportOperation` now includes `renewSession` and `revokeSession`.

`BackendTransportRequest` and `BackendAuthenticationApiRequest` expose provider-neutral constructors for those operations using only `SecureSessionCredentials`.

`BackendAuthenticationGateway` exposes renewal and revocation. `AuthenticationService` exposes `renewSession`; `signOut` uses the revocation boundary and preserves local fail-closed cleanup.

## Verification

- Focused V285 tests: 10 passed.
- Full Python regression: 343 passed.
- Security Audit: PASS.
- Privacy Audit: PASS.
- Architecture Audit: PASS.
- Accessibility Audit: PASS.
- Quality Audit: PASS — 14,813 entries; 14,813 unique IDs; 14,813 unique German entries.
- Credential/shared-preferences boundary scan: PASS.
- Flutter/Dart/APK: NOT RUN because the required toolchain is unavailable in this environment.

## Compatibility

The contract remains provider-neutral and keeps the language-learning domain independent from authentication lifecycle state. It is suitable as a pattern for future language projects, but no code is copied into another project automatically.
