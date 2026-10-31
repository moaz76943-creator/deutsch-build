# Release Readiness Report — 3.3.10+133

Date: 2026-10-05
Baseline main at final synchronization: `b4ad22285e05a4d82c3be8da30b7166b6c1ed95a`
Hardening branch: `release/final-hardening-3.3.10-133-v2`

## Executive decision

**Status: CONDITIONALLY READY — final runtime gate and signed artifact build still required.**

The release source is structurally hardened for Android 3.3.10+133. The final hardening pass found and corrected concrete release blockers in the permission contract, CI exact-head verification, signing path handling, Codemagic test-build mode, mutable GitHub Action references, and destructive manual-preview release cleanup.

No learning-state, SRS, corpus, database schema, Adaptive Glass presentation, or application feature logic is modified by this hardening branch.

## Android permission audit

Source manifest after hardening:

- `android.permission.RECORD_AUDIO` — **retained / justified**.
  - The Android native pronunciation signal probe is registered by `MainActivity`.
  - The probe requests `Manifest.permission.RECORD_AUDIO` only when its permission method is invoked and uses `AudioRecord` for local pronunciation signal capture.
- `android.permission.POST_NOTIFICATIONS` — **removed**.
  - Notification service code exists in the repository, but there is currently no production composition/instantiation path for the local notification service or its permission gateway.
  - The permission must be reintroduced only when notification delivery is explicitly wired into the production composition root.
- `android.permission.INTERNET` — **absent by design**.
  - This preserves the Offline-First release contract.
- TTS discovery uses a `<queries>` declaration for `android.intent.action.TTS_SERVICE`; this is package visibility metadata, not a runtime permission.

Additional manifest hardening retained:
- `android:allowBackup="false"`
- `android:usesCleartextTraffic="false"`
- explicit backup/data-extraction rules
- launcher activity export limited to the launcher contract.

The release APK verifier now checks the **merged APK permission set**, not only the source manifest:
- requires `RECORD_AUDIO`;
- rejects `INTERNET`;
- rejects `POST_NOTIFICATIONS`.

This catches permissions introduced accidentally through manifest merging.

## CI/CD and build readiness

### GitHub required quality contexts

`.github/workflows/engineering-ci.yml`
- preserves required context names:
  - `Python engineering gates`
  - `Flutter Android readiness`
- both PR jobs now check out the exact pull-request HEAD SHA before reporting compatibility status.
- main integration continues to run the canonical local quality/build readiness paths.

`.github/workflows/quality.yml`
- checks out the exact PR HEAD.
- runs `scripts/local_quality_gate.sh`.
- Flutter/pub caches are disabled on the quality surface.
- Gradle cache is explicitly disabled for the isolated quality environment.

### GitHub release APK

`.github/workflows/build-apk.yml`
- private-repository and protected-ref gates retained.
- release signing remains mandatory.
- the keystore path is now absolute:
  `${{ github.workspace }}/android/app/upload-keystore.jks`.
- the canonical quality gate executes before the release build.
- release signing material is removed in the final cleanup step.

### GitHub signed AAB

`.github/workflows/build_aab.yml`
- manual, main-only signed release path.
- version contract: `3.3.10+133`.
- secure signing only; no debug signing fallback.
- builds with Dart obfuscation and split debug symbols.
- verifies the AAB signature with `jarsigner -verify -strict`.
- records SHA-256 and preserves AAB + symbols artifacts.

### Codemagic

`signed-android-aab`
- restricted to `main`.
- Flutter `3.44.9`, Java 17, NDK 28.2.13676358.
- required secret variables:
  - `CM_KEYSTORE_BASE64`
  - `CM_KEYSTORE_PASSWORD`
  - `CM_KEY_ALIAS`
  - `CM_KEY_PASSWORD`
- exact release command:
  `flutter build appbundle --release --obfuscate --split-debug-info=symbols/ --build-name=3.3.10 --build-number=133`
- verifies signature and records SHA-256.
- exports AAB, symbols, and checksum metadata.

`test-apk-build`
- corrected from an unsigned release build that conflicted with mandatory release signing.
- now uses the locked Flutter 3.44.9 / Java 17 toolchain.
- uses `flutter pub get --enforce-lockfile`.
- produces a debug test APK, so release signing secrets are not required.

### Manual APK/Web preview

`.github/workflows/build_apk.yml`
- restricted to `main`.
- now consumes the canonical toolchain lock for Flutter, Java, and Gradle.
- destructive deletion of older releases/tags was removed.
- publishing remains an explicit manual action.

### Supply-chain pinning

All 17 GitHub workflow files were inspected on the hardening branch.

**Result: 0 mutable third-party Action references.**

The remaining `actions/cache@v4` and `dart-lang/setup-dart@v1` references in `agents_pulse.yml` were replaced with immutable full commit SHAs.

## Security gate correction

`tool/security_audit.py` previously contained two release-blocking drifts:

1. it incorrectly required `android.permission.INTERNET` even though the canonical audio/offline contracts explicitly forbid it;
2. the quality-workflow cache requirements did not match the checked-in workflow.

The hardening branch aligns the audit and workflows without disabling or weakening the gate:
- `INTERNET` absence is now required;
- `RECORD_AUDIO` remains required for the native pronunciation probe;
- unused `POST_NOTIFICATIONS` is forbidden;
- isolated quality-cache requirements are implemented;
- immutable Action SHA enforcement remains active.

## Draft PR #225 disposition

PR #225, `Verify canonical premium Home implementation`, was closed as **SUPERSEDED** without merge.

Evidence:
- branch was 695 commits behind current main;
- comparison expanded to 158 changed files;
- it overlapped current integrated files including `lib/ui_v35/account_auth_page.dart` and `lib/ui_v35/app.dart`.

It is not safe to merge or auto-rebase into the release line. If Premium Home is revisited, it must be recreated from the then-current `main` and only the intended Home scope ported.

## Verification evidence completed in this hardening pass

Repository/static verification on the hardening branch:
- manifest permission contract: PASS;
- CI exact-head checkout contract: PASS;
- quality cache-isolation contract: PASS;
- GitHub APK signing path contract: PASS;
- GitHub AAB signing path contract: PASS;
- Codemagic signed AAB command/secrets/artifacts contract: PASS;
- Codemagic test APK no-release-signing contract: PASS;
- release version alignment `3.3.10+133`: PASS;
- merged-APK permission verification wiring: PASS;
- all 17 workflow third-party Action refs pinned to 40-character commit SHAs: PASS;
- final hardening branch includes the latest main persistence-regression contract and is not behind baseline main.

## Regression-suite architecture reconciliation

The Termux release gate exposed historical Python regression contracts that still searched for the pre-Phase3 composition root (`DeutschAppV35`, `AppDependencies<ContentItem>`, direct `SearchIndex`/backend/auth wiring in `main.dart`).

The gate was **not shortened** and no tests were skipped, xfailed, deleted, or excluded. `scripts/local_quality_gate.sh` still executes:

`python3 -m pytest -q tests`

Eighteen affected architecture-contract files were updated to assert the current production topology instead:

- render-first bootstrap before heavy corpus activation;
- `ActivePackRuntimeProvider` as the indexed corpus authority;
- bounded initial corpus window and explicit `Phase3ProductionShell` injection;
- inline `LearnerPersistence` composition at the current bootstrap boundary;
- backend/auth/search legacy graphs absent from the Offline-First production root;
- secure-storage native channel retained but not activated by the current production root;
- commute, pronunciation-lab, and error-pattern legacy surfaces remain isolated rather than falsely asserted as production-root dependencies.

Unchanged main-root contracts for gamification clock integrity, Phase17 failure hardening, and unified offline audio were re-inspected and still match the current `lib/main.dart`.

Because these test updates change the exact PR HEAD, the earlier analyzer evidence for `db97fec094197fcf9c7799a421a5e1146b34add6` is historical only. Runtime verification must target the new exact HEAD.

## Required evidence before merging the hardening PR

Run on the **exact final hardening HEAD**:

```bash
dart analyze lib/ 2>&1 | grep "error •"
bash scripts/local_quality_gate.sh
```

Expected:
- analyzer error output is empty;
- canonical local quality gate ends with `LOCAL QUALITY GATE: PASS`.

An independent adversarial review should also confirm that the CI/security changes do not weaken release gates.

## Required evidence before declaring the store artifact VERIFIED

After the hardening PR is merged:

1. run `signed-android-aab` in Codemagic on the resulting exact `main` HEAD using the four release signing secrets;
2. confirm `jarsigner -verify -strict` passes;
3. retain:
   - `app-release.aab`
   - `symbols/`
   - `release-metadata/SHA256SUMS.txt`;
4. record the final AAB SHA-256 and build HEAD in the release record.

Until that signed artifact exists on the post-hardening main HEAD, source readiness is not equivalent to a verified store binary.

## Final state classification

- Adaptive Glass application surfaces: **INTEGRATED**.
- Android source permission hardening: **IMPLEMENTED on hardening branch**.
- CI/CD release hardening: **IMPLEMENTED on hardening branch**.
- PR #225 stale-release risk: **CLOSED / SUPERSEDED**.
- Exact-head Runtime verification for hardening branch: **PENDING**.
- Signed production AAB for post-hardening main: **PENDING**.
- Overall production release: **CONDITIONALLY READY**.
