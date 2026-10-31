# Session Lifecycle Hardening Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the application authentication session lifecycle deterministic, fail-closed, and safe across initialization, expiry, logout, and app restart without introducing credential persistence or backend dependencies.

**Architecture:** Keep `AuthSessionController` as the application-facing owner of transient authentication state and keep learner data completely separate. Harden the existing provider-neutral authentication boundary so expired/invalid sessions are rejected and lifecycle transitions are observable through tests without storing credentials.

**Tech Stack:** Flutter/Dart application code, Python regression tests, existing authentication abstractions.

**Spec:** V279 Session Integration design approved in conversation; this plan operationalizes only the approved Session Lifecycle Hardening step.

## Global Constraints

- Do not add real authentication providers or backend integration.
- Do not persist passwords, OTP values, access tokens, refresh tokens, payment data, or authoritative subscription state.
- Do not couple authentication to `LearnerRepository` or learner state.
- Do not change dependencies.
- Preserve existing behavior outside the authentication/session boundary.
- Use TDD: failing test first, then minimal implementation, then regression verification.
- Do not claim Flutter/Dart/APK verification when those toolchains are unavailable.

---

### Task 1: Define lifecycle expectations in tests

**Files:**
- Modify: `tests/test_v279_session_lifecycle_hardening.py`
- Test: same file

**Interfaces:**
- Consumes: `AuthSessionController`, `ProviderAuthenticationService`, `AccountSession`.
- Produces: executable contract tests for initialization, expiry, logout, and failed session restoration.

- [x] **Step 1: Write failing tests for expired initialization and failed restoration.**
- [x] **Step 2: Run the focused Python tests and verify the new assertions fail for the intended reason.**
- [x] **Step 3: Add lifecycle tests for logout clearing only auth state and restart-like reinitialization returning unauthenticated when no session exists.**

### Task 2: Harden the session lifecycle minimally

**Files:**
- Modify: `lib/services/auth_session_controller.dart`
- Modify: `lib/services/authentication.dart`
- Test: `tests/test_v279_session_lifecycle_hardening.py`

**Interfaces:**
- Consumes: existing `AuthenticationService` and `AccountSession`.
- Produces: deterministic fail-closed session transitions with no credential persistence.

- [x] **Step 1: Implement only the behavior required by the failing tests.**
- [x] **Step 2: Ensure initialization clears stale failure state only after a valid authenticated session is accepted.**
- [x] **Step 3: Ensure invalid/expired restoration becomes unauthenticated without leaking stale authenticated state.**
- [x] **Step 4: Ensure logout always leaves the controller unauthenticated even if provider logout reports an authentication failure.**
- [x] **Step 5: Re-run focused tests and then the full Python regression suite.**

### Task 3: Security and architecture regression

**Files:**
- Modify: `tests/test_v279_session_lifecycle_hardening.py` only if additional regression assertions are required.

**Interfaces:**
- Consumes: complete V279 source tree.
- Produces: verified Python-level lifecycle/security regression evidence.

- [x] **Step 1: Check authentication files for forbidden credential persistence and learner-state coupling.**
- [x] **Step 2: Run all Python tests with `pytest -q`.**
- [x] **Step 3: Record exact pass/fail counts and toolchain limitations.**
- [x] **Step 4: Package the resulting V279 lifecycle-hardening snapshot without unrelated cache/artifact files.**
