# V293 — Session Storage Format Versioning Design

## Status

VERIFIED

## Goal

Make the Android session-credential file format explicitly versioned so future storage/key migrations reject unknown formats safely instead of attempting ambiguous decryption.

## Scope

- Add a one-byte storage format version before the nonce and ciphertext.
- Accept only the current known version.
- Reject unknown versions before decryption with a generic corruption result.
- Include the version byte in the stored-size bound.
- Preserve AES-GCM, Android Keystore, app-private storage, backup exclusion, and opaque credential boundaries.

## Security constraints

- No plaintext credential persistence.
- No secrets or production credential values in source, tests, docs, or artifacts.
- Unknown or malformed formats fail closed.
- No automatic fallback to older cryptographic formats.
- No changes to learner state or entitlement authority.
