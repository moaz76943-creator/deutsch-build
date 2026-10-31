# Deutsch بالعربي — Build Reproducibility Hardening Design

## Goal

Make the current V177 project reproducible and maintainable on Termux/Android ARM64 without reducing application features, corpus, tests, security, or analyzer strictness.

## Binding toolchain contract

The project will use one repository-level `toolchain.lock` as the source of truth for build-tool versions. The approved reference is Flutter 3.44.9 with Dart 3.12.2, Java 21, Gradle 8.13, AGP 8.13.2, Kotlin 2.3.0, Android compile/target SDK 36, min SDK 23, Android Build Tools 36.0.0, and ARM64 APK targeting. NDK 27.0.12077973 is recorded as the AGP-compatible reference, but the guard will distinguish “required by the current project” from “available in the SDK” so an unused NDK does not block a pure-Dart Android build.

## Build flow

`doctor.sh` is diagnostic and structured. `build_guard.sh` is a hard preflight. `test.sh` is the complete local quality gate. `build.sh debug|release` orchestrates guard → dependency integrity → analyze → Flutter tests → project/content/security audits → Android build → APK verification → build provenance/SHA256.

`flutter pub get` is allowed only as dependency resolution against the checked-in lockfile. Build/test scripts snapshot `pubspec.lock` before resolution and fail if it changes. CI must not run `flutter pub cache repair` automatically.

## APK verification

A dedicated verifier will check existence, non-zero size, package ID, versionName/versionCode, `arm64-v8a` native library presence, manifest/resources, and release signing through Android SDK/Termux verification tools. SHA256 is emitted only after all checks pass.

## Safety

No build or installer script may contain general destructive commands such as `rm -rf`, `rm -f`, `git reset --hard`, branch/tag deletion, or cache purges. Existing toolchains/configuration are preserved. Termux-specific ARM64 AAPT2 configuration remains isolated from generic Linux/CI paths.

## Provenance

Each successful APK build writes a build-info record containing app version, build number, Flutter/Dart versions, Android target, build mode, Git commit when available, APK path, size, and SHA256. No claim of a successful Android build is emitted without a real verified APK.

## Compatibility/legacy review

This phase does not remove `ui_v35` or any data/service/UI file merely because it is old. Existing imports and behavior remain intact. Package-facing compatibility refactors are limited to evidence-based hotspots; this build-hardening phase does not rewrite working application behavior.

## Validation

Every new contract gets a static regression test first (RED), then the minimal implementation (GREEN), followed by the full Python regression suite. Flutter analyzer/tests and an actual Android build remain required gates when the Flutter toolchain is available; this environment cannot honestly substitute static checks for those unavailable runtime/build commands.
