# Keystore Key-Loss Hardening Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ensure Android secure-session reads never create a replacement Keystore key when the original key is unavailable.

**Architecture:** Keep key creation exclusively on encryption/save. The decryption path resolves only the existing key and fails closed when it is missing or unusable.

**Tech Stack:** Kotlin Android Keystore, Python structural tests, existing project audits.

**Spec:** `docs/V294_KEYSTORE_KEY_LOSS_HARDENING.md`

## Global Constraints

- Never use SharedPreferences for authentication credentials.
- Keep credentials opaque and out of AccountSession and learner state.
- Do not add production credentials or secrets.
- Do not add dependencies.
- Preserve fail-closed behavior.

### Task 1: Regression and implementation

**Files:**
- Modify: `android/app/src/main/kotlin/com/deutschbilarabi/app/AndroidSecureSessionStorage.kt`
- Test: `tests/test_v294_keystore_key_loss.py`

- [x] Write failing tests for existing-key-only decryption.
- [x] Run focused tests and verify RED.
- [x] Implement `getExistingKey()` and use it from decryption.
- [x] Run focused tests and verify GREEN.

### Task 2: Verification

- [x] Run full Python tests.
- [x] Run security, privacy, architecture, accessibility, and quality audits.
- [x] Confirm no authentication use of SharedPreferences.
- [x] Confirm no sensitive values in source/tests/docs.

### Task 3: Documentation and archive

- [x] Record scope and evidence.
- [x] Create clean archive excluding build/cache and prior archives.
- [x] Verify ZIP integrity and SHA-256.
