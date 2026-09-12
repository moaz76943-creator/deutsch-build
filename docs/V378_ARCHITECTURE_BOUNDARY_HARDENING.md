# V378 — Architecture Boundary Hardening

## Goal
Strengthen the architecture gate so that the existing green language-boundary result is complemented by enforceable dependency and storage-adapter boundaries.

## Changes
- Added `tool/architecture_boundary_gate.py`.
- `lib/core` and `lib/models` are forbidden from importing `lib/services`.
- `shared_preferences` is allowed only through `lib/services/preferences_service.dart`.
- Integrated the dependency boundary into `tool/architecture_audit.py`.
- The audit now accepts an optional repository root, while preserving the normal project-root default.
- Added regression tests covering both violations and a clean repository.

## Verification policy
This stage adds architecture enforcement only; it does not alter learner behavior, SRS behavior, entitlements, authentication, or persistence formats.

Flutter/Android verification remains separate when the Flutter SDK is available.
