# V286 — Production Secure Storage Platform Contract Design

## Status

APPROVED FOR IMPLEMENTATION — continuation authorization from the user covers the project's staged implementation; this phase remains contract-only and introduces no production credentials.

## Goal

Define the platform-security boundary required before any real session credential can be persisted on Android.

## Design

`SecureSessionStorage` remains the application-facing abstraction. A future Android implementation must persist only opaque session credentials using platform-backed secure storage; authentication, learner state, and entitlement authority remain separate.

The contract must support save, read, clear, and replacement semantics without exposing key names, raw storage APIs, provider data, or credential contents to unrelated layers.

## Security requirements

- Never persist authentication credentials in SharedPreferences.
- Never log credential values or include them in tests, fixtures, screenshots, content, or release archives.
- Android secure storage must be backed by platform-protected key material when implemented.
- Application code must not export or serialize the credential container.
- Missing, corrupted, unreadable, or unavailable storage fails closed.
- Clear is idempotent and must not reveal credential contents.
- Replacement is atomic from the caller's perspective: an unsuccessful save must not be reported as successful.
- No device fingerprinting or unnecessary account metadata.

## Non-goals

No secure-storage dependency, Android implementation, Keystore alias, encryption format, token format, refresh-token format, production backend, provider SDK, billing, or synchronization is introduced in V286.
