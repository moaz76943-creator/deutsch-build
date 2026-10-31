# Backend Authentication Contract Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement the approved provider-neutral mobile/backend authentication contract without creating a production backend, provider SDK integration, billing logic, or learner-state coupling.

**Architecture:** Keep `AuthenticationService`, `AuthSessionController`, and `AccountSession` provider-neutral. Add a backend gateway contract plus transient provider-credential transport models so provider adapters produce assertions while the backend boundary remains responsible for canonical `userId`, session validity, expiry, and revocation. Until a real backend platform is selected, the shipped adapter remains fail-closed and no network endpoint, token format, refresh TTL, or secure-storage implementation is invented.

**Tech Stack:** Flutter/Dart; existing `http` dependency only if a later transport implementation is explicitly approved; Python `pytest` regression suite; no new dependency in this contract stage.

**Spec:** `docs/superpowers/specs/2026-09-11-backend-authentication-contract-design.md`

## Global Constraints

- The backend owns the canonical internal `userId`.
- Provider identities are external references and must not become the application's canonical identity.
- `AccountIdentity` contains only `userId`.
- No provider access token, refresh token, OTP value, password, payment credential, or provider secret is part of `AccountIdentity` or `AccountSession`.
- LearnerRepository / learner progress remains outside authentication ownership.
- Subscription and entitlement verification remains separate and server-authoritative.
- Provider-specific verification occurs behind one provider-neutral backend authentication boundary.
- Authentication errors exposed to ordinary clients remain stable and non-secret.
- OTP expiry, replay prevention, rate limiting, provider assertion validation, revocation, input validation, TLS-only transport, and server-side authorization are production backend requirements; this stage models their boundary but does not fake their implementation.
- Exact token format, refresh mechanism, secure-storage technology, and TTL are not invented in this stage.
- No secrets may be written to source, tests, logs, documentation, fixtures, or generated artifacts.
- No Flutter/Dart/APK release claim is made unless those toolchains are actually available and verified.
- The current extracted snapshot is not a Git repository; commit commands are therefore replaced by an explicit filesystem checkpoint/archive step and no commit is claimed.

---

## File map

- Create `lib/models/backend_authentication_contract.dart`: immutable transport-neutral request/credential/result models and stable backend failure categories. It must not contain learner or subscription data.
- Modify `lib/services/authentication.dart`: introduce the backend gateway interface and move provider orchestration toward backend-authoritative session establishment while preserving the public provider-neutral `AuthenticationService` surface.
- Modify `lib/services/authentication_providers.dart`: keep fail-closed adapters and, where needed, change them to return transient provider assertions rather than fabricated authenticated sessions.
- Modify `lib/services/auth_session_controller.dart`: preserve transient state semantics and add only the lifecycle operation required by the approved backend contract; never persist credentials or learner data.
- Modify `lib/main.dart`: wire the contract through the existing fail-closed construction path without introducing a real endpoint.
- Create `test/auth/backend_authentication_contract_test.dart`: Dart contract tests for model invariants and gateway/service behavior.
- Create `tests/test_v280_backend_authentication_contract.py`: Python structural/security regression tests for ownership, secret hygiene, dependency stability, and wiring.
- Create `docs/V280_BACKEND_AUTHENTICATION_CONTRACT.md`: implementation notes, explicit non-goals, verification state, and future integration requirements.

---

### Task 1: Backend Contract Models

**Files:**
- Create: `lib/models/backend_authentication_contract.dart`
- Test: `test/auth/backend_authentication_contract_test.dart`

**Interfaces:**
- Produces `BackendAuthenticationFailureCode` with stable categories: `invalidAuthentication`, `rateLimited`, `providerRejected`, `unavailable`, `invalidSession`, `retryable`.
- Produces immutable `ProviderAuthenticationAssertion` with `AccountProvider provider` and transient `String assertion`.
- Produces immutable `BackendAuthenticatedSession` wrapping only `AccountSession session`.
- Produces immutable `EmailOtpRequest` with `String email` and `EmailOtpVerification` with `String email`, `String otp`; these values are transport inputs only and must never be copied into persistent session state.

- [ ] **Step 1: Write the failing tests**

Add tests proving:

```dart
test('provider assertion keeps provider and assertion transiently', () {
  const credential = ProviderAuthenticationAssertion(
    provider: AccountProvider.google,
    assertion: 'ephemeral-assertion',
  );
  expect(credential.provider, AccountProvider.google);
  expect(credential.assertion, 'ephemeral-assertion');
});

test('backend failure codes are stable and provider-neutral', () {
  expect(
    BackendAuthenticationFailureCode.values,
    containsAll(<BackendAuthenticationFailureCode>[
      BackendAuthenticationFailureCode.invalidAuthentication,
      BackendAuthenticationFailureCode.rateLimited,
      BackendAuthenticationFailureCode.providerRejected,
      BackendAuthenticationFailureCode.unavailable,
      BackendAuthenticationFailureCode.invalidSession,
      BackendAuthenticationFailureCode.retryable,
    ]),
  );
});

test('backend authenticated session exposes only AccountSession', () {
  const result = BackendAuthenticatedSession(
    AccountSession.authenticated(
      identity: AccountIdentity(userId: 'internal-user'),
    ),
  );
  expect(result.session.identity?.userId, 'internal-user');
  expect(result.session.isAuthenticated, isTrue);
});
```

- [ ] **Step 2: Run the focused test to verify it fails**

Run: `flutter test test/auth/backend_authentication_contract_test.dart`
Expected: FAIL because the contract types do not yet exist.

- [ ] **Step 3: Write the minimal implementation**

Implement the exact immutable models and enum names above. Do not add email/profile fields, provider tokens, refresh tokens, passwords, payment fields, learner fields, or authorization booleans.

- [ ] **Step 4: Run the focused test to verify it passes**

Run: `flutter test test/auth/backend_authentication_contract_test.dart`
Expected: PASS when Flutter is available. If Flutter is unavailable, record `NOT RUN` rather than substituting a claim.

- [ ] **Step 5: Filesystem checkpoint**

Because the current snapshot has no Git repository, preserve the changed files in the working snapshot; do not run or claim a Git commit.

---

### Task 2: Backend Gateway Boundary

**Files:**
- Modify: `lib/services/authentication.dart`
- Modify: `test/auth/backend_authentication_contract_test.dart`

**Interfaces:**
- Consumes `ProviderAuthenticationAssertion`, `EmailOtpRequest`, and `EmailOtpVerification` from Task 1.
- Produces `BackendAuthenticationGateway` with these exact methods:

```dart
abstract interface class BackendAuthenticationGateway {
  Future<void> requestEmailOtp(EmailOtpRequest request);

  Future<AccountSession> verifyEmailOtp(EmailOtpVerification request);

  Future<AccountSession> authenticateProvider(
    ProviderAuthenticationAssertion assertion,
  );

  Future<AccountSession> getCurrentSession();

  Future<void> signOut();
}
```

- [ ] **Step 1: Write the failing tests**

Add a fake gateway and test that `ProviderAuthenticationService` delegates Email OTP verification and provider assertions to the backend gateway, and accepts an authenticated result only when `AccountSession.isAuthenticated` and `identity != null`.

```dart
test('provider authentication delegates canonical session creation to backend', () async {
  final gateway = FakeBackendAuthenticationGateway(
    session: const AccountSession.authenticated(
      identity: AccountIdentity(userId: 'internal-user'),
    ),
  );
  final service = ProviderAuthenticationService(
    emailOtpProvider: FakeEmailOtpProvider(),
    googleProvider: FakeGoogleProvider(),
    appleProvider: FakeAppleProvider(),
    backendGateway: gateway,
  );

  final session = await service.signInWithGoogle();

  expect(session.identity?.userId, 'internal-user');
  expect(gateway.providerAssertions.single.provider, AccountProvider.google);
});
```

- [ ] **Step 2: Run the focused test to verify it fails**

Run: `flutter test test/auth/backend_authentication_contract_test.dart`
Expected: FAIL because `BackendAuthenticationGateway` is absent and the service constructor has no backend gateway.

- [ ] **Step 3: Write the minimal implementation**

Add the interface. Update `ProviderAuthenticationService` so successful provider adapters supply a transient assertion to `authenticateProvider()` and the backend result becomes the only authenticated session accepted by the service. Keep `_authenticate()` fail-closed. Do not add HTTP calls or endpoint URLs.

- [ ] **Step 4: Run the focused test to verify it passes**

Run: `flutter test test/auth/backend_authentication_contract_test.dart`
Expected: PASS when Flutter is available.

- [ ] **Step 5: Filesystem checkpoint**

Preserve the changed files in the isolated snapshot; no Git commit is available or claimed.

---

### Task 3: Fail-Closed Provider Adapter Refactor

**Files:**
- Modify: `lib/services/authentication_providers.dart`
- Modify: `lib/services/authentication.dart`
- Modify: `test/auth/provider_authentication_test.dart`
- Modify: `test/auth/backend_authentication_contract_test.dart`

**Interfaces:**
- `EmailOtpProvider.requestCode({required String email})` remains the request-side operation.
- Social adapters must expose transient provider assertions through a provider-neutral operation returning `ProviderAuthenticationAssertion`; no adapter returns an authenticated `AccountSession` directly.
- `UnavailableEmailOtpProvider` and `UnavailableSocialAuthenticationProvider` remain fail-closed.

- [ ] **Step 1: Write the failing tests**

Add tests asserting that unavailable providers still throw `AuthenticationFailureCode.unavailable`, no unavailable adapter can fabricate a session, and a social adapter cannot become the canonical identity source.

```dart
test('unavailable social adapter remains fail-closed', () async {
  const provider = UnavailableSocialAuthenticationProvider(
    AccountProvider.apple,
  );
  expect(
    provider.authenticate(),
    throwsA(
      isA<AuthenticationFailure>().having(
        (error) => error.code,
        'code',
        AuthenticationFailureCode.unavailable,
      ),
    ),
  );
});
```

- [ ] **Step 2: Run the focused provider tests to verify the intended failures**

Run: `flutter test test/auth/provider_authentication_test.dart test/auth/backend_authentication_contract_test.dart`
Expected: FAIL only where the new assertion-returning adapter contract is not implemented yet.

- [ ] **Step 3: Write the minimal implementation**

Refactor only the provider-to-backend handoff. Keep all assertion material transient. Preserve provider validation (`google` adapter must report `AccountProvider.google`; Apple likewise). Keep the existing unavailable adapters throwing `AuthenticationFailureCode.unavailable`.

- [ ] **Step 4: Run the focused provider tests to verify they pass**

Run: `flutter test test/auth/provider_authentication_test.dart test/auth/backend_authentication_contract_test.dart`
Expected: PASS when Flutter is available.

- [ ] **Step 5: Filesystem checkpoint**

Preserve the changed files; no Git commit is claimed.

---

### Task 4: Session Lifecycle and Application Wiring

**Files:**
- Modify: `lib/services/auth_session_controller.dart`
- Modify: `lib/main.dart`
- Modify: `tests/test_v280_backend_authentication_contract.py`

**Interfaces:**
- `AuthSessionController` continues to expose only `AccountSession`, initialization state, and non-secret `AuthenticationFailure`.
- `main.dart` continues constructing a fail-closed service; no endpoint, token, or credential is embedded.

- [ ] **Step 1: Write the failing Python structural tests**

Add checks that the main wiring contains `BackendAuthenticationGateway`, still constructs unavailable adapters, and does not contain URL literals, token constants, OTP values, password fields, or payment fields.

```python
def test_v280_main_wiring_remains_fail_closed(project_root):
    text = (project_root / 'lib' / 'main.dart').read_text()
    assert 'UnavailableEmailOtpProvider' in text
    assert 'UnavailableSocialAuthenticationProvider' in text
    assert 'BackendAuthenticationGateway' in text
    assert 'http://' not in text
    assert 'https://' not in text
```

- [ ] **Step 2: Run the Python test to verify it fails**

Run: `pytest -q tests/test_v280_backend_authentication_contract.py`
Expected: FAIL until the new gateway is explicitly wired.

- [ ] **Step 3: Write the minimal implementation**

Introduce only the wiring needed for a gateway dependency. Provide a local fail-closed gateway implementation if the constructor requires one; it must throw `AuthenticationFailureCode.unavailable` for every operation and contain no endpoint or credential data. Keep session state in memory and preserve logout clearing semantics.

- [ ] **Step 4: Run the focused Python tests**

Run: `pytest -q tests/test_v280_backend_authentication_contract.py tests/test_v278_authentication_provider.py tests/test_v279_session_lifecycle_hardening.py`
Expected: PASS with the existing Python environment.

- [ ] **Step 5: Filesystem checkpoint**

Preserve the changed files; no Git commit is claimed.

---

### Task 5: Security, Privacy, Architecture, and Documentation Verification

**Files:**
- Create: `docs/V280_BACKEND_AUTHENTICATION_CONTRACT.md`
- Modify: `tests/test_v280_backend_authentication_contract.py`

**Interfaces:**
- Produces a documented verification state that distinguishes Python verification from unavailable Flutter/Dart/APK verification.

- [ ] **Step 1: Write the failing regression checks**

Add structural checks for:

```python
def test_v280_does_not_add_credentials_to_account_session(project_root):
    text = (project_root / 'lib' / 'models' / 'account_session.dart').read_text()
    forbidden = ('password', 'refreshToken', 'accessToken', 'otp', 'payment')
    assert not any(name in text for name in forbidden)


def test_v280_authentication_does_not_reference_learner_state(project_root):
    text = (project_root / 'lib' / 'services' / 'authentication.dart').read_text()
    assert 'LearnerRepository' not in text
    assert 'LearnerState' not in text


def test_v280_has_no_new_dependencies(project_root):
    pubspec = (project_root / 'pubspec.yaml').read_text()
    assert 'shared_preferences:' in pubspec
    assert 'http:' in pubspec
```

- [ ] **Step 2: Run the regression checks**

Run: `pytest -q tests/test_v280_backend_authentication_contract.py`
Expected: FAIL before the final documentation and all structural assertions are in place.

- [ ] **Step 3: Write the minimal implementation/documentation**

Document the implemented contract, fail-closed state, non-goals, data ownership, and verification limitations. Do not record sample secrets or fake backend URLs. Keep the document explicit that production authentication requires a real backend and runtime verification.

- [ ] **Step 4: Run the full Python regression suite**

Run: `pytest -q`
Expected: 0 failures. If failures occur, stop and fix them before making any completion claim.

- [ ] **Step 5: Run available static/security checks**

Run the project's existing Python security/privacy/architecture checks using the same scripts used by V279. Expected: PASS. If Flutter/Dart remains unavailable, record Flutter/Dart/APK as `UNKNOWN / NOT RUN`.

- [ ] **Step 6: Final filesystem checkpoint**

Create a new archive of the verified snapshot. Record its SHA-256. Do not claim a Git commit, tag, release, or APK build.

---

## Final verification gate

Before calling the stage verified, execute all available checks fresh:

```bash
pytest -q
```

If Flutter is available:

```bash
flutter test
flutter analyze
```

If the project's Android build environment is available, run the existing build contract rather than inventing a new build command. Otherwise record it as `NOT RUN`.

The release state for this stage is **TESTED** only after fresh evidence is recorded. It must not be called **VERIFIED**, **RELEASE CANDIDATE**, or **RELEASED** without real backend/runtime integration and the production verification listed by the spec.

## Plan self-review

- Identity ownership is covered by Tasks 1–3.
- Provider verification remains behind the backend boundary; no provider SDK is implemented here.
- Session expiry/revocation semantics remain represented by `AccountSession` and the gateway contract; server-side revocation is explicitly a production integration requirement.
- Error categories are covered by Task 1 and fail-closed behavior by Tasks 2–4.
- OTP rate limiting, expiry, replay prevention, provider assertion validation, TLS-only transport, and server-side authorization are documented as backend requirements without inventing an implementation.
- Privacy/data minimization and learner/subscription separation are covered by Task 5.
- Migration/recovery requirements are documented and no existing credential migration is introduced.
- Explicit non-goals remain intact: no production backend, real providers, payment processing, entitlement verification, learner sync, account linking/deletion UI, or multi-language runtime.
- The plan contains no unresolved placeholders or unspecified implementation instructions.
