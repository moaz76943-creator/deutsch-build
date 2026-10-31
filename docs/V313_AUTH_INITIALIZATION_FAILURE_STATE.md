# V313 — Authentication Initialization Failure-State Hardening

## Change

`AuthSessionController.initialize()` now clears `_lastFailure` after a successful `currentSession` lookup regardless of whether the returned session is authenticated.

This prevents a stale error from a previous authentication operation from remaining visible after initialization successfully establishes the current unauthenticated state.

## Safety boundary

- No learner state is read or mutated.
- No subscription entitlement is changed.
- No credentials are exposed to presentation code.
- No persistence format or backend protocol is changed.

## Verification

- Focused V313 regression: PASS
- Full Python suite: 401 passed
- Security audit: PASS
- Privacy audit: PASS
- Quality audit: PASS
- Accessibility audit: PASS (0 warnings)
- Architecture audit: PASS
- Weakness gate: PASS

Flutter/Android compilation was not executed because the required Flutter/Dart/Gradle toolchain is not installed in the current environment.
