# Session Renewal & Revocation Contract Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add provider-neutral renewal and revocation semantics for authenticated sessions without selecting production token or transport technology.

**Architecture:** Extend the existing backend authentication boundary with explicit renewal and revocation operations. Credentials remain opaque and isolated in `SecureSessionStorage`; `AccountSession` remains credential-free and server authority remains final.

**Tech Stack:** Flutter/Dart contracts, Python structural tests, existing project audits.

**Spec:** `docs/superpowers/specs/2026-09-11-session-renewal-revocation-contract-design.md`

## Global Constraints

- Never use SharedPreferences for authentication credentials.
- Keep AccountSession credential-free.
- Keep learner state and subscription authority outside authentication storage.
- No production backend, endpoint, token format, or secure-storage package.
- Preserve fail-closed behavior.

### Task 1: Contract tests

**Files:** Create `tests/test_v285_session_renewal_revocation_contract.py`; modify `test/auth/backend_authentication_api_test.dart` only if Dart coverage requires it.

- [x] Write failing structural tests for renewal/revocation operations and response credential handling.
- [x] Run focused tests and verify RED.

### Task 2: Transport/API contract

**Files:** Modify `lib/models/backend_transport.dart`; modify `lib/models/backend_authentication_api.dart`; modify `lib/services/backend_authentication_api.dart`.

- [x] Add renewal and revocation operations with opaque credential input/output.
- [x] Preserve nullable-safe validation.
- [x] Run focused tests and verify GREEN.

### Task 3: Authentication lifecycle

**Files:** Modify `lib/services/authentication.dart`; modify `lib/services/auth_session_controller.dart` only if its public lifecycle needs exposure.

- [x] Add renewal operation to the authentication boundary.
- [x] Replace stored credential only after a valid authenticated response.
- [x] Clear local credential on rejected/invalid renewal.
- [x] Keep logout clearing semantics intact.
- [x] Run focused tests.

### Task 4: Verification and documentation

- [x] Run `pytest -q`.
- [x] Run available security, privacy, architecture, accessibility, and content audits.
- [x] Scan for forbidden credential persistence and sensitive literals.
- [x] Create `docs/V285_SESSION_RENEWAL_REVOCATION_CONTRACT.md`.
- [x] Re-run final verification.
- [x] Create clean archive and record SHA-256.


## Execution Evidence

- RED: focused V285 suite initially failed 4 contract assertions before implementation.
- GREEN: focused V285 suite passed 10 tests after implementation and lifecycle hardening.
- Final regression: 343 tests passed.
