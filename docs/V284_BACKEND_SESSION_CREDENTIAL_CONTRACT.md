# V284 — Backend Session Credential Contract

## Status

VERIFIED

## Scope

V284 defines the semantic contract for an opaque backend session credential. It does not select JWT, another token format, refresh policy, TTL, an HTTP implementation, a secure-storage package, provider SDKs, or a production backend.

## Implemented boundary

- `SecureSessionCredentials` contains only one opaque `value`.
- `AccountSession` remains credential-free.
- Backend transport responses may carry an opaque credential separately from the canonical account session.
- Successful authentication validates the authenticated `AccountSession` before storing the returned credential.
- Session restoration reads the credential only through `SecureSessionStorage` and sends it through the backend transport boundary.
- Missing credentials fail closed to unauthenticated state.
- Logout retains the V283 guarantee that local credential storage is cleared even when remote sign-out fails.
- No authentication credential is stored in `SharedPreferences`.

## Security decisions

The client never parses credential contents, derives Premium access from them, or copies them into learner state. Credential material is excluded from application-facing `AccountSession` and remains outside content and learner persistence.

A credential received alongside an invalid/missing session is not stored. This prevents an unusable backend response from becoming a locally retained authentication secret.

## Verification

- Focused V284 structural tests: **8 passed**
- Full Python regression: **333 passed**
- Security Audit: **PASS**
- Privacy Audit: **PASS**
- Architecture Audit: **PASS**
- Accessibility Audit: **PASS**
- Quality Audit: **PASS**
  - Content entries: 14,813
  - Unique IDs: 14,813
  - Unique German entries: 14,813
- Credential persistence/source scan: **PASS**
- Flutter/Dart/APK: **NOT RUN** (toolchain unavailable in this environment)

## Files

- `lib/models/secure_session_credentials.dart`
- `lib/models/backend_authentication_api.dart`
- `lib/models/backend_transport.dart`
- `lib/services/authentication.dart`
- `lib/services/backend_authentication_api.dart`
- `lib/services/secure_session_storage.dart`
- `test/auth/backend_session_credential_contract_test.dart`
- `tests/test_v284_backend_session_credential_contract.py`

## Deferred to a later approved stage

Concrete token format, renewal/refresh semantics, server endpoints, secure platform storage implementation, real provider integrations, billing/entitlements, and account synchronization remain intentionally deferred.
