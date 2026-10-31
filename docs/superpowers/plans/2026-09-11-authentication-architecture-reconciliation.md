# Authentication Architecture Reconciliation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reduce authentication coupling by separating contracts, failures, backend gateway, and lifecycle orchestration while preserving the public compatibility surface.

**Architecture:** Keep `authentication.dart` as a compatibility barrel and move each responsibility into one focused file. No learning, subscription, provider SDK, or credential-storage semantics are changed.

**Tech Stack:** Flutter/Dart source, Python pytest structural tests, existing project audits.

**Spec:** `docs/superpowers/specs/2026-09-11-authentication-architecture-reconciliation-design.md`

## Global Constraints

- Preserve existing public authentication imports through the compatibility barrel.
- Keep learner state and subscription authority outside authentication.
- Do not add runtime dependencies.
- Keep credentials out of `AccountSession`.
- Preserve fail-closed behavior.
- Do not claim Flutter/Dart/APK verification when the toolchain is unavailable.

### Task 1: Architecture RED test

**Files:**
- Create: `tests/test_v295_authentication_architecture_split.py`

- [x] Write the failing architecture assertions.
- [x] Run the focused test and observe RED: 3 failures.

### Task 2: Responsibility split

**Files:**
- Create: `lib/services/authentication_failures.dart`
- Create: `lib/services/authentication_contract.dart`
- Create: `lib/services/authentication_backend_gateway.dart`
- Create: `lib/services/authentication_service.dart`
- Modify: `lib/services/authentication.dart`

- [x] Move failure taxonomy.
- [x] Move provider-neutral contracts.
- [x] Move backend gateway implementations.
- [x] Move orchestration/lifecycle implementation.
- [x] Convert `authentication.dart` to a compatibility barrel.

### Task 3: Regression compatibility

**Files:**
- Modify legacy structural tests under `tests/` to inspect the new responsibility owner instead of assuming one monolithic source file.

- [x] Update structural test targets.
- [x] Run full regression.
- [x] Resolve all test failures caused by stale source-location assumptions.

### Task 4: Final verification

- [x] Security audit.
- [x] Privacy audit.
- [x] Architecture audit.
- [x] Accessibility audit.
- [x] Quality audit.
- [x] Python compile checks.
- [x] Confirm Flutter/Dart/APK status honestly.
- [x] Create clean release archive and SHA-256.
