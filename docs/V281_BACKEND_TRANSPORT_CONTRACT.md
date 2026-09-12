# V281 — Backend Transport Contract

## Status

**TESTED** — structural/regression verification passed. Flutter/Dart/APK verification remains not run because the current environment does not provide the Flutter/Dart toolchain.

## Purpose

V281 introduces a platform-neutral transport boundary below the V280 backend authentication gateway. It prepares the architecture for a real backend without selecting a backend vendor, inventing production endpoints, or adding a network client prematurely.

## Boundary

```text
Provider adapters / Email OTP
            |
            v
BackendAuthenticationGateway
            |
            v
BackendTransport
            |
            v
Real backend transport (future stage)
```

`BackendTransport` is provider-neutral and has no dependency on learner state, subscription state, provider SDKs, or persistence.

## Contract

`BackendTransportRequest` carries one of five transient operations:

- request Email OTP
- verify Email OTP
- authenticate with a provider assertion
- retrieve current session
- sign out

`BackendTransportResponse` exposes only an optional `AccountSession`.

`BackendTransportFailureCode` defines stable categories for invalid authentication, rate limiting, provider rejection, unavailable service, invalid session, and retryable failures.

The authentication gateway maps transport failures into application-level `AuthenticationFailure` categories.

## Fail-Closed Default

`UnavailableBackendTransport` is the runtime implementation in this stage. It rejects backend operations with an explicit unavailable failure. `main.dart` wires this implementation through `TransportBackendAuthenticationGateway`.

No real URL, endpoint, HTTP client, provider SDK, credential, token, OTP value, or payment data was introduced.

## Security / Privacy

- No authentication credentials are persisted by the transport layer.
- OTP and provider assertions are transient request inputs only.
- `AccountSession` remains credential-free.
- Learner data remains outside authentication/transport.
- Premium entitlement remains server-authoritative and outside this contract.
- No new dependency was added.

## Verification

- Baseline before V281: 308 Python tests passed.
- V281 focused structural tests: 6 passed.
- Final Python regression: **314 passed**.
- Content quality audit: **PASS** (14,813 entries; 14,813 unique IDs; 14,813 unique German entries).
- Security audit: **PASS**.
- Privacy audit: **PASS**.
- Architecture audit: **PASS**; oversized files: 0.
- Flutter/Dart tests and APK build: **NOT RUN** — Flutter/Dart are unavailable in the current environment.

## Non-goals

V281 does not implement a production backend, HTTP client, endpoint schema, token format, refresh mechanism, secure credential storage, provider SDK integration, account linking/deletion, billing, or learner-data synchronization.
