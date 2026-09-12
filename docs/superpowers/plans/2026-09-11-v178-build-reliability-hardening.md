# V178 Build Reliability Hardening Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the V177 Deutsch بالعربي build pipeline reproducible, non-destructive, provenance-aware, and easy to run on Termux ARM64 while preserving all application behavior and tests.

**Architecture:** A single `toolchain.lock` feeds shell guards, installers, CI, and diagnostic output. Dedicated scripts handle preflight, tests, APK verification, and provenance; `build.sh` composes them without hiding failures or deleting caches.

**Tech Stack:** Flutter/Dart, Android Gradle Plugin, Gradle Wrapper, Kotlin, Bash, Python/pytest, Android SDK verification tools.

**Spec:** `docs/superpowers/specs/2026-09-11-build-reproducibility-hardening-design.md`

## Global Constraints

- Keep Flutter + Dart as the application technology.
- Reference Flutter toolchain: Flutter 3.44.9 / Dart 3.12.2 / Android ARM64.
- Keep `pubspec.yaml` and `pubspec.lock`; no automatic dependency upgrade.
- No `flutter pub upgrade --major-versions` in build scripts.
- No `flutter clean` in the normal build path.
- No destructive deletion of Flutter, SDK, NDK, Gradle, caches, projects, APKs, ZIPs, Git history, branches, or tags.
- `flutter analyze` must remain a real gate.
- `flutter test` and project regression tests must remain real gates.
- Preserve corpus and existing app features.
- Termux ARM64 may use native AAPT2 configuration; generic Linux/CI must remain portable.
- Release APK verification must include package/version/ABI/manifest/resources/signing/SHA256.

---

### Task 1: Establish the single toolchain contract

**Files:**
- Create: `toolchain.lock`
- Modify: `android/app/build.gradle`
- Modify: `android/build.gradle`
- Modify: `android/settings.gradle`
- Modify: `android/gradle/wrapper/gradle-wrapper.properties`
- Test: `tests/test_v178_build_reproducibility.py`

**Interfaces:**
- `toolchain.lock` exposes shell-safe `KEY=VALUE` variables for all pinned versions.
- Android Gradle configuration remains functionally identical except for explicit NDK metadata if needed by the pinned contract.

- [ ] **Step 1: Write failing tests**
  Assert `toolchain.lock` exists, contains Flutter 3.44.9/Dart 3.12.2/Java 21/Gradle 8.13/AGP 8.13.2/Kotlin 2.3.0/SDK 36/Build Tools 36.0.0/ABI arm64-v8a, and that scripts/workflows do not hardcode a conflicting Flutter version.

- [ ] **Step 2: Run the focused test and verify RED**
  Run `pytest tests/test_v178_build_reproducibility.py -q`; it must fail because the contract does not yet exist.

- [ ] **Step 3: Add `toolchain.lock` and align version consumers**
  Use one key-value contract and update installer/bootstrap/CI/guards to source it rather than duplicating toolchain numbers.

- [ ] **Step 4: Run focused test and full Python regression**
  Run `pytest tests/test_v178_build_reproducibility.py -q` then `pytest -q tests`.

- [ ] **Step 5: Preserve existing Gradle pin integrity**
  Verify the wrapper SHA-256 pin remains unchanged and the Gradle/AGP/Kotlin relationship remains supported.

---

### Task 2: Make dependency resolution reproducible and non-mutating

**Files:**
- Modify: `scripts/build_guard.sh`
- Modify: `scripts/test.sh`
- Modify: `scripts/build.sh`
- Modify: `.github/workflows/quality.yml`
- Modify: `.github/workflows/build-apk.yml`
- Test: `tests/test_v178_build_reproducibility.py`

**Interfaces:**
- Shell helper `snapshot_lockfile()` records the checked-in lock hash.
- Shell helper `assert_lockfile_unchanged()` fails on any `pubspec.lock` mutation.

- [ ] **Step 1: Add failing tests**
  Assert build/test scripts snapshot and compare `pubspec.lock`, CI contains no automatic `flutter pub cache repair`, and no build script calls dependency upgrade.

- [ ] **Step 2: Verify RED**
  Run the focused test and confirm it fails on the missing lockfile mutation guard/CI repair contract.

- [ ] **Step 3: Implement minimal lockfile guards**
  Run `flutter pub get`, compare SHA256 before/after, and fail with a remediation message if changed. Do not delete or rewrite the lockfile.

- [ ] **Step 4: Run tests**
  Run focused and full Python tests.

---

### Task 3: Harden environment guard and doctor output

**Files:**
- Modify: `scripts/build_guard.sh`
- Modify: `scripts/doctor.sh`
- Modify: `scripts/build_deutsch.sh`
- Modify: `tool/bootstrap_flutter_android.sh`
- Test: `tests/test_v178_build_reproducibility.py`

**Interfaces:**
- `build_guard.sh` sources `toolchain.lock` and validates actual Flutter/Dart/Java/Gradle/SDK/Build Tools/architecture/path state.
- `doctor.sh` reports `PASS/WARN/FAIL` per component and exits non-zero only when a required Android build prerequisite is broken.

- [ ] **Step 1: Add failing tests**
  Assert guards source `toolchain.lock`, build/doctor scripts use portable `#!/usr/bin/env bash`, and no Termux-only interpreter is required by generic scripts.

- [ ] **Step 2: Verify RED**
  Run the focused test.

- [ ] **Step 3: Implement the guard/doctor contract**
  Add explicit version parsing, Flutter↔Dart path validation, Android SDK/build-tools checks, NDK detection with “required vs available” semantics, Gradle wrapper validation, disk-space check, and concise doctor rows.

- [ ] **Step 4: Run shell syntax checks and Python tests**
  Run `bash -n` on all maintained shell scripts and `pytest -q tests`.

---

### Task 4: Add APK verifier and build provenance

**Files:**
- Create: `scripts/apk_verify.sh`
- Modify: `scripts/build.sh`
- Test: `tests/test_v178_build_reproducibility.py`

**Interfaces:**
- `apk_verify.sh <apk> <debug|release>` returns non-zero on any failed APK invariant and prints package/version/ABI/manifest/resources/signing status.
- `build.sh` calls the verifier before printing final success and writes `build/build-info-<mode>.txt`.

- [ ] **Step 1: Add failing tests**
  Assert verifier exists, checks `com.deutschbilarabi.app`, version from `pubspec.yaml`, `arm64-v8a`, manifest/resources, and uses `apksigner` for release.

- [ ] **Step 2: Verify RED**
  Run the focused test.

- [ ] **Step 3: Implement verifier**
  Prefer `aapt`/`apkanalyzer`/`apksigner`/`unzip` according to availability. Never fabricate a result; if a required verifier is absent, fail with installation guidance.

- [ ] **Step 4: Implement provenance output**
  Record app version/build number, Flutter/Dart versions, Android target, mode, Git commit or `unknown` when no Git metadata exists, APK size, and SHA256.

- [ ] **Step 5: Run focused and full tests**
  Run `pytest -q tests` and shell syntax checks.

---

### Task 5: Enforce non-destructive script policy and CI parity

**Files:**
- Modify: `install_flutter.sh`
- Modify: `scripts/build.sh`
- Modify: `scripts/test.sh`
- Modify: `scripts/doctor.sh`
- Modify: `scripts/build_guard.sh`
- Modify: `build_deutsch.sh`
- Modify: `.github/workflows/quality.yml`
- Modify: `.github/workflows/build-apk.yml`
- Test: `tests/test_v178_build_reproducibility.py`

**Interfaces:**
- All build/install scripts are statically rejectable if they introduce forbidden destructive commands.
- CI consumes the same `toolchain.lock` values and invokes the same audits without repairing caches automatically.

- [ ] **Step 1: Add failing destructive-policy tests**
  Scan installer/build/doctor/test scripts and fail on active `rm -rf`, `rm -f`, `git reset --hard`, branch deletion, tag deletion, or cache purge patterns.

- [ ] **Step 2: Verify RED**
  Run focused test and record exact offending lines.

- [ ] **Step 3: Remove/replace only unsafe operations**
  Preserve existing safe cleanup of script-owned temporary files; do not introduce broad deletion as a workaround.

- [ ] **Step 4: Align CI with local gates**
  Use lockfile values, run content/security audits, and call APK verification after release build. Keep signing material removal scoped to the ephemeral CI keystore file.

- [ ] **Step 5: Run all static gates**
  Run `pytest -q tests`, `python -m compileall -q tool tests`, and `bash -n` over all maintained shell scripts.

---

### Task 6: Final integrity review and V178 artifact

**Files:**
- Create: `docs/V178_BUILD_RELIABILITY_HARDENING.md`
- Modify: `pubspec.yaml` only if a build-number change is necessary for the versioned artifact.

- [ ] **Step 1: Add V178 change log**
  Document the single toolchain source, dependency mutation guard, structured doctor, APK verification, provenance, and non-destructive policy.

- [ ] **Step 2: Run content/security audits**
  Run `python tool/quality_audit.py` and `python tool/security_audit.py`.

- [ ] **Step 3: Run full Python regression suite**
  Run `pytest -q tests` and require zero failures.

- [ ] **Step 4: Run available Flutter gates**
  If Flutter is installed and the Android SDK is usable, run `flutter analyze`, `flutter test`, and `scripts/build.sh release`. If unavailable in the current environment, report that fact and do not claim APK success.

- [ ] **Step 5: Package V178 from the modified V177 source**
  Create a new ZIP without deleting V177 or any other previous artifact and record SHA256.
