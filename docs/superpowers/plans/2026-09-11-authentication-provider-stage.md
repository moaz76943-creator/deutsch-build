# Authentication Provider Stage Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Put Email OTP, Google, and Apple behind the V277 authentication contract without introducing secrets, learner-state coupling, or client-side entitlement authority.

**Architecture:** `ProviderAuthenticationService` orchestrates three independent provider adapters. Provider-specific SDK/backend work remains behind those adapters; this source snapshot supplies fail-closed unavailable adapters because no production provider/backend contract has been selected or can be exercised in the current environment. Session state remains in memory and is never written into learner state.

**Tech Stack:** Flutter/Dart contracts and unit tests; Python source-boundary regression tests.

**Spec:** `docs/V276_ACCOUNT_BOUNDARY_DESIGN.md`

## Global Constraints

- Core learning remains usable without authentication.
- Authentication never directly mutates `LearnerRepository`.
- No passwords.
- No OTP persistence.
- No provider access/refresh token persistence in learner state.
- No backend secrets or privileged credentials in the APK/source.
- No local premium grant.
- No sync or billing implementation.
- No dependency changes.
- Fail closed on provider cancellation, failure, expiry, or unavailable integration.
- Do not claim real platform/provider execution without a capable Flutter environment.

---

### Task 1: Define provider failure and adapter contracts

**Files:**
- Modify: `lib/services/authentication.dart`
- Test: `test/auth/provider_authentication_test.dart`
- Test: `tests/test_v278_authentication_provider.py`

- [x] Write failing source-boundary tests for provider adapters and orchestration.
- [x] Run the focused Python tests and confirm the new contract is missing.
- [x] Add `AuthenticationFailure`, `EmailOtpProvider`, and `SocialAuthenticationProvider`.
- [x] Add `ProviderAuthenticationService` with independent Google/Apple adapters.
- [x] Validate that only authenticated results carrying a canonical identity become the current session.
- [x] Run focused Python tests.

### Task 2: Add fail-closed provider adapters

**Files:**
- Create: `lib/services/authentication_providers.dart`
- Test: `test/auth/provider_authentication_test.dart`

- [x] Add `UnavailableEmailOtpProvider` that throws `unavailable` for verification/request.
- [x] Add `UnavailableSocialAuthenticationProvider` for Google and Apple.
- [x] Ensure no credential/token/OTP is persisted.
- [x] Ensure no learner-state dependency exists.
- [x] Add tests for unavailable/cancelled providers producing no authenticated session.

### Task 3: Add session expiry and sign-out regression coverage

**Files:**
- Test: `test/auth/provider_authentication_test.dart`
- Test: `tests/test_v278_authentication_provider.py`

- [x] Test an expired authenticated session becomes unauthenticated on `currentSession`.
- [x] Test sign-out clears only authentication session state.
- [x] Test no learner repository or local persistence API is referenced.

### Task 4: Documentation and versioned release artifact

**Files:**
- Create: `docs/V278_AUTHENTICATION_PROVIDER_STAGE.md`
- Create: `docs/V278_RELEASE_NOTES.md`
- Modify: `DEVELOPMENT_PROGRESS.md` only if present in the source snapshot.

- [x] Document exactly what is implemented and what is deferred.
- [x] Record that real Google/Apple/Email OTP provider execution is not claimed here.
- [x] Record test/toolchain limitations honestly.
- [x] Record data minimization rules and explicit non-goals.

### Task 5: Final verification

- [ ] Run the full Python test suite.
- [ ] Run security/privacy audits available in the snapshot.
- [ ] Check `pubspec.yaml` is unchanged.
- [ ] Check learner-state/repository sources are unchanged.
- [ ] Scan the authentication boundary for passwords, OTP storage, access/refresh tokens, payment data, and learner-state references.
- [ ] Attempt focused Flutter tests and record the environment blocker if Flutter remains unavailable.
- [ ] Package V278 and calculate SHA-256.
