# V294 — Android Keystore Key-Loss Hardening

## Status

VERIFIED

## Change

The Android secure-session reader no longer creates a replacement Keystore key while attempting to decrypt an existing credential file. Decryption now requires the existing key; if the key is unavailable, the operation fails closed.

## Security rationale

Creating a new key during a read path can mask key-loss and creates a misleading recovery path. Existing ciphertext must only be decrypted with its original key. Key creation remains limited to the save/encryption path.

## Scope

- Android Keystore only.
- No credential values, secrets, tokens, or key material are stored in source, tests, docs, or logs.
- No SharedPreferences authentication storage.
- No changes to learner state, content, or entitlement authority.
- No dependency changes.

## TDD evidence

- New focused regression initially failed: 3 failures.
- Minimal implementation changed the decrypt path to use an existing-key lookup only.
- Focused regression: 3/3 passed.
- Full project tests: 373 passed.

## Audits

- Security: PASS
- Privacy: PASS
- Architecture: PASS
- Accessibility: PASS (0 warnings)
- Quality: PASS
- ZIP integrity: PASS

Flutter/Dart/APK execution was not available in this environment and is therefore not claimed as run.
