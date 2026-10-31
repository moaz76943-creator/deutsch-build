# Backend Transport Contract Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [x]`) syntax for tracking.

**Goal:** Add a platform-neutral, fail-closed transport boundary beneath the V280 backend authentication gateway without inventing a real backend API.

**Architecture:** `BackendAuthenticationGateway` remains the authentication-facing contract. A new `BackendTransport` boundary carries provider-neutral requests/responses and maps transport failures; the current runtime uses an unavailable implementation, so no network endpoint is introduced. Learner state, subscription authority, credentials, and secrets remain outside transport.

**Tech Stack:** Flutter/Dart source contracts, Python structural/regression tests, existing project audit scripts.

**Spec:** `docs/superpowers/specs/2026-09-11-backend-authentication-contract-design.md`

## Global Constraints

- Keep the app offline-first and fail-closed.
- Do not add real backend URLs, endpoints, credentials, tokens, OTP values, or payment data.
- Do not persist authentication credentials in SharedPreferences.
- Keep `LearnerRepository`/`LearnerState` separate from authentication and transport.
- Keep subscription/entitlement authority server-side; no local premium decision.
- Do not add unnecessary dependencies.
- Do not claim Flutter/Dart/APK verification when the toolchain is unavailable.
- Preserve the existing V280 build/security/privacy contracts.

### Task 1: Transport Models and Interface

**Files:**
- Create: `lib/models/backend_transport.dart`
- Test: `tests/test_v281_backend_transport_contract.py`
- Test: `test/auth/backend_transport_test.dart`

- [x] Write structural tests for the new transport contract and minimal request/response models.
- [x] Run the focused structural tests and confirm the intended RED failure.
- [x] Implement immutable provider-neutral transport models and `BackendTransport`.
- [x] Run focused tests and confirm GREEN.
- [x] Verify no secrets, URLs, tokens, learner state, or entitlement fields exist in the transport models.

### Task 2: Fail-Closed Transport and Gateway Adapter

**Files:**
- Modify: `lib/services/authentication.dart`
- Create: `lib/services/backend_transport.dart`
- Modify: `tests/test_v281_backend_transport_contract.py`
- Modify: `test/auth/backend_authentication_contract_test.dart`

**Interfaces:**
- `BackendTransport` is the lower-level provider-neutral transport abstraction.
- The authentication gateway may depend on it, but the transport must not depend on learner or subscription state.

- [x] Add failing tests for unavailable transport behavior and gateway error mapping.
- [x] Run tests and confirm RED.
- [x] Implement the minimal unavailable transport and adapter behavior.
- [x] Run focused tests and confirm GREEN.
- [x] Confirm logout and current-session behavior remain fail-closed.

### Task 3: Wiring and Regression Protection

**Files:**
- Modify: `lib/main.dart`
- Modify: `lib/services/auth_session_controller.dart` only if required by the contract
- Modify: `tests/test_v281_backend_transport_contract.py`

- [x] Add failing wiring/ownership assertions.
- [x] Run tests and confirm RED.
- [x] Wire the unavailable transport explicitly without adding a network client.
- [x] Run focused tests and confirm GREEN.
- [x] Run the full Python regression suite.
- [x] Run security, privacy, and architecture audits.

### Task 4: Documentation and Release Evidence

**Files:**
- Create: `docs/V281_BACKEND_TRANSPORT_CONTRACT.md`
- Modify: `docs/superpowers/plans/2026-09-11-backend-transport-contract.md`

- [x] Record exact scope, non-goals, ownership, and verification limitations.
- [x] Re-run the full verification commands after documentation changes.
- [x] Produce a V281 tested archive excluding caches/build artifacts.
- [x] Calculate SHA-256 and record it in the release notes.

## Verification Commands

```text
pytest -q
```

Also run the project's existing security, privacy, and architecture audit scripts where available. Flutter/Dart/APK checks must be reported as NOT RUN if the toolchain remains unavailable.
