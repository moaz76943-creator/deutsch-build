# Deutsch بالعربي — Security Hardening V87

## Security model

This application is intentionally **private and offline-first**. It does not need
an internet permission, remote API, WebView, cloud database, or embedded API key.
The local learner state is treated as untrusted input because a rooted/modified
device can alter application storage.

## Release requirements

1. The GitHub repository must remain **private**.
2. Release APKs must be signed with a dedicated Android release keystore stored
   only in GitHub Actions Secrets/local secure storage.
3. Debug signing is forbidden for release builds.
4. R8/resource shrinking is enabled.
5. Flutter release builds use Dart obfuscation and private split-debug symbols.
6. Build artifacts are retained for only three days.
7. The CI security gate must pass before an APK is produced.

## Important limitation

No offline APK can be made mathematically impossible to reverse-engineer on a
compromised/rooted device. Obfuscation, signing, backup restrictions and local
state validation raise the cost and prevent common attack paths, but they do not
make client-side premium flags or local progress authoritative.

If real paid entitlements are added later, validation must happen through the
store/backend and no secret should ever be embedded in the APK.
