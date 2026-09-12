# V168 — Gradle Wrapper Stability Hardening

## Root cause
The Android project pins Gradle 8.9 and has checked-in wrapper scripts/properties, but the generated `gradle-wrapper.jar` is not present in the source snapshot. Flutter invokes the Android wrapper during `flutter build`, so a missing wrapper runtime can stop the build before Android compilation.

## Fix
CI now bootstraps the official Gradle 8.9 wrapper runtime only when the JAR is absent. Before running the Gradle wrapper task, CI saves the checked-in wrapper scripts and properties; after generation it restores those files, retaining only the generated wrapper JAR. CI then verifies the JAR is non-empty and the distribution URL remains pinned to Gradle 8.9.

This avoids transient drift of the checked-in wrapper configuration while still making the build executable from a source snapshot that lacks the generated JAR.

## Verification
Static V168 wrapper-stability test passes. The full Python regression suite was run in two bounded batches because the first all-tests process exceeded the environment timeout; every test in both batches passed. Security, quality, architecture, accessibility, and weakness audits all passed.

Actual Flutter/Gradle APK execution remains environment-unverified because this worker does not provide the Flutter/Android SDK toolchain or outbound package access.
