# V174 Termux Gap Closure

V174 continues directly from V173 and closes the remaining installer/build gaps identified in the Termux hardening review.

## Closed gaps

- Detect and reuse an existing Android SDK across common Termux/user paths.
- Reuse installed platform-tools, Android API platform, and build-tools; install only missing components.
- Enumerate sdkmanager state after component setup to verify the SDK is readable.
- Handle completed/resumable downloads without blindly restarting; explicitly account for HTTP 416 responses.
- Inspect Termux's main repository configuration before `pkg update`; if repository refresh fails, explain the mirror repair path without silently changing repositories.
- Keep NDK out of the baseline install; it is not installed unless the project later proves it necessary.
- Keep Gradle global installation out of the build path; the project Gradle Wrapper is checked and invoked before `flutter build apk`.
- Preserve all existing Flutter/SDK/Gradle data and never delete prior installations automatically.

## Verification

- Python test suite: 122/122 passed.
- Python compileall: passed.
- Shell syntax checks: passed.
- Security audit: passed.
- Quality audit: passed (14,793 entries, unique IDs and German entries).
- Architecture audit: passed.
- Accessibility audit: passed (0 warnings).
- Weakness gate: passed.

Actual Flutter/Gradle/APK execution remains an environment-level verification that must be performed on Termux/Android, because this development container does not provide that runtime.
