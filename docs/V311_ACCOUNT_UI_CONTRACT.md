# V311 — Account UI Contract

## Status

**VERIFIED (source/test level)**

## Scope

V311 adds a provider-neutral account screen and wires it into the home AppBar. The screen is presentation-only and depends on `AuthSessionController`.

## Boundaries

- Account UI does not access `LearnerRepository`.
- Account UI does not access `SubscriptionService` or determine Premium entitlement.
- Account UI does not access persistence, secure credential storage, or network transport.
- Authentication state remains transient through `AuthSessionController`.
- Authenticated UI displays only the non-secret internal user ID and generic session state.
- Authentication failures are mapped to short non-sensitive Arabic messages; raw exceptions are not rendered.
- Email/OTP input is transient UI state and is cleared after successful authentication.
- Google, Apple, and backend adapters remain fail-closed/unavailable in this phase.
- Learning remains usable without an account.

## Files

- `lib/ui_v35/account_auth_page.dart`
- `lib/ui_v35/app.dart`
- `tests/test_v311_account_ui_contract.py`
- `docs/superpowers/specs/2026-09-11-account-ui-contract-design.md`
- `docs/superpowers/plans/2026-09-11-account-ui-contract.md`

## Verification

- Focused V311 contract tests: PASS (4/4).
- Full Python regression suite: PASS (398 tests).
- Security audit: PASS.
- Privacy audit: PASS; direct `SharedPreferences` imports outside adapter: 0; sensitive persistence vocabulary: 0.
- Quality audit: PASS; 14,813 entries, 14,813 unique IDs, 14,813 unique German entries.
- Accessibility audit: PASS; 0 warnings.
- Architecture audit: PASS; no oversized UI files.
- Weakness gate: PASS; review-only, mutation NONE; 1,180 content review candidates.

## Environment limitation

Flutter/Dart/Gradle are not installed in the current execution environment. Therefore V311 does not claim a Flutter compilation or Android APK build. Those checks remain part of the project's build contract when the reference toolchain is available.
