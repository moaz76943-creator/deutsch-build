# V178 — Build Reliability & Reproducibility Hardening

V178 keeps the V177 application behavior and corpus intact while hardening the build system.

## Main changes

- Added `toolchain.lock` as the single source of truth for Flutter 3.44.9 / Dart 3.12.2, Java 21, Gradle 8.13, AGP 8.13.2, Kotlin 2.3.0, Android API 36, Build Tools 36.0.0, and ARM64 targeting.
- Added lockfile mutation protection around `flutter pub get`.
- Removed automatic CI `flutter pub cache repair`.
- Added structured environment diagnostics and a stricter build preflight.
- Added `scripts/apk_verify.sh` for package/version/ABI/manifest/resources/signing/size/SHA256 validation.
- Added `scripts/signing_guard.sh` for release signing prerequisites.
- Added build provenance output with app/toolchain/build/Git/APK metadata.
- Kept Termux-specific AAPT2 configuration isolated in `build_deutsch.sh` while using the same project source as CI/Linux.
- Added a `PreferencesService` adapter and a `SpeechResult` domain boundary; UI code no longer imports `shared_preferences`, `speech_to_text`, or `flutter_tts` directly. TTS remains isolated in the existing `SafeTtsController`.
- Added a static regression contract covering reproducibility and non-destructive build behavior.

## Safety

The installer and build scripts do not delete existing Flutter/SDK/NDK/Gradle/cache/project/APK/ZIP data. No `flutter clean` is part of the normal build path. Previous project versions are preserved.

## Toolchain decision

Flutter 3.44.9 bundles Dart 3.12.2. The Android Gradle Plugin 8.13 line supports Gradle 8.13 and API 36; its documented default NDK reference is 27.0.12077973. The project records that NDK reference without forcing installation when the current app does not declare an NDK requirement.

## Verification limitation in this environment

This source archive is the V177 snapshot plus V178 changes. The supplied V177 archive did not contain `pubspec.lock`, and the current execution environment does not have Flutter/Dart installed. Therefore a lockfile was deliberately **not fabricated**, and no APK/analyzer/Flutter-test success is claimed from this environment. The new guards will stop a real build until the checked-in lockfile is restored/generated deliberately with the pinned Flutter 3.44.9 toolchain and then committed.
