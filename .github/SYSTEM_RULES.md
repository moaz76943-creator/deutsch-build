# SYSTEM RULES

These rules are mandatory for every contribution.

## 1. Offline-First — Absolute
- The application MUST remain fully offline-first.
- Network permissions and external networking are forbidden, including `INTERNET`, HTTP clients, sockets, remote APIs, telemetry, cloud sync, and runtime network dependencies.
- No change may introduce or restore network access.

## 2. Architecture & Local Persistence
- Direct access to `SharedPreferences` is forbidden outside the approved Local Persistence Adapter/Port boundary.
- Features MUST depend on the persistence port/adapter abstraction, never on storage implementation details.

## 3. Backward Compatibility & Regression Safety
- Active contracts MUST NOT be broken.
- Existing behavioral guarantees MUST remain covered by regression tests.
- Prefer behavior/contract assertions; do not duplicate brittle source-text or exact-implementation checks when behavior can be verified directly.

## 4. Mandatory Quality Gate
- Every contribution MUST pass:
  ```bash
  bash scripts/local_quality_gate.sh
  ```
- A change MUST NOT be accepted, merged, or treated as valid until this gate passes.
