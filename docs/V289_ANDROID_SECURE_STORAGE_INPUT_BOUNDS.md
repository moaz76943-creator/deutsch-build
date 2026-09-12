# V289 — Android Secure Storage Input Bounds

## Status

VERIFIED

## Scope

V289 is a narrowly scoped security hardening pass over the Android secure-session storage implementation introduced in V287 and hardened in V288.

The implementation now rejects oversized opaque session credentials before encryption. The bound is 16 KiB after UTF-8 encoding. This limits accidental or abusive memory/disk amplification while preserving the existing Keystore/AES-GCM boundary.

## Security invariants

- Credentials remain opaque to the Dart authentication model.
- Credentials are never stored in SharedPreferences.
- Android Keystore remains the key boundary.
- AES-GCM authenticated encryption remains the ciphertext boundary.
- No credential values are present in source, tests, logs, or documentation.
- No production backend, provider SDK, token format, or refresh-token format is introduced.
- Learner state and entitlement authority remain outside authentication storage.

## Verification

- Focused V289 tests: 2 passed.
- Full Python regression: 360 passed.
- Security audit: PASS.
- Privacy audit: PASS.
- Architecture audit: PASS.
- Accessibility audit: PASS.
- Content quality audit: PASS (14,813 entries; 14,813 unique IDs; 14,813 unique German entries).
- Flutter/Dart/APK: NOT RUN because the required toolchain is unavailable in the current environment.
- Git metadata: unavailable; no commit or branch claim is made.

## Change boundary

Only the Android secure-storage implementation and its structural regression test were changed for V289. No content data was modified.
