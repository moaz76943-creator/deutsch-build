# V379 — Network & Runtime Configuration Boundary Hardening

## Scope

This phase closes a remaining production-architecture leak: the UI previously read cloud-AI compile-time configuration and constructed the HTTP adapter itself.

## Changes

- Added `AiRuntimeConfig` as the single owner of non-secret AI compile-time configuration.
- Added `AiGatewayFactory` as the composition-root factory for offline/HTTPS AI gateways.
- `AppDependencies` now carries the selected `AiGateway` dependency.
- `main.dart` owns runtime configuration parsing and gateway construction.
- Writing and conversation UI now consume the injected `AiGateway`; they no longer parse endpoints, host allowlists, or construct HTTP clients.
- Architecture boundary gate now enforces:
  - `package:http` only in approved network adapters.
  - `dart:io` only in approved network/platform adapters.
  - `String.fromEnvironment` only in configuration boundaries.
- Existing endpoint HTTPS/host pinning remains enforced inside `HttpsAiGateway`.

## Compatibility / safety

No SRS, mastery, learner persistence, entitlement, authentication policy, or content semantics were intentionally changed.

The cloud AI path remains opt-in through the existing privacy setting and remains offline by default when no valid owner configuration exists.

## Verification

- Architecture boundary gate: PASS (`findings=0`)
- Architecture audit: PASS
- Full pytest: PASS
- Flutter/Android build: not claimed; Flutter SDK is unavailable in the execution environment.
