# V163 — Android Toolchain Hardening

## Goal
Keep the Android build toolchain aligned with Flutter 3.24.3 and prevent CI from rewriting repository build configuration.

## Changes
- Flutter CI remains pinned to 3.24.3.
- Dart SDK floor remains >=3.5.0 for flutter_lints 5 compatibility.
- Android Gradle Plugin is pinned to 8.7.3.
- Kotlin Android plugin is pinned to 1.9.24 to avoid depending on the newer Kotlin 2.1 toolchain.
- Gradle distribution remains pinned to 8.9 in the checked-in wrapper properties.
- CI no longer rewrites the Gradle wrapper on every run; it uses the repository configuration.
- `flutter pub cache repair` remains before `flutter pub get` as a recovery step for the reported package-cache/authentication failures.

## Verification
- Python regression suite: 86 passed.
- Security, quality, architecture and accessibility audits: PASS.
- Flutter/Dart compilation and Android APK build remain unverified in this environment because the Flutter SDK/network are unavailable.
- The checked-in Gradle wrapper JAR is still absent from the source snapshot; CI therefore must supply the wrapper runtime before invoking Gradle if the repository does not contain it. This is intentionally documented rather than falsely marked as solved.
