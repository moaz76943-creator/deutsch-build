# Authentication Gateway Contract Hardening Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Restore the authentication gateway's declared lifecycle contract and harden fail-closed credential cleanup paths.

**Architecture:** Keep provider-neutral authentication and secure credential storage boundaries unchanged. Only align the interface with its existing lifecycle implementation and ensure local credentials are cleared when restoration or sign-out cannot complete safely.

**Tech Stack:** Flutter/Dart contracts, Python structural regression tests, existing project audits.

**Spec:** `docs/V290_AUTH_GATEWAY_CONTRACT_HARDENING.md`

## Global Constraints

- No production credentials or secrets.
- No new authentication provider, endpoint, token format, billing, or learner synchronization.
- Never use SharedPreferences for authentication credentials.
- Preserve fail-closed behavior.
- Do not modify content data unnecessarily.
- Flutter/Dart/APK checks must be reported honestly when unavailable.

### Task 1: Contract and lifecycle regression

**Files:**
- Modify: `lib/services/authentication.dart`
- Modify: `tests/test_v284_backend_session_credential_contract.py`
- Create: `tests/test_v290_auth_gateway_contract_integrity.py`

- [x] Write failing tests for missing lifecycle declarations and cleanup invariants.
- [x] Run focused tests and verify RED.
- [x] Implement the minimal contract/lifecycle corrections.
- [x] Run focused tests and verify GREEN.

### Task 2: Full verification and documentation

- [x] Run full Python regression.
- [x] Run quality, security, privacy, accessibility, and architecture audits.
- [x] Record environment limitations honestly.
- [x] Create the V290 verification document.
- [x] Create a clean release archive and record SHA-256.
