# V102 — Flutter / Android environment

Added a reproducible Flutter + Android build environment path.

- CI uses Java 17 (Temurin).
- CI installs the stable Flutter channel.
- Android compile/target SDK: 35.
- Local Linux bootstrap installs Flutter 3.35.7 and Android SDK command-line tools outside the repo.
- Local bootstrap runs doctor, pub get, analyze, tests, and release APK build.
- Android version is aligned with pubspec: 1.49.0+59.
