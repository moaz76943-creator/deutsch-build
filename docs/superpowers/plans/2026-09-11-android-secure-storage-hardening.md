# Android Secure Storage Hardening Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the existing Android secure-session implementation explicitly enforce randomized authenticated encryption while preserving all existing boundaries.

**Architecture:** Retain the Android Keystore AES-GCM implementation and Flutter MethodChannel boundary. This is a narrowly scoped hardening change with no new storage provider or backend behavior.

**Tech Stack:** Kotlin Android Keystore, Flutter/Dart MethodChannel, Python pytest audits.

**Spec:** `docs/superpowers/specs/2026-09-11-android-secure-storage-hardening-design.md`

## Global Constraints
- Never store authentication credentials in SharedPreferences.
- Store ciphertext only in the app-private files directory.
- Keep AccountSession credential-free.
- Do not add production credential values.
- Do not add new dependencies.
- Preserve fail-closed behavior.

### Task 1: Explicit encryption hardening
**Files:** Modify `android/app/src/main/kotlin/com/deutschbilarabi/app/AndroidSecureSessionStorage.kt`; Test `tests/test_v288_android_secure_storage_hardening.py`.
- [x] Write failing structural tests.
- [x] Verify RED.
- [x] Add explicit randomized-encryption requirement.
- [x] Verify focused GREEN.

### Task 2: Full verification
- [x] Run full Python regression.
- [x] Run security, privacy, architecture, accessibility, and quality audits.
- [x] Scan credential boundaries.

### Task 3: Documentation and archive
- [x] Record scope and evidence.
- [x] Create clean archive.
- [x] Compute SHA-256.
