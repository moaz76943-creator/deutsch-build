# Backend Transport Factory Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Isolate runtime selection of the authentication backend transport from `main.dart` while preserving fail-closed behavior.

**Architecture:** `BackendTransportFactory` is the sole composition boundary that converts the non-secret `BackendRuntimeConfig` into either `HttpBackendTransport` or `UnavailableBackendTransport`. `main.dart` only requests a transport from the factory; authentication and transport contracts remain unchanged.

**Tech Stack:** Dart, Flutter, existing backend transport contracts, pytest-based repository contract tests.

**Spec:** `docs/superpowers/specs/2026-09-11-backend-http-transport-design.md`

**Global Constraints:**
- HTTPS-only backend transport; no production URL hardcoded in application source.
- No secrets in source, content, tests, logs, or artifacts.
- Missing or invalid runtime configuration must fail closed to `UnavailableBackendTransport`.
- Preserve existing `BackendTransport` and authentication interfaces.
- Do not add external packages or introduce destructive cleanup/build changes.

### Task 1: Transport composition boundary

**Files:**
- Create: `lib/services/backend_transport_factory.dart`
- Modify: `lib/main.dart`
- Test: `tests/test_v331_backend_transport_factory.py`

**Interfaces:**
- Consumes: `BackendRuntimeConfig`, `BackendTransport`.
- Produces: `BackendTransportFactory.fromRuntimeConfig(config)` returning a `BackendTransport`.

- [x] **Step 1: Write the failing test**

Create `tests/test_v331_backend_transport_factory.py` with these checks:

```python
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_factory_exists_and_exposes_runtime_config_entrypoint():
    source = (ROOT / "lib/services/backend_transport_factory.dart").read_text()
    assert "class BackendTransportFactory" in source
    assert "fromRuntimeConfig" in source
    assert "BackendRuntimeConfig" in source
    assert "BackendTransport" in source


def test_factory_selects_http_transport_only_for_configured_runtime():
    source = (ROOT / "lib/services/backend_transport_factory.dart").read_text()
    assert "config.isConfigured" in source
    assert "HttpBackendTransport(config.baseUri!)" in source
    assert "UnavailableBackendTransport()" in source


def test_main_uses_factory_instead_of_constructing_transport_directly():
    source = (ROOT / "lib/main.dart").read_text()
    assert "BackendTransportFactory.fromRuntimeConfig(config)" in source
    assert "HttpBackendTransport(config.baseUri!)" not in source


def test_factory_does_not_contain_network_url_literals_or_secrets():
    source = (ROOT / "lib/services/backend_transport_factory.dart").read_text()
    assert "https://" not in source
    assert "client_secret" not in source
    assert "api_key" not in source.lower()
    assert "password" not in source.lower()
```

- [x] **Step 2: Run test to verify it fails**

Run:

```bash
pytest tests/test_v331_backend_transport_factory.py -q
```

Expected: FAIL because `backend_transport_factory.dart` does not yet exist and `main.dart` still constructs the concrete transports itself.

- [x] **Step 3: Write minimal implementation**

Create `lib/services/backend_transport_factory.dart`:

```dart
import '../models/backend_runtime_config.dart';
import '../models/backend_transport.dart';
import 'backend_http_transport.dart';
import 'backend_transport.dart';

/// Composes the authentication backend transport from non-secret runtime configuration.
final class BackendTransportFactory {
  const BackendTransportFactory._();

  static BackendTransport fromRuntimeConfig(BackendRuntimeConfig config) {
    if (!config.isConfigured) {
      return const UnavailableBackendTransport();
    }
    return HttpBackendTransport(config.baseUri!);
  }
}
```

Then replace the direct selection in `lib/main.dart`:

```dart
final config = BackendRuntimeConfig.fromEnvironment();
final BackendTransport transport =
    BackendTransportFactory.fromRuntimeConfig(config);
```

and add the factory import while removing the now-unused `backend_http_transport.dart` import.

- [x] **Step 4: Run test to verify it passes**

Run:

```bash
pytest tests/test_v331_backend_transport_factory.py -q
pytest -q
```

Expected: focused tests PASS and the full repository regression remains green.

- [x] **Step 5: Run repository security/architecture checks**

Run:

```bash
python tool/security_audit.py
python tool/privacy_audit.py
python tool/quality_audit.py
python tool/accessibility_audit.py
python tool/architecture_audit.py
python tool/weakness_gate.py
```

Expected: all checks PASS; no new secret or network URL literals in application source.

- [ ] **Step 6: Verify archive contents and hash**

Create a V331 release archive excluding nested release archives, caches, APK/AAB files, logs, and secrets. Then verify it with `unzip -l` and `sha256sum` before reporting the artifact.
