# Android Secure Storage Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement the Android side of the existing secure session storage boundary using Keystore-protected authenticated encryption.

**Architecture:** Keep `SecureSessionStorage` as the only application-facing credential persistence abstraction. A Flutter `MethodChannel` bridges opaque values to a Kotlin implementation that uses Android Keystore for the AES key and an app-private encrypted file for ciphertext.

**Tech Stack:** Flutter/Dart MethodChannel, Kotlin/Android Keystore, AES-GCM, app-private filesystem, Python structural regression tests.

**Spec:** `docs/superpowers/specs/2026-09-11-android-secure-storage-implementation-design.md`

## Global Constraints

- Use Android Keystore for the encryption key.
- Use authenticated encryption (AES-GCM).
- Store only ciphertext plus its nonce in an app-private file.
- Never use SharedPreferences for authentication credentials.
- Exclude the credential file and temporary replacement file from Android backup/device transfer.
- Never log, serialize, or expose cryptographic key material.
- Do not put credentials in learner state, content, tests, screenshots, or release archives.
- Missing storage returns unauthenticated; corrupted/unreadable storage fails closed.
- Replacement uses an atomic filesystem move; if atomic replacement is unavailable, report failure rather than silently downgrade the guarantee.
- Clear is idempotent.
- No device fingerprinting, provider profile duplication, or entitlement data.
- No remote backend implementation, token format, refresh policy, provider SDK, billing, synchronization, or account-linking behavior.

---

### Task 1: Android implementation boundary

**Files:**
- Create: `android/app/src/main/kotlin/com/deutschbilarabi/app/AndroidSecureSessionStorage.kt`
- Create: `lib/services/android_secure_session_storage.dart`
- Modify: `android/app/src/main/kotlin/com/deutschbilarabi/app/MainActivity.kt`

- [x] Write failing structural tests.
- [x] Verify RED.
- [x] Implement Keystore/AES-GCM storage and MethodChannel adapter.
- [x] Verify GREEN.

### Task 2: Backup boundary and authentication wiring

**Files:**
- Modify: `android/app/src/main/res/xml/backup_rules.xml`
- Modify: `android/app/src/main/res/xml/data_extraction_rules.xml`
- Modify: `lib/main.dart`
- Modify: `lib/services/authentication.dart`

- [x] Add credential-file backup exclusions.
- [x] Inject one secure-storage instance into authentication and backend gateway.
- [x] Remove stale in-memory-only documentation.
- [x] Verify structural integration tests.

### Task 3: Verification

- [x] Run focused V287 tests.
- [x] Run full Python regression.
- [x] Run security, privacy, architecture, accessibility, and quality audits.
- [x] Scan source/tests/docs for credential leaks and SharedPreferences authentication persistence.
- [x] Confirm Flutter/Dart/APK status honestly.

### Task 4: Documentation and archive

- [x] Record implementation and threat-boundary details in `docs/V287_ANDROID_SECURE_STORAGE_IMPLEMENTATION.md`.
- [x] Re-run final verification.
- [x] Create a clean archive excluding build/cache/release archives.
- [x] Record SHA-256.
