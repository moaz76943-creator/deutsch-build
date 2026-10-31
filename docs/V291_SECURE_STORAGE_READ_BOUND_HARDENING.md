# V291 — Secure Storage Read-Side Resource Hardening

## Status

VERIFIED

## Scope

V291 hardens the Android secure-session storage read path against unbounded local ciphertext loading. It does not change the credential format, cryptographic primitive, backend contract, learner state, entitlement authority, or dependency set.

## Root cause

The Android storage implementation checked credential size on writes, but `read()` loaded the entire credential file with `readBytes()` before validating its size. A locally corrupted or unexpectedly large file could therefore cause unnecessary memory pressure.

## Changes

- Added a maximum stored payload bound derived from the maximum credential size, nonce size, and GCM authentication-tag size.
- Checked `File.length()` before calling `readBytes()`.
- Rejected an oversized stored payload as corrupted and failed closed.
- Added regression tests proving the size check occurs before the byte-array load.
- Hardened the Dart opaque credential model against empty and oversized values.

## Security and privacy boundaries preserved

- Android Keystore remains the key boundary.
- AES-GCM remains the encryption primitive.
- Credentials are not stored in SharedPreferences.
- No credential values, secrets, tokens, or provider assertions were added to source, tests, docs, or artifacts.
- `AccountSession`, learner state, and subscription authority remain separate.
- No production backend or provider SDK was introduced.

## Verification

- Focused V291 tests: PASS (2/2)
- Full Python project suite (`tests/`): PASS (367/367)
- Security audit: PASS
- Privacy audit: PASS
- Architecture audit: PASS
- Accessibility audit: PASS — 0 warnings
- Quality audit: PASS — 14,813 entries, 14,813 unique IDs, 14,813 unique German entries
- ZIP integrity: PASS

Flutter/Dart/APK execution remains NOT RUN because the required toolchain is unavailable in the current environment.
