# V290 — Authentication Gateway Contract Hardening

## Status

VERIFIED

## Scope

V290 is a narrowly scoped authentication-contract hardening pass discovered during post-V289 review. It does not add providers, endpoints, credentials, billing, learner synchronization, or new dependencies.

## Root cause

`TransportBackendAuthenticationGateway` already implemented `renewSession` and `revokeSession` with `@override`, but `BackendAuthenticationGateway` did not declare those lifecycle operations. That creates a Dart contract mismatch and would fail compilation once the Dart toolchain is available.

A second lifecycle weakness was found in `ProviderAuthenticationService.signOut`: reading secure storage happened before the cleanup-protected `try/finally`, so a storage-read failure could bypass the local cleanup path.

A third hardening gap was found in `TransportBackendAuthenticationGateway.getCurrentSession`: a backend response containing an unauthenticated session did not explicitly clear the locally stored credential before returning the invalid-session result.

## Changes

- Declared `renewSession` and `revokeSession` on `BackendAuthenticationGateway`.
- Made `ProviderAuthenticationService.signOut` protect both credential read and backend revocation with cleanup/finally semantics.
- Made rejected/unauthenticated backend restoration clear the local credential before failing closed.
- Updated the existing V284 structural test so it verifies ordering without assuming a specific implementation spelling.
- Added V290 regression tests for the contract and lifecycle cleanup invariants.

## Security and privacy boundaries preserved

- No credential values were introduced.
- No token format was selected.
- No secrets are logged or serialized.
- Authentication credentials remain outside `LearnerRepository` and learner state.
- No authentication credentials use `SharedPreferences`.
- Premium/entitlement authority remains server-side.
- No dependency or build-toolchain change.

## Verification

- Focused V290 tests: PASS (3/3)
- Full Python regression: PASS (363/363)
- Quality audit: PASS — 14,813 entries, 14,813 unique IDs, 14,813 unique German entries
- Security audit: PASS
- Privacy audit: PASS
- Accessibility audit: PASS — 0 warnings
- Architecture audit: PASS — 0 oversized files

Flutter/Dart/APK execution was not available in the current environment, so those checks remain NOT RUN rather than being represented as passing.
