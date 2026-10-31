# Account UI Contract Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a provider-neutral account screen that exposes authentication state and actions without coupling account state to learner data or local premium state.

**Architecture:** The account page depends only on `AuthSessionController` and displays its transient `AccountSession`. Email OTP, Google, and Apple actions remain provider-neutral and fail-closed through the existing adapters; learner storage and subscription authority remain separate.

**Tech Stack:** Flutter/Dart, Material 3, existing AuthSessionController, Python source-contract regression tests.

**Spec:** `docs/superpowers/specs/2026-09-11-account-ui-contract-design.md`

## Global Constraints

- Core learning remains usable without an account.
- Authentication owns no `LearnerRepository` or learner state.
- No password, OTP value, access token, refresh token, or payment secret is persisted or logged.
- Premium entitlement is never granted by local UI state.
- Google/Apple/backend integrations remain fail-closed in this phase.
- Use TDD for behavior changes.
- Do not perform destructive cleanup.

---

### Task 1: Account page contract and wiring

**Files:**
- Create: `docs/superpowers/specs/2026-09-11-account-ui-contract-design.md`
- Create: `tests/test_v311_account_ui_contract.py`
- Create: `lib/ui_v35/account_auth_page.dart`
- Modify: `lib/ui_v35/app.dart`

**Interfaces:**
- Consumes: `AuthSessionController.session`, `AuthSessionController.lastFailure`, `AuthSessionController.isInitialized`, and its existing authentication methods.
- Produces: `AccountPage({required AuthSessionController auth})` and an AppBar entry that opens it.

- [ ] **Step 1: Write the failing source-contract tests**

```python
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ACCOUNT = ROOT / "lib/ui_v35/account_pages.dart"
APP = ROOT / "lib/ui_v35/app.dart"


def test_account_page_depends_on_auth_controller_and_exposes_provider_actions():
    text = ACCOUNT.read_text(encoding="utf-8")
    assert "class AccountPage" in text
    assert "AuthSessionController" in text
    assert "requestEmailOtp" in text
    assert "signInWithEmailOtp" in text
    assert "signInWithGoogle" in text
    assert "signInWithApple" in text
    assert "signOut" in text


def test_account_ui_has_no_learner_or_subscription_ownership():
    text = ACCOUNT.read_text(encoding="utf-8")
    assert "LearnerRepository" not in text
    assert "SubscriptionService" not in text
    assert "isPremium" not in text
    assert "premium = true" not in text


def test_account_ui_does_not_render_or_persist_secrets():
    text = ACCOUNT.read_text(encoding="utf-8")
    for forbidden in ("password", "accessToken", "refreshToken", "cardNumber", "SharedPreferences", "SecureSessionStorage"):
        assert forbidden not in text


def test_home_wires_account_page_without_replacing_learning_dependencies():
    text = APP.read_text(encoding="utf-8")
    assert "AccountPage(auth: widget.auth)" in text
    assert "auth: widget.auth" in text
```

- [ ] **Step 2: Run the focused test and verify RED**

Run: `pytest tests/test_v311_account_ui_contract.py -q`
Expected: FAIL because `AccountPage` and its AppBar wiring do not yet exist.

- [ ] **Step 3: Implement the minimal account page**

Create a stateful `AccountPage` in `account_auth_page.dart` with:
- an `AuthSessionController auth` dependency only;
- initialization/loading state based on `auth.isInitialized`;
- authenticated state showing only `userId` and provider, plus a sign-out action;
- unauthenticated state with an email field, OTP field, request-OTP action, verify action, Google action, and Apple action;
- a short non-sensitive failure message derived from `lastFailure`, never raw exception text or credentials;
- no repository, subscription, persistence, or network dependency.

Add an AppBar account icon in `HomeV35` that navigates to `AccountPage(auth: widget.auth)`.

- [ ] **Step 4: Run the focused test and verify GREEN**

Run: `pytest tests/test_v311_account_ui_contract.py -q`
Expected: PASS.

- [ ] **Step 5: Run the full Python regression suite**

Run: `pytest -q tests`
Expected: all tests pass.

- [ ] **Step 6: Run repository audits**

Run:
```bash
python3 tool/security_audit.py
python3 tool/privacy_audit.py
python3 tool/quality_audit.py
python3 tool/accessibility_audit.py
python3 tool/architecture_audit.py
python3 tool/weakness_gate.py
```
Expected: all audits PASS; no mutation by the weakness gate.

- [ ] **Step 7: Record the phase status**

Add `docs/V311_ACCOUNT_UI_CONTRACT.md` documenting scope, boundaries, tests, and the explicit fact that real provider/backend integration is not enabled in this phase.
