# V310 — Session Invalidation Credential Cleanup

## Change
When the backend rejects the current session with `invalidSession`, the authentication gateway now clears the locally stored secure session credential before rethrowing the failure.

## Reason
A rejected backend session must not leave a stale credential in local secure storage. Keeping it would cause repeated invalid restoration attempts and retain no-longer-valid authentication material longer than necessary.

## Scope
- Authentication backend gateway only.
- No learner state coupling.
- No subscription behavior changes.
- No credential format changes.
- No provider behavior changes.

## TDD evidence
1. Added `tests/test_v310_invalid_session_clears_credential.py`.
2. Confirmed RED against the pre-change gateway.
3. Implemented the minimal `AuthenticationFailure` handling in `getCurrentSession()`.
4. Confirmed GREEN.

## Verification
- Python regression suite: 394 passed.
- Security audit: PASS.
- Privacy audit: PASS.
- Quality audit: PASS (14,813 entries; 14,813 unique IDs; 14,813 unique German entries).
- Accessibility audit: PASS (0 warnings).
- Architecture audit: PASS.
- Weakness gate: PASS.
- Flutter/Android build was not executed because the Flutter/Dart/Gradle toolchain is not installed in the current environment.
