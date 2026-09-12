# Backend HTTP Transport Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a provider-neutral, bounded HTTPS transport for the existing backend authentication contract and reconcile all semantic-to-transport operation mappings.

**Architecture:** Keep `AuthenticationService` and `TransportBackendAuthenticationGateway` unchanged as the policy boundary. Add one injectable HTTP transport that only serializes/deserializes the existing transport models and maps network/protocol failures to `BackendTransportFailure`; no endpoint, provider SDK, token parsing, billing, or persistence is introduced.

**Tech Stack:** Dart/Flutter, `dart:convert`, `dart:io`, existing `http` package only where already present in the project; Python pytest for repository contract gates.

**Spec:** `docs/superpowers/specs/2026-09-11-backend-http-transport-design.md`

## Global Constraints

- No production backend URL may be hardcoded.
- No secrets may appear in source, tests, logs, or artifacts.
- Credentials remain opaque and transient.
- `SecureSessionStorage` remains the only credential persistence boundary.
- Client code must not decide premium entitlement.
- Request body ≤ 32 KiB; response body ≤ 64 KiB.
- HTTP timeout must be between 1 and 30 seconds; default 15 seconds.
- HTTPS is mandatory for the configured endpoint.
- Existing provider-neutral authentication models remain the public contract.
- Every production change follows RED → GREEN → regression verification.

---

### Task 1: Lock operation coverage and HTTP transport contract tests

**Files:**
- Create: `tests/test_v325_backend_http_transport.py`
- Test: `tests/test_v325_backend_http_transport.py`

**Interfaces:**
- Consumes: `BackendAuthenticationOperation`, `BackendAuthenticationApiRequest`, `BackendTransportOperation`, `BackendTransportRequest`, the planned HTTP transport constructor.
- Produces: executable tests proving every semantic operation maps to a transport operation and the HTTP transport enforces HTTPS, request/response bounds, timeout limits, and safe error mapping.

- [ ] **Step 1: Write the failing test**

```python
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_http_transport_module_exists_with_required_contract_symbols():
    source = (ROOT / "lib/services/backend_http_transport.dart").read_text()
    assert "class HttpBackendTransport" in source
    assert "BackendTransport" in source
    assert "BackendTransportFailure" in source
    assert "32 * 1024" in source
    assert "64 * 1024" in source
    assert "15" in source


def test_backend_api_maps_renew_and_revoke_operations():
    source = (ROOT / "lib/services/backend_authentication_api.dart").read_text()
    assert "BackendAuthenticationOperation.renewSession" in source
    assert "BackendAuthenticationOperation.revokeSession" in source
    assert "BackendTransportRequest.renewSession" in source
    assert "BackendTransportRequest.revokeSession" in source


def test_https_is_required_and_credentials_are_not_logged():
    source = (ROOT / "lib/services/backend_http_transport.dart").read_text()
    assert "Uri.https" in source or "scheme != 'https'" in source
    assert "print(" not in source
    assert "debugPrint(" not in source
    assert "credential" in source


def test_response_and_timeout_bounds_are_explicit():
    source = (ROOT / "lib/services/backend_http_transport.dart").read_text()
    assert "MAX_RESPONSE_BYTES" in source
    assert "MAX_REQUEST_BYTES" in source
    assert "timeout" in source
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `pytest tests/test_v325_backend_http_transport.py -q`
Expected: FAIL because `lib/services/backend_http_transport.dart` does not yet exist and the API mapping is incomplete.

- [ ] **Step 3: Do not modify production code in this step**

Keep the failure as the proof that the new contract is actually being tested before implementation.

- [ ] **Step 4: Re-run the same test and confirm the failure is specific**

Run: `pytest tests/test_v325_backend_http_transport.py -q`
Expected: failure references the missing transport module or missing renew/revoke mapping, not an unrelated repository error.

---

### Task 2: Add the minimal HTTP transport implementation

**Files:**
- Create: `lib/services/backend_http_transport.dart`
- Test: `tests/test_v325_backend_http_transport.py`

**Interfaces:**
- Consumes: `BackendTransportRequest` and `BackendTransportResponse`.
- Produces: `HttpBackendTransport(Uri baseUri, {Duration timeout = const Duration(seconds: 15)})` implementing `BackendTransport`.

- [ ] **Step 1: Write the minimal implementation**

The transport must:

```dart
final class HttpBackendTransport implements BackendTransport {
  HttpBackendTransport(
    this.baseUri, {
    Duration timeout = const Duration(seconds: 15),
  }) : timeout = _validateTimeout(timeout) {
    if (baseUri.scheme != 'https') {
      throw ArgumentError('Backend transport requires HTTPS');
    }
  }

  static const maxRequestBytes = 32 * 1024;
  static const maxResponseBytes = 64 * 1024;
  static const minTimeout = Duration(seconds: 1);
  static const maxTimeout = Duration(seconds: 30);

  final Uri baseUri;
  final Duration timeout;

  @override
  Future<BackendTransportResponse> send(
    BackendTransportRequest request,
  ) async {
    // 1. Serialize only fields belonging to the operation.
    // 2. Reject a request body > maxRequestBytes before network I/O.
    // 3. Send HTTPS POST to a stable path derived from the operation.
    // 4. Read at most maxResponseBytes + 1 bytes.
    // 5. Reject oversized or malformed responses without exposing body text.
    // 6. Decode only the existing session/credential fields.
    // 7. Map status/network/protocol failures to BackendTransportFailure.
  }
}
```

Use no hardcoded host. The path must be deterministic from `BackendTransportOperation` and must not include credential material.

- [ ] **Step 2: Run focused tests**

Run: `pytest tests/test_v325_backend_http_transport.py -q`
Expected: PASS.

---

### Task 3: Reconcile semantic API operation mapping

**Files:**
- Modify: `lib/services/backend_authentication_api.dart`
- Test: `tests/test_v325_backend_http_transport.py`

**Interfaces:**
- Consumes: `BackendAuthenticationApiRequest`.
- Produces: complete switch coverage for all `BackendAuthenticationOperation` values, including `renewSession` and `revokeSession`.

- [ ] **Step 1: Extend the failing contract test**

```python
def test_backend_api_has_complete_operation_switch():
    source = (ROOT / "lib/services/backend_authentication_api.dart").read_text()
    expected = [
        "BackendAuthenticationOperation.requestEmailOtp",
        "BackendAuthenticationOperation.verifyEmailOtp",
        "BackendAuthenticationOperation.authenticateProvider",
        "BackendAuthenticationOperation.currentSession",
        "BackendAuthenticationOperation.renewSession",
        "BackendAuthenticationOperation.revokeSession",
        "BackendAuthenticationOperation.signOut",
    ]
    for operation in expected:
        assert operation in source
```

- [ ] **Step 2: Run the focused test and observe RED**

Run: `pytest tests/test_v325_backend_http_transport.py::test_backend_api_has_complete_operation_switch -q`
Expected: FAIL on the missing renew/revoke branches.

- [ ] **Step 3: Add only the two missing switch branches**

```dart
BackendAuthenticationOperation.renewSession =>
  BackendTransportRequest.renewSession(
    credentials: _require(request.credentials, 'credentials'),
  ),
BackendAuthenticationOperation.revokeSession =>
  BackendTransportRequest.revokeSession(
    credentials: request.credentials,
  ),
```

- [ ] **Step 4: Re-run the focused test**

Run: `pytest tests/test_v325_backend_http_transport.py::test_backend_api_has_complete_operation_switch -q`
Expected: PASS.

---

### Task 4: Run the full repository verification gates

**Files:**
- Modify only files already listed above if verification exposes a V325-specific defect.

- [ ] **Step 1: Run Python regression**

Run: `pytest -q`
Expected: all tests pass.

- [ ] **Step 2: Run repository audits**

Run the existing repository security, privacy, quality, accessibility, architecture, and weakness checks exposed under `tool/` and `scripts/`, using their normal project commands.

Expected: every existing gate passes with zero new warnings.

- [ ] **Step 3: Run sensitive-content checks**

Confirm no endpoint host, API key, token, OTP, password, private key, or credential literal was added to tracked source/tests/docs/artifacts.

- [ ] **Step 4: Validate archive contents**

Create a V325 archive containing the source/test/docs checkpoint while excluding prior release archives, caches, generated build outputs, and secrets. Validate the archive integrity and calculate SHA-256.

- [ ] **Step 5: Record the checkpoint**

Status: `V325 — VERIFIED` only after all fresh commands above pass. Record exact test counts and SHA-256 in the release note.
