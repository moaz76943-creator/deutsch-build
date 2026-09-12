# V280 — Backend Authentication Contract

## Status

**TESTED (contract stage)**

This stage implements the provider-neutral mobile/backend authentication boundary only. It does **not** implement a production backend, provider SDKs, billing, entitlement verification, or persistent credential storage.

## Implemented boundary

- `BackendAuthenticationGateway` is the single provider-neutral backend boundary.
- Google and Apple adapters produce transient `ProviderAuthenticationAssertion` values; they do not create canonical application identities.
- Email OTP verification is delegated to the backend gateway.
- The backend result is accepted only as an authenticated `AccountSession` with a non-null canonical `AccountIdentity.userId`.
- `AccountSession` and `AccountIdentity` remain free of passwords, OTP values, access tokens, refresh tokens, payment data, and learner data.
- `AuthSessionController` remains responsible only for transient application authentication state.
- The shipped backend gateway is `UnavailableBackendAuthenticationGateway`, which fails closed for authentication operations until a real backend is selected and integrated.

## Security and privacy boundary

Production backend integration must enforce OTP expiry, replay prevention, rate limiting, provider assertion validation, TLS-only transport, session revocation, input validation, abuse detection, and server-side authorization. Those mechanisms are deliberately not faked in this stage.

No backend URL, credential, token, secret, provider profile payload, or payment data is embedded in the app.

## Verification

- Python regression suite: **308 passed**.
- Security audit: **PASS**.
- Privacy audit: **PASS**.
- Architecture audit: **PASS**.
- Flutter/Dart tests: **NOT RUN** — Flutter/Dart toolchain is unavailable in the current environment.
- Android APK build: **NOT RUN** — Android/Flutter build toolchain is unavailable in the current environment.

The absence of Flutter/Dart verification prevents this stage from being called `VERIFIED`, `RELEASE CANDIDATE`, or `RELEASED`.

## Next production prerequisites

Before enabling real authentication, select and review the backend platform and define its concrete token/session protocol, secure storage strategy, expiry/refresh policy, provider verification implementation, revocation model, account recovery policy, and operational abuse controls. These choices require a separate implementation decision; none are inferred here.
