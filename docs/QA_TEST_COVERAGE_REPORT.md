# Android QA & Test Coverage Review – Deutsch بالعربي

**Date:** 2026-10-24  
**Reviewer:** Expert Android QA (Grok)  
**Target:** Google Play Core App Quality, Data Safety, Privacy, Stability  

## Current State Summary

- **Framework:** Flutter / Dart, offline-first architecture.
- **Storage:** SharedPreferences, SQLite (content + encrypted progress vault), flutter_secure_storage.
- **Sensitive permissions:** RECORD_AUDIO (on-device pronunciation), INTERNET + ACCESS_NETWORK_STATE (optional updates).
- **Existing tests:** Extensive unit tests under `test/` covering SRS, audio, database bootstrap, vault validation, crash loop guard, feature boundaries, etc. Quality-gate Python tests + `apk_verify.sh` enforce release permission contracts.
- **Privacy:** Strong offline-first design, public privacy policy, storage permissions explicitly removed, allowBackup=false.

## Identified Gaps

| Area | Coverage | Risk | Notes |
|------|----------|------|-------|
| Unit – Vault encryption envelope & key recovery | Partial | High | Validation and key uniqueness tested; full cipher round-trip and catalog integrity need more mocks. |
| Integration – Progress backup/restore + migration | Partial | High | Complex vault migration and operational snapshot logic. |
| UI / Widget – Critical flows (dashboard, flashcards, pronunciation) | Low | Medium | Few dedicated widget tests; golden or integration tests recommended. |
| Security – Runtime permission handling & graceful degradation | Low | High | RECORD_AUDIO denial path and no network leakage of learner data. |
| Security – Data Safety accuracy | Medium | High | Source manifest still declares INTERNET; release contracts and verify scripts reject it. Align Data Safety form with actual merged APK. |
| Performance / ANR / Memory | Low | Medium | No explicit profiling tests; CrashLoopGuard is a good start. |
| Accessibility & Localization (bidi Arabic/German) | Partial | Medium | Some bidi tests exist; full screen reader and font scaling coverage needed. |
| Google Play Quality – Target SDK, 64-bit, etc. | Assumed | Low | Target SDK 36 declared; verify in CI. |

## Actions Taken (this review)

1. Added `test/high_risk_security_tests.dart` focusing on:
   - Progress key uniqueness / isolation across languages.
   - Strict ID validation (traversal, injection, length).
   - Catalog key derivation (no plaintext lexeme in SQLite index).
   - Key-failure recovery does not delete ciphertext.
2. These tests are pure unit tests and can be run with `flutter test`.

## Recommended Next Priority Test Cases

1. **Mocked vault cipher round-trip** – encrypt/decrypt with a fake VaultCipher; assert envelope format (version byte 1 or 2) and size limits.
2. **Operational snapshot export/restore integrity** – seed known SRS + bookmarks, export, restore, assert no data loss or cross-language leakage.
3. **Runtime permission tests** (integration or Robolectric) – deny RECORD_AUDIO → pronunciation feature degrades without crash; no residual audio files.
4. **Network boundary test** – with INTERNET stripped in release, verify no unexpected http calls of learner data (use mock client or proxy).
5. **Widget tests for main dashboard and flashcard review flow** – including error states and offline mode.
6. **Data Safety form audit script** – parse merged APK permissions + privacy policy and flag mismatches before Play upload.
7. **Accessibility audit** – TalkBack labels, contrast, font scaling on key screens.
8. **Crash-loop and ANR simulation** under low-memory / rapid restart.

## How to Run & Verify

```bash
flutter test test/high_risk_security_tests.dart
flutter test  # full suite
# Release permission contract:
python3 -m pytest tests/quality_gate/
bash scripts/apk_verify.sh path/to/release.apk
```

All changes are additive and safe. No production code modified.  
**Status:** Tests added; full suite execution requires local Flutter SDK or CI.
