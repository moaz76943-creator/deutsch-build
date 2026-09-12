# V177 Build System

V177 formalizes the build workflow without changing application code or deleting
existing toolchains, caches, project files, APKs, ZIPs, or SDK components.

Commands:
- `./scripts/doctor.sh` — diagnose environment only.
- `./scripts/test.sh` — pub get, analyze, Flutter tests, and static regression tests.
- `./scripts/build.sh debug` — guarded ARM64 debug APK build.
- `./scripts/build.sh release` — guarded ARM64 release APK build.

The scripts are non-destructive: they do not remove or downgrade an existing
Flutter/Java/Android/Gradle installation and do not modify `lib/`, `android/`,
`assets/`, `data/`, `docs/`, `pubspec.yaml`, or `pubspec.lock`.
