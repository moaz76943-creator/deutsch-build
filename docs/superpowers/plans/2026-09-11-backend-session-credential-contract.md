# Backend Session Credential Contract Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [x]`) syntax for tracking.

**Goal:** Define an opaque backend session credential contract and enforce its lifecycle without selecting production token or storage technology.

**Architecture:** Authentication remains provider-neutral. A credential is an opaque value exchanged only between authentication/session boundaries and `SecureSessionStorage`; `AccountSession` never carries it. The backend remains authoritative for session validity and authorization.

**Tech Stack:** Flutter/Dart contracts, Python structural tests, existing project audits.

**Spec:** `docs/superpowers/specs/2026-09-11-backend-session-credential-contract-design.md`

## Global Constraints

- Credential values are opaque and never parsed by learner/application code.
- No password, OTP value, provider assertion, payment data, or entitlement is stored as session credential metadata.
- No credential is placed in `AccountSession`, learner state, content, logs, screenshots, or user-facing diagnostics.
- No SharedPreferences storage for authentication credentials.
- No client-side Premium decision based on credential contents.
- Missing, malformed, expired, revoked, or rejected credentials fail closed.
- Logout clears local credentials even when remote sign-out fails.
- No unnecessary device fingerprinting or account metadata.
- No JWT decision, token format, refresh-token policy, TTL, endpoint URL, HTTP implementation, secure-storage package, provider SDK, billing, sync, account linking, or production backend is selected here.

### Task 1: Credential lifecycle contract

**Files:**
- Modify: `lib/models/secure_session_credentials.dart`
- Create: `test/auth/backend_session_credential_contract_test.dart`
- Create: `tests/test_v284_backend_session_credential_contract.py`

- [x] Write failing structural/behavioral tests for opaque credentials and replacement semantics.
- [x] Run focused tests and verify RED.
- [x] Implement only the minimum contract required by the tests.
- [x] Run focused tests and verify GREEN.

### Task 2: Authentication boundary wiring

**Files:**
- Modify: `lib/services/authentication.dart`
- Modify: `lib/services/backend_authentication_api.dart`
- Modify: `lib/models/backend_authentication_api.dart`
- Add/update: `test/auth/backend_authentication_api_test.dart`
- Add/update: `tests/test_v284_backend_session_credential_contract.py`

- [x] Write failing tests proving credentials are handled outside `AccountSession`.
- [x] Verify RED.
- [x] Add the minimal provider-neutral request/response contract for opaque session credentials.
- [x] Ensure invalid or missing credentials produce unauthenticated state.
- [x] Verify GREEN.

### Task 3: Security regression verification

- [x] Run `pytest -q`.
- [x] Run available security, privacy, architecture, accessibility, and content audits.
- [x] Scan for credential persistence in SharedPreferences and sensitive credential fields in application models.
- [x] Confirm Flutter/Dart/APK status honestly.

### Task 4: Documentation and archive

- [x] Create `docs/V284_BACKEND_SESSION_CREDENTIAL_CONTRACT.md`.
- [x] Record exact test/audit evidence.
- [x] Re-run final verification.
- [x] Create clean archive excluding caches/build artifacts and record SHA-256.
