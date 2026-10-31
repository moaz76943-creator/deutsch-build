# V287 — Android Secure Storage Implementation Design

## Status

APPROVED FOR IMPLEMENTATION — continuation authorization from the user covers the staged implementation. This phase introduces the first platform-backed credential storage implementation while preserving the existing application boundary.

## Goal

Persist only opaque authenticated-session credentials on Android using an Android Keystore-protected AES key and an app-private encrypted file, without placing authentication credentials in SharedPreferences.

## Architecture

`AndroidSecureSessionStorage` implements the existing `SecureSessionStorage` contract. Dart communicates with it through a narrow `MethodChannel`; Android owns the Keystore key, encryption, ciphertext file, and file lifecycle. `AuthenticationService` and `AuthSessionController` remain unaware of platform cryptography.

## Security requirements

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

## Non-goals

No remote backend implementation, token format, refresh policy, provider SDK, billing, synchronization, or account-linking behavior is added.
