# Deutsch بالعربي — V277 Account Contract Stage

## Phase
P0 Security / account boundary — contract stage.

## Scope
Implemented only the provider-neutral account/session boundary described by V276.

Added:
- `AccountIdentity` with canonical `userId` and optional `email`.
- `AccountProvider` values for Email OTP, Google, and Apple.
- Immutable `AccountSession` with authenticated/unauthenticated state and optional expiry metadata.
- `AuthenticationService` interface exposing `currentSession`, Email OTP, Google, Apple, and sign-out operations.
- Focused Python source-contract regression tests.
- Focused Dart unit tests for the contract.

## Explicit non-scope
- No real Email OTP provider.
- No Google SDK integration.
- No Apple SDK integration.
- No session credential persistence.
- No backend implementation.
- No cloud sync.
- No account deletion workflow.
- No billing/store verification.
- No provider-specific UI.
- No learner-state migration or rewrite.

## Data minimization
The account/session models contain no password, OTP value, provider token, payment data, or learner-progress fields. Authentication does not import or mutate `LearnerRepository`.

## Entitlement boundary
`SubscriptionService` remains fail-closed. No local premium grant or client-authoritative entitlement was added.

## Verification
- `pytest tests/test_v277_account_contract.py -v`: PASS — 4 passed.
- `flutter test test/account_contract_test.dart`: NOT RUN — Flutter executable is unavailable in the current environment (`command not found`).
- Existing learner/security regression suite remains subject to the project's previously documented environment/tooling blockers.
