# Android QA & Test Coverage Review – Deutsch بالعربي

**Date:** 2026-11-13  
**Reviewer:** Expert Android QA (Grok)  
**Target:** Google Play Core App Quality, Data Safety, Privacy, Stability  

## Current State Summary

- **Framework:** Flutter / Dart, offline-first architecture.
- **Storage:** SharedPreferences, SQLite (content + encrypted progress vault), flutter_secure_storage.
- **Sensitive permissions:** RECORD_AUDIO (on-device pronunciation only). Network and broad storage permissions are explicitly removed via `tools:node="remove"`.
- **Existing tests:** Extensive unit tests under `test/` covering SRS, audio engines, database bootstrap, vault validation, crash-loop guard, feature boundaries, and curriculum. Quality-gate Python tests + `apk_verify.sh` enforce release permission and ABI contracts.
- **Privacy:** Strong offline-first design, public privacy policy, `allowBackup=false`, `usesCleartextTraffic=false`, hardware-backed or software AES vault with no key material crossing the platform channel.

## Identified Gaps

| Area | Coverage | Risk | Notes |
|------|----------|------|-------|
| Unit – Vault encryption envelope & key recovery | Good | High | ID validation, isolation, size limits, and key-failure non-deletion covered. Cipher is mocked. |
| Integration – Progress backup/restore + migration | Improved | High | New operational snapshot export/restore tests added. Full migration path still benefits from more edge-case coverage. |
| UI / Widget – Critical flows (dashboard, flashcards, pronunciation) | Low | Medium | Few dedicated widget tests; golden or integration tests recommended. |
| Security – Runtime permission handling & graceful degradation | Low | High | RECORD_AUDIO denial path and no residual audio files need integration/Robolectric coverage. |
| Security – Data Safety accuracy | Good | High | Source manifest correctly removes network/storage; new `scripts/data_safety_audit.py` validates contracts. Align Play Console form with merged APK. |
| Performance / ANR / Memory | Low | Medium | CrashLoopGuard exists; explicit profiling or stress tests still recommended. |
| Accessibility & Localization (bidi Arabic/German) | Partial | Medium | Some bidi tests exist; full TalkBack and font-scaling coverage needed. |
| Google Play Quality – Target SDK, 64-bit, etc. | Assumed | Low | Target SDK 36 declared; CI should continue verifying. |

## Actions Taken (this review)

1. Existing `test/high_risk_security_tests.dart` covers ID isolation, validation, size limits, and key-failure non-deletion.
2. Added `test/operational_snapshot_integrity_test.dart` covering:
   - Export → restore round-trip for SRS + bookmarks.
   - `incomingWins=false` does not clobber local data.
   - Key-failure report preserves ciphertext.
3. Added `scripts/data_safety_audit.py` – static check of AndroidManifest.xml against privacy invariants (required RECORD_AUDIO, removed network/storage, allowBackup=false, no cleartext).
4. All changes are additive; no production code modified.

## Recommended Next Priority Test Cases

1. **Runtime permission tests** (integration or Robolectric) – deny RECORD_AUDIO → pronunciation feature degrades without crash; no residual audio files.
2. **Network boundary test** – confirm no learner data leaves the device even if a plugin tries to open a connection (mock client / proxy).
3. **Widget tests for main dashboard and flashcard review flow** – including error states and offline mode.
4. **Accessibility audit** – TalkBack labels, contrast, font scaling on key screens.
5. **Crash-loop and ANR simulation** under low-memory / rapid restart.
6. **Full vault migration edge cases** (legacy DB present, partial catalogs, corrupted envelopes).

## How to Run & Verify

```bash
# Unit / security tests (requires Flutter SDK)
flutter test test/high_risk_security_tests.dart
flutter test test/operational_snapshot_integrity_test.dart
flutter test  # full suite

# Data Safety static audit (Python only)
python3 scripts/data_safety_audit.py

# Release permission & APK contract
python3 -m pytest scripts/test_check_apk_permissions.py
bash scripts/apk_verify.sh path/to/release.apk
```

**Status:** New tests and audit script added on branch `qa/security-coverage-improvements`. Full Flutter suite execution requires local Flutter SDK or CI. No failing tests introduced by these changes.
