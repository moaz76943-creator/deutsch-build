# V166 Gradle Wrapper Build Hardening

V166 closes the remaining Android build-root gap identified after the Gradle/AGP alignment work.

## Contract

- Gradle is pinned to **8.9** in `gradle-wrapper.properties` and CI.
- Android Gradle Plugin is pinned to **8.7.3**.
- Kotlin is pinned to **1.9.24** for the Flutter 3.24.3 toolchain.
- `android/app/build.gradle` declares namespace `com.deutschbilarabi.app`.
- `compileSdk` and `targetSdk` are explicitly **34**.
- CI uses Java 17 and Flutter 3.24.3.
- CI materializes the official Gradle wrapper runtime with the pinned Gradle 8.9 command when the generated `gradle-wrapper.jar` is absent, then verifies the JAR and pinned distribution URL before Flutter runs.

## Verification boundary

The local environment does not contain Flutter/Android SDK tooling and cannot reach the external package/distribution hosts, so an APK build cannot be honestly claimed from this environment. The CI workflow now contains the missing wrapper bootstrap and an explicit fail-fast check so the real build environment can execute `flutter build apk --release` with the pinned toolchain.
