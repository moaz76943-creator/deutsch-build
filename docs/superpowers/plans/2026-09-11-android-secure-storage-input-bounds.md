# Android Secure Storage Input Bounds Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Bound opaque Android session credentials before encryption to reduce memory/disk abuse without changing the cryptographic boundary.

**Architecture:** Keep `SecureSessionStorage` and Android Keystore as the existing boundaries. Reject credentials whose UTF-8 representation exceeds 16 KiB before encryption; do not introduce a new provider, persistence mechanism, or token format.

**Tech Stack:** Kotlin/Android Keystore, Flutter MethodChannel boundary, Python pytest structural regression tests.

**Spec:** `docs/V289_ANDROID_SECURE_STORAGE_INPUT_BOUNDS.md`

## Global Constraints

- Never use SharedPreferences for authentication credentials.
- Keep AccountSession credential-free.
- Keep learner state and subscription authority outside authentication storage.
- No production backend, endpoint, token format, or secure-storage provider is introduced.
- No credential values in source, tests, logs, documentation, or release artifacts.
- Preserve fail-closed behavior.

### Task 1: Add input bound

**Files:**
- Modify: `android/app/src/main/kotlin/com/deutschbilarabi/app/AndroidSecureSessionStorage.kt`
- Test: `tests/test_v289_secure_storage_input_bounds.py`

- [x] Write failing tests.
- [x] Run focused tests and verify RED.
- [x] Implement the 16 KiB UTF-8 input bound before encryption.
- [x] Run focused tests and verify GREEN.

### Task 2: Verify and document

- [x] Run `pytest -q`.
- [x] Run security, privacy, architecture, accessibility, and quality audits.
- [x] Scan the changed boundary for credential leakage and SharedPreferences usage.
- [x] Record Flutter/Dart/APK status honestly.
- [x] Create a clean archive and SHA-256.
