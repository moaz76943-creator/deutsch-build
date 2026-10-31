# V169 — Core Hotpath & Correctness Hardening

Release: `1.81.0+91` / Android `versionCode 91`.

## Changes

- `MistakeEngine` now builds one content-id index instead of scanning the full content catalog for every mistake item.
- `LearningEngine` now builds one eligible-content index and reuses it for all selected-item lookups.
- Removed one redundant `LearningIntelligence` sort while preserving the bounded trim sort and final ordering sort.
- `HttpsAiGateway` now normalizes the configured base URI with a trailing slash and resolves relative API paths, preserving a deployment path prefix such as `/gateway/`.
- Updated stale historical contracts to reflect the V167 persisted-state normalization and V168 Gradle wrapper bootstrap behavior.
- Bumped Android release metadata to `1.81.0+91`.

## Verification

- 104 static regression tests: PASS.
- Python compile/test harness: PASS.
- Security audit: PASS.
- Content quality audit: PASS (14,793 entries; unique IDs and German entries).
- Architecture audit: PASS (maximum UI file 1,000 lines; oversized files 0).
- Accessibility static audit: PASS (0 warnings).

Flutter/Android compilation and runtime QA remain environment-dependent and were not claimed locally because this environment has no Flutter SDK/Android SDK.
