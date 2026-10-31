# V173 Termux / Android toolchain hardening

V173 replaces the old host bootstrap with a Termux-safe, resumable environment installer.

- Flutter target: 3.44.9 (configurable via `FLUTTER_VERSION`, the canonical value in `toolchain.lock`).
- Java target: OpenJDK 21.
- Android Gradle Plugin: 8.13.2.
- Gradle Wrapper: 8.13, with SHA-256 pin.
- compileSdk/targetSdk: 36.
- Android command-line tools: 15859902, with SHA-256 verification.
- No mandatory 7z dependency.
- No `sudo`, no destructive deletion of existing SDK/Flutter/Gradle installations.
- Large downloads use curl resume (`-C -`) and are integrity-checked.
- `install_flutter.sh` prepares the environment only.
- `build_deutsch.sh` separately runs `pub get`, analyze, tests, debug APK build, file check and SHA-256.
- ARM64 Termux requires a native `aapt2`; the build script fails clearly if it is absent rather than claiming a successful APK.

The Flutter version above is sourced from the repository `toolchain.lock`, and Flutter lists Linux ARM64 as a supported desktop host architecture. Android's AGP 8.13 documentation lists Gradle 8.13 and API level 36 compatibility.
