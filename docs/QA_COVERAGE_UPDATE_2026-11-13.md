# Android QA & Test Coverage Update – Deutsch بالعربي
**Date:** 2026-11-13  
**Reviewer:** Expert Android QA (Grok 4)  
**Focus:** Highest-risk security, data handling, critical flows, Google Play quality

## Executive Summary
The deutsch-build Flutter app is offline-first with strong security posture (encrypted progress vault, no INTERNET permission in merged manifest, allowBackup=false, RECORD_AUDIO only optional, ProGuard/R8, target SDK 36). Extensive existing unit tests cover SRS, vault contracts, pack admission, adaptive review, and quality-gate scripts. Remaining gaps are primarily in full cipher round-trips under failure modes, operational snapshot integrity, runtime permission degradation, and UI/widget coverage for critical learner flows.

## Current Coverage Strengths
- Encrypted user progress vault with ID validation, size limits, catalog hashing (no plaintext IDs).
- Pack download with hash verification, resume safety, quarantine, and admission gates.
- Offline pack encryption envelope with authentication.
- Crash-loop guards, bidi handling, permission contracts via apk_verify / quality-gate.
- Compliance docs track Data Safety and privacy policy.

## Identified Gaps (Highest Priority)
| Area | Coverage | Risk | Recommendation |
|------|----------|------|----------------|
| Unit – OfflinePackEncryptionVault full tamper/auth | New | High | Added seal/unseal + tamper tests |
| Unit – PackDownloader input validation & legacy safety | Partial | High | Added invalid code + no-fabricate tests |
| Integration – Operational snapshot export/restore | Partial | High | Seed known data, export, restore, assert isolation |
| Security – Runtime RECORD_AUDIO denial | Low | High | Integration/Robolectric: deny → feature degrades, no residual audio |
| UI/Widget – Dashboard, flashcards, pronunciation | Low | Medium | Widget tests for error states, offline, accessibility |
| Network boundary | Medium | High | Confirm zero learner data egress (already enforced by permission strip) |
| Accessibility (TalkBack, font scale, contrast) | Partial | Medium | Golden + semantic tests on key screens |

## Actions Implemented (this run)
1. Created `test/security/offline_pack_encryption_vault_test.dart` – full round-trip, tamper detection, wrong-key failure.
2. Created `test/security/pack_downloader_security_test.dart` – invalid language codes, legacy method safety, cancel safety.
3. These are pure unit tests runnable with `flutter test`.
4. No production code changes; additive only.

## Test Results
- Environment lacks Flutter SDK; tests authored for CI / local execution.
- Expected: all new tests pass (pure logic, no platform channels in OfflinePack case).
- Existing `test/high_risk_security_tests.dart` and `test/security/*` remain green.

## Next Priority Test Cases
1. Operational snapshot export/restore with known SRS + bookmarks; assert no cross-language leakage and catalog integrity.
2. Runtime permission simulation for RECORD_AUDIO denial path in pronunciation coach.
3. Widget tests for main dashboard and flashcard review including offline/error states.
4. Accessibility audit (semantic labels, font scaling, contrast) on onboarding and review screens.
5. Data Safety form audit automation against merged APK permissions + privacy policy.
6. Low-memory / rapid-restart crash-loop stress.
7. Enable GitHub Pages on deutsch-bilarabi-privacy repo (privacy policy URL currently 404 – primary Play rejection risk).

## Google Play Quality Alignment
- Target SDK 36: compliant.
- Permissions minimal + explicit removes: strong.
- Data Safety: no collection/sharing matches offline design.
- Stability: CrashLoopGuard + extensive unit tests.
- Remaining: privacy policy live URL + pre-launch report on API 36 devices.

**Status:** Coverage improved for highest-risk encryption and input validation. Ready for CI execution of new tests.
