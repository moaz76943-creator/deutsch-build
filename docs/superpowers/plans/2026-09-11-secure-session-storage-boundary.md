# Secure Session Storage Boundary Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a credential-safe session-storage abstraction without selecting a concrete secure-storage backend.

**Architecture:** A small `SecureSessionStorage` interface sits beside authentication, storing only an opaque credential bundle in a future implementation. The current runtime uses an unavailable/in-memory-safe implementation, so no credentials are persisted and no dependency is added.

**Tech Stack:** Flutter/Dart contracts, Python structural tests, existing audits.

**Spec:** `docs/superpowers/specs/2026-09-11-secure-session-storage-boundary-design.md`

## Global Constraints

- Never use SharedPreferences for authentication credentials.
- Keep AccountSession credential-free.
- Keep learner state and subscription authority outside authentication storage.
- No production backend, endpoint, token format, or secure-storage package.
- No unnecessary dependencies.
- Preserve fail-closed behavior.

### Task 1: Storage contract

**Files:** Create `lib/models/secure_session_credentials.dart`; create `lib/services/secure_session_storage.dart`; tests `test/auth/secure_session_storage_test.dart`, `tests/test_v283_secure_session_storage.py`.

- [ ] Write failing tests for the storage interface and credential model.
- [ ] Run focused tests and verify RED.
- [ ] Implement minimal immutable credential container and storage interface.
- [ ] Add safe unavailable implementation.
- [ ] Run focused tests and verify GREEN.

### Task 2: Authentication lifecycle integration

**Files:** Modify `lib/services/authentication.dart`; modify `lib/services/auth_session_controller.dart`; update focused tests.

- [ ] Write failing tests for restoration and logout clearing semantics.
- [ ] Verify RED.
- [ ] Integrate storage without exposing credentials through AccountSession.
- [ ] Ensure failures fail closed and logout clears storage in finally.
- [ ] Verify GREEN.

### Task 3: Security and regression verification

- [ ] Run `pytest -q`.
- [ ] Run security, privacy, architecture, accessibility, and content audits available in the project.
- [ ] Scan for credential persistence in SharedPreferences and sensitive values in source/tests/docs.
- [ ] Confirm Flutter/Dart/APK status honestly.

### Task 4: Documentation and archive

- [ ] Create `docs/V283_SECURE_SESSION_STORAGE_BOUNDARY.md` with exact scope and verification evidence.
- [ ] Re-run final verification.
- [ ] Create a clean archive excluding caches/build artifacts and record SHA-256.
