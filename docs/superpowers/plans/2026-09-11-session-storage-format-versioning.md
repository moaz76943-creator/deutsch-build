# Session Storage Format Versioning Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add explicit versioning to the Android session-credential file format with fail-closed handling for unknown formats.

**Architecture:** Keep the existing Android Keystore/AES-GCM boundary and add a one-byte format version ahead of nonce+ciphertext. Reads reject unknown versions before decryption; no migration or legacy fallback is introduced.

**Tech Stack:** Kotlin Android platform boundary, Flutter MethodChannel boundary, Python pytest structural regression suite.

**Spec:** `docs/superpowers/specs/2026-09-11-session-storage-format-versioning-design.md`

## Global Constraints

- No plaintext credential persistence.
- No secrets or production credential values in source, tests, docs, or artifacts.
- Unknown or malformed formats fail closed.
- No automatic fallback to older cryptographic formats.
- No changes to learner state or entitlement authority.

### Task 1: Versioned format

**Files:**
- Modify: `android/app/src/main/kotlin/com/deutschbilarabi/app/AndroidSecureSessionStorage.kt`
- Test: `tests/test_v293_secure_storage_key_versioning.py`

- [x] Write failing tests.
- [x] Verify RED.
- [x] Implement minimal version header and pre-decryption validation.
- [x] Verify GREEN.

### Task 2: Verification and documentation

- [x] Run `pytest -q tests`.
- [x] Run security, quality, accessibility, and privacy audits.
- [x] Scan credential boundary.
- [x] Record Flutter/Dart/APK availability honestly.
- [x] Create clean archive and SHA-256.
