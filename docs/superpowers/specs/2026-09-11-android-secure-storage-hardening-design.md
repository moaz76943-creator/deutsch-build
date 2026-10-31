# V288 — Android Secure Storage Hardening Design

## Status
VERIFIED

## Goal
Harden the Android Keystore storage boundary without introducing new credentials, providers, or storage dependencies.

## Scope
- Keep credentials in the app-private files directory only.
- Keep encryption authenticated with AES-GCM.
- Explicitly require randomized encryption for Keystore-generated keys.
- Preserve the existing Flutter MethodChannel boundary.
- Preserve backup/device-transfer exclusions.
- Do not require user authentication for every storage operation; that would change the session UX and is outside this hardening phase.
- Do not add logs, external storage, SharedPreferences, or credential literals.

## Non-goals
No backend changes, token format, refresh policy, provider SDK, billing, entitlement logic, or new dependency.
