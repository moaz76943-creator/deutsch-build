# Account Contract Stage Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a provider-neutral account/session contract without implementing real authentication providers, changing learner state, or granting paid access.

**Architecture:** Add small immutable account/session models and a provider-neutral `AuthenticationService` boundary. Keep account/session state completely separate from `LearnerRepository`; retain the existing fail-closed `SubscriptionService` and introduce no provider SDKs, backend secrets, or sync behavior in this stage.

**Tech Stack:** Flutter/Dart, existing project conventions, `flutter_test` when the real Flutter toolchain is available, plus source-level Python contract tests because the current environment has no Flutter/Dart executable.

**Spec:** `docs/V276_ACCOUNT_BOUNDARY_DESIGN.md`

## Global Constraints

- Core learning must continue without authentication.
- Authentication must never directly mutate learner progress.
- `LearnerRepository` remains the sole owner of learner-owned local state.
- Session credentials must not be stored in learner-state JSON.
- Paid entitlement remains server-authoritative and fail-closed.
- No backend secret, service credential, private signing key, or privileged API credential may be embedded in the APK.
- No real Google, Apple, or Email OTP provider integration in this stage.
- No sync, account deletion, billing implementation, provider-specific UI, or backend vendor selection in this stage.
- No dependency upgrade.
- No destructive cleanup or deletion of unrelated files.
- Preserve existing content IDs and local persistence behavior.

---

### Task 1: Add failing contract tests

**Files:**
- Create: `tests/test_v277_account_contract.py`
- Create: `test/account_contract_test.dart`

**Interfaces:**
- The tests define the expected provider-neutral account/session surface before production implementation.

- [x] **Step 1: Write Python source-contract tests.**
- [x] **Step 2: Run the contract tests and confirm the expected RED state before implementation.**
- [x] **Step 3: Write Dart unit tests for immutable account/session value semantics and the provider-neutral service surface.**
- [x] **Step 4: Attempted focused Flutter test; toolchain unavailable and blocker recorded.**

### Task 2: Implement the minimal account/session contract

**Files:**
- Create: `lib/models/account_session.dart`
- Create: `lib/services/authentication.dart`
- Modify: `pubspec.yaml` only if required (expected: no change)

**Interfaces:**
- `AccountIdentity`
- `AccountProvider`
- `AccountSession`
- `AuthenticationService.currentSession`
- `AuthenticationService.signInWithEmailOtp(...)`
- `AuthenticationService.signInWithGoogle(...)`
- `AuthenticationService.signInWithApple(...)`
- `AuthenticationService.signOut()`

- [x] **Step 1: Implemented only the immutable value models required by the tests.**
- [x] **Step 2: Implemented the provider-neutral service contract without provider integration or fabricated sessions.**
- [x] **Step 3: Focused Python contract tests pass.**
- [x] **Step 4: Focused Dart test attempt recorded as blocked by missing Flutter executable.**

### Task 3: Security boundary regressions

**Files:**
- Modify: `tests/test_v277_account_contract.py`
- Create/modify: `test/account_security_boundary_test.dart` only if supported by existing layout

- [x] **Step 1: Asserted account/session code does not directly access or mutate `LearnerRepository`.**
- [x] **Step 2: Asserted session models contain only minimal non-secret account/session fields.**
- [x] **Step 3: Asserted the existing `SubscriptionService` remains fail-closed.**
- [x] **Step 4: Ran focused Python tests fresh.**
- [x] **Step 5: Ran relevant existing security/privacy/local-state regressions fresh.**

### Task 4: Documentation

**Files:**
- Create: `docs/V277_ACCOUNT_CONTRACT_STAGE.md`
- `DEVELOPMENT_PROGRESS.md` is absent from the V276 archive; no fabricated progress file was added.

- [x] **Step 1: Recorded contract-only scope and explicit deferrals in `docs/V277_RELEASE_NOTES.md`.**
- [x] **Step 2: Recorded exact verification results and the Flutter blocker.**
- [x] **Step 3: Verified documentation makes no claim of real provider login, billing, sync, or APK validation.**

### Task 5: Final verification

- [x] **Step 1: Re-read V276 and the implementation plan against the final changes.**
- [x] **Step 2: Ran focused Python contract tests fresh.**
- [x] **Step 3: Ran the full Python regression suite fresh: 282 passed.**
- [x] **Step 4: Checked dependency stability and secret patterns; no changes/hits.**
- [x] **Step 5: Verification evidence collected; next-version archive can be produced.**
