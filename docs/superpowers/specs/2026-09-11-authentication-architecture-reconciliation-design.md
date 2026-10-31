# V295 — Authentication Architecture Reconciliation Design

## Status

IMPLEMENTED AND VERIFIED

## Goal

Reconcile the authentication subsystem with the app's established architecture by separating public contracts, failures, backend gateway, and authentication orchestration without changing externally visible behavior.

## Architecture

`authentication.dart` is a compatibility barrel only. Authentication responsibilities are separated into focused services:

- `authentication_contract.dart` — provider-neutral interfaces and public contracts.
- `authentication_failures.dart` — authentication failure taxonomy.
- `authentication_backend_gateway.dart` — backend semantic boundary and fail-closed transport adapter.
- `authentication_service.dart` — provider/session orchestration and lifecycle.

Learning state, content, and subscription authority remain outside the authentication subsystem.

## Compatibility rules

- Existing imports of `services/authentication.dart` remain valid through exports.
- Public class and constructor behavior is preserved.
- No runtime dependency is added.
- No authentication credential is exposed through `AccountSession`.
- No learner or subscription state is owned by authentication.
- No provider-specific SDK is introduced.

## Verification requirements

- Focused architecture tests must pass.
- Full Python regression must pass.
- Security, privacy, architecture, accessibility, and quality audits must pass.
- Flutter/Dart/APK remain explicitly unverified when the SDK/toolchain is unavailable.
