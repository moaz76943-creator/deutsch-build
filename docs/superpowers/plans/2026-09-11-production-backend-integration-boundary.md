# Production Backend Integration Boundary Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a fail-closed, environment-configured backend authentication boundary without embedding a production URL or secret in the APK.

**Architecture:** A small runtime configuration object reads only non-secret `--dart-define` values for the auth base URL and optional host allowlist. `main.dart` selects the HTTPS transport only when the configuration is valid; otherwise it keeps the existing unavailable transport. No provider SDKs, credentials, or backend implementation are introduced.

**Tech Stack:** Flutter/Dart, existing `BackendTransport`/`HttpBackendTransport`, `String.fromEnvironment`, Python regression tests.

**Spec:** `docs/superpowers/specs/2026-09-11-backend-http-transport-design.md`

## Global Constraints

- HTTPS only.
- No production URL hardcoded in source.
- No secrets, tokens, passwords, or provider private keys in source/tests/logs/artifacts.
- Missing or invalid configuration must fail closed to unavailable transport.
- Learner state and subscription logic remain outside backend transport.
- Existing dependency lockfile must remain unchanged.

### Task 1: Add backend runtime configuration boundary

**Files:**
- Create: `lib/models/backend_runtime_config.dart`
- Test: `tests/test_v330_backend_runtime_config.py`

**Interfaces:**
- `BackendRuntimeConfig.fromEnvironment()` reads `DEUTSCH_AUTH_BASE_URL` and `DEUTSCH_AUTH_ALLOWED_HOSTS`.
- `bool get isConfigured` identifies a usable configuration.
- `Uri? get baseUri` returns only a validated HTTPS URI.

- [x] Step 1: Write failing tests for missing config, HTTP rejection, URL credential/query rejection, valid HTTPS config, and host allowlist rejection.
- [x] Step 2: Run `python -m pytest -q tests/test_v330_backend_runtime_config.py` and verify failure.
- [x] Step 3: Implement the minimal immutable configuration model with bounded host parsing and HTTPS-only validation.
- [x] Step 4: Re-run the focused test and verify PASS.
- [x] Step 5: Run `python -m pytest -q tests/test_v330_backend_runtime_config.py tests/test_v325_backend_http_transport.py`.

### Task 2: Wire configuration into boot without changing the safe default

**Files:**
- Modify: `lib/main.dart`
- Test: `tests/test_v330_main_backend_configuration.py`

**Interfaces:**
- `main.dart` constructs `HttpBackendTransport(config.baseUri!)` only when `config.isConfigured` is true.
- Otherwise it constructs `const UnavailableBackendTransport()`.

- [x] Step 1: Write failing source-level tests proving `main.dart` reads the config and preserves the unavailable fallback.
- [x] Step 2: Run the focused test and verify failure.
- [x] Step 3: Implement the smallest wiring change.
- [x] Step 4: Re-run the focused test and verify PASS.

### Task 3: Verify full project gates and archive

**Files:**
- No new production files.

- [x] Step 1: Run `python -m pytest -q tests`.
- [x] Step 2: Run `python tool/quality_audit.py`.
- [x] Step 3: Run `python tool/security_audit.py`.
- [x] Step 4: Run architecture/accessibility/weakness gates available in the repository.
- [x] Step 5: Verify `pubspec.lock` unchanged.
- [x] Step 6: Create `v330_release_archive/deutsch_bilarabi_v330_production_backend_integration_boundary_verified.zip` excluding prior archives and caches.
- [x] Step 7: Run `unzip -t` and SHA-256 verification.
