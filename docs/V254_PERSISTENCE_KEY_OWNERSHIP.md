# V254 — Persistence Key Ownership Gate

## Goal

Make local persistence ownership explicit so an approved storage key cannot be silently reused by another feature or layer.

## Ownership contract

| Key | Owner |
|---|---|
| `v34_state` | `lib/services/repository.dart` |
| `verb_favorites_v1` | `lib/services/repository.dart` |
| `privacy_cloud_ai_v1` | `lib/services/privacy_settings.dart` |
| `privacy_speech_v1` | `lib/services/privacy_settings.dart` |

## Enforcement

`tool/privacy_audit.py` now inventories the file that references each persistence key and fails if an approved key appears outside its declared owner. It also fails if a declared key disappears from the inventory.

This is intentionally a narrow hardening change. No runtime behavior, learner data format, content, dependency, or build configuration was changed.

## TDD evidence

Focused red test:

`pytest -q tests/test_v254_persistence_key_ownership.py`

Initial result: failed because `PrivacyReport` did not expose `local_storage_owners`.

Minimal implementation added ownership inventory and enforcement.

Focused green result: `1 passed`.

Full regression: `242 passed`.

Additional verification:

- Privacy audit: PASS
- Python compileall: PASS
- `scripts/build.sh` bash syntax: PASS
- `scripts/doctor.sh` bash syntax check was attempted; no failure was emitted.
- Flutter/Android build remains unverified because the current environment does not contain the required Flutter/Android toolchain.
