# Flutter / Android build environment

## Canonical build versions

- Flutter: **3.24.3**
- Dart SDK: **3.5.x** (enforced by `pubspec.yaml`)
- Gradle Wrapper: **8.9** (`android/gradle/wrapper/gradle-wrapper.properties`)
- Android Gradle Plugin: **8.7.3**
- Kotlin: **2.1.0**
- Android compile/target SDK: **35**
- Java: **17**

These versions are intentionally pinned so a push cannot silently switch the
CI build back to a different Flutter/Gradle toolchain.

## Automated CI

GitHub Actions installs Java 17 and Flutter 3.24.3, repairs the local Flutter
package cache, resolves packages, runs analysis/tests, and builds the signed
release APK.

## Package-cache recovery

CI runs `flutter pub cache repair` before `flutter pub get`. This can repair a
corrupt local cache, but it cannot fix a real network outage or pub.dev
authorization/service failure; those remain explicit build failures rather than
being silently ignored.

## Local Linux bootstrap

Run:

```bash
tool/bootstrap_flutter_android.sh
```

The local bootstrap should use the same Flutter/Gradle versions above. SDK
binaries remain outside the repository.
