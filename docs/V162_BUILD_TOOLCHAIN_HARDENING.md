# V162 — Flutter / Gradle Build Toolchain Hardening

## Goal

Make the Android build toolchain deterministic instead of depending on whatever
Flutter/Gradle versions happen to be installed by a runner or local environment.

## Pinned contract

- Flutter: 3.24.3
- Dart: 3.5.x minimum enforced by `pubspec.yaml`
- Gradle: 8.9
- Android Gradle Plugin: 8.7.3
- Kotlin: 2.1.0
- Android compile/target SDK: 35
- Java: 17

## Changes

- `pubspec.yaml` now requires Dart `>=3.5.0` so `flutter_lints: ^5.0.0` cannot
  be resolved with an older Dart SDK.
- Both GitHub Actions workflows pin Flutter to 3.24.3.
- Both workflows install Gradle 8.9 and materialize the Gradle wrapper before
  package/build steps, preventing a missing/old wrapper from silently returning.
- Both workflows run `flutter pub cache repair` before `flutter pub get`.
  A real pub.dev/network/authentication failure remains a visible build failure;
  cache repair is not treated as a substitute for network availability.
- The repository now contains a pinned `android/gradle/wrapper/gradle-wrapper.properties`
  and wrapper launcher scripts.

## Verification

The local environment does not provide Flutter/Android SDKs, so a real APK build
cannot be claimed here. Static regression, security, quality, architecture,
and accessibility gates are run locally. CI remains the authoritative Flutter
and Android compilation check.
