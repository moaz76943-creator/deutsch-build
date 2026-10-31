# V312 — Session Renewal UI Contract

## Goal
Expose the existing provider-neutral session renewal contract through the authentication controller and account UI without coupling authentication to learner state or subscription state.

## Changes
- `AuthSessionController.renewSession()` delegates to `AuthenticationService.renewSession()`.
- Successful renewal replaces the transient account session and clears the previous failure.
- Renewal failures surface through the existing sanitized failure model and leave the controller unauthenticated.
- Account UI exposes a `تجديد الجلسة` action for authenticated sessions.
- No learner, subscription, credential, or secure-storage ownership was added to presentation.

## TDD
- Added `tests/test_v312_session_renewal_ui_contract.py`.
- RED observed before implementation: 2 failing tests.
- GREEN observed after minimal implementation: 2 passing tests.

## Verification
- `pytest -q tests`: 400 passed.
- Security audit: PASS.
- Privacy audit: PASS.
- Quality audit: PASS — 14,813 entries, 14,813 unique IDs, 14,813 unique German entries.
- Accessibility audit: PASS — 0 warnings.
- Architecture audit: PASS.
- Weakness gate: PASS — 1,180 review candidates, mutation NONE.
- Flutter/Android compilation was not executed because the required toolchain is unavailable in the current environment.

## Security boundary
The UI does not receive or persist session credentials. Renewal remains mediated by the authentication service and backend gateway, with existing secure-storage and fail-closed behavior preserved.
