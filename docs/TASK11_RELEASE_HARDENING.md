# TASK 11 — End-to-End Release Hardening & Offline Verification

Baseline: `main@007fbc8e8e06d5c5fdc3af92fbbc806e57997167`

Scope: release/offline/schema integrity only. No production Dart feature logic is changed.

## Locked boundaries

- Android main manifest allows exactly `RECORD_AUDIO`; network permissions remain absent, cleartext traffic remains disabled, and application backup remains disabled.
- The release overlay must explicitly remove `POST_NOTIFICATIONS`.
- Production entrypoint/bootstrap/runtime may not introduce HTTP/WebSocket/browser-network imports or direct `HttpClient`, `Socket`, `WebSocket`, or `Uri.http(s)` calls.
- Learner-state SQLite schema remains pinned at v1 and gamification SQLite at v4. Existing schema verification, migration-chain markers, foreign-key enforcement, and integrity fingerprints are release contracts.
- Release builds execute the canonical local quality gate unconditionally before analyzer/signing/build.
- Merged release APK verification rejects network/notification permissions, pins ARM64 ABI, and verifies package/version, ELF shape, signing identity, size, and SHA-256.
- Content compilation/parity, pack validation, licensed-media verification, Gradle wrapper integrity, and Dart blocking-error checks remain part of the canonical local gate.
- Task surfaces remain bounded to at most 1000 lines.

## Fail-closed behavior

`tool/task11_release_hardening.py check` exits non-zero on permission drift, network reachability introduced at the production boundary, schema-version drift, missing schema-integrity markers, weakened release gates, or file-ceiling violations.

## Evidence boundary

Source hardening is not equivalent to a verified store artifact. The signed release binary must still be built and verified on the exact release commit before the artifact itself is classified as verified.
