# Local signed release recovery

Task: `local-release-recovery-20261006`. Owner: Codex, explicitly authorized by
the repository owner to deliver on `main`. Scope: signing, local build setup,
space/Java preflight and release documentation. Canonical source inspected:
`f83e35b63a71cfcc4c049d5650f9ff9162c6f191`. Open PRs were inspected before mutation;
the Play Store automation PR changes Fastlane/workflow files rather than this scope.
The generated project record has stale historical lineage; this task does not
rewrite that history or claim unrelated Flutter/CI work is verified.

## Existing Termux installation

```bash
cd ~/deutsch-bilarabi && git switch main && git pull --ff-only origin main && bash scripts/local-release.sh
```

The default keystore is `$HOME/.gradle/release-key.jks`, which is
`/data/data/com.termux/files/home/.gradle/release-key.jks` on standard Termux.
The owner-specified local defaults are alias `release` and store/key password
`deutsch2026`. No key is generated and no existing signing identity is replaced.

The script:

1. Reuses the existing toolchain, or installs it if Flutter/Java are absent in Termux.
2. Validates the private key, alias and both passwords using `keytool`.
3. Atomically updates only signing/settings entries in private user Gradle properties,
   preserving unrelated values and avoiding duplicate keys. Files use permissions `0600`.
4. Repairs a nonexistent old worker keystore path when the local default key exists,
   unless the caller explicitly supplies a different path.
5. Sets local Flutter/SDK paths and native ARM64 AAPT2; reuses generated runtime content
   and materializes it in checkouts where it is absent.
6. Resolves pinned dependencies, preserving `pubspec.lock` and existing caches.
7. Builds an obfuscated ARM64 release with R8/resource shrinking and verifies its
   package/version/ABI, manifest and APK signature.

APK: `build/app/outputs/flutter-apk/app-release.apk`.
Provenance/checksum: `build/local-release-info.txt`.
Dart symbols: `build/symbols/`; preserve them with the corresponding release.
If Termux shared downloads are already writable, the script also copies the APK to
`~/storage/downloads/deutsch-bilarabi-release.apk`.

Java 21 can run the pinned Gradle 8.14.5 toolchain. Java/Kotlin bytecode target 17
and the default cloud Java 17 pin remain valid. Installer and build preflight accept
both JDKs. No `df` probe or free-space threshold runs; actual write/download failures
still report their real exit status.

## Other entrypoints

```bash
bash scripts/local-release.sh --bootstrap  # refresh/install the Termux toolchain
bash scripts/local-release.sh --verify     # also run the existing canonical quality gate
bash scripts/local-release.sh --setup-only # signing only, no Flutter download or build
```

`--verify` requires pytest and the existing quality-gate dependencies. Normal local
builds compile and verify the artifact; they do not claim to have run the full test suite.
Historical lexical checks remain available through `RUN_LEGACY_TEXT_REGRESSIONS=1`;
the local release command uses the current build contract.

Once dependencies and generated content have been prepared, direct Gradle works:

```bash
cd android && ./gradlew assembleRelease
```

The app now resolves signing from CLI `-P` overrides, exported
`ORG_GRADLE_PROJECT_release*` values, Gradle properties, `RELEASE_*` environment
values, `android/key.properties`, then the existing default local keystore.
Relative signing paths retain Android app-directory semantics; `~/` paths expand.
CLI settings remain highest priority. The setup script exports its validated values
so an old user-property path cannot override them in the same build.

For a different key, supply `RELEASE_KEYSTORE_PATH`, `RELEASE_STORE_PASSWORD`,
`RELEASE_KEY_ALIAS` and `RELEASE_KEY_PASSWORD` (or canonical Gradle variables).
Cloud environments keep their explicit secret-backed signing configuration.

## Base64 import on a new device

Either provide `RELEASE_KEYSTORE_BASE64` in the environment, or a private local file:

```bash
RELEASE_KEYSTORE_BASE64_FILE="$HOME/release-key.b64" bash scripts/local-release.sh
```

Wrapped Base64 is accepted. Decoding occurs in a private temporary file; keytool
validates it before publication. Invalid input, wrong passwords, and a key different
from an existing destination fail without replacing the keystore. GitHub Secrets
cannot be read back through `gh`; retain a separate private backup for device recovery.
Never commit the key or its encoded backup. No GitHub authentication is needed for
local compilation once the source has been pulled.

## Zero-cost execution and caching

Moving a private repository to another worker repository under the same account
does not replenish hosted Actions minutes or resolve billing rejection. The reliable
fallback is this local command; it neither dispatches workflows nor provisions paid
services. Existing cloud workflows remain available for a later migration.

Builds preserve Gradle dependency/task caches, the Flutter/pub cache, `.dart_tool`,
and incremental Android outputs. There is no automatic clean or cache repair.
Default Gradle settings use one worker, no parallel projects, build caching enabled,
and a 1536 MiB heap without a persistent daemon. Override `LOCAL_BUILD_WORKERS`
or `LOCAL_BUILD_JVMARGS` only when device resources allow. For less memory:

```bash
LOCAL_BUILD_JVMARGS='-Xmx1024m -XX:MaxMetaspaceSize=384m -Dfile.encoding=UTF-8' bash scripts/local-release.sh
```

For unattended CI, a trusted existing Linux machine can run the same command as
a self-hosted runner with Flutter/Android SDK installed. The optional
`local_release.yml` workflow is manual, canonical-main-only, and gated by
`LOCAL_RELEASE_RUNNER_ENABLED=true`; its runner must have labels
`self-hosted`, `linux`, `android-build`. It requests no hosted runner and uploads
no billable artifact. The output stays on that runner; configure distribution
separately if needed. It must not execute untrusted PR code or use a paid hosted
runner as an automatic fallback.

## Verification evidence and limits

Behavioral tests exercise an existing real disposable JKS, wrapped Base64 import,
invalid input, wrong private-key password, identity preservation, stale worker paths,
escaped properties, Java 21 and absence of any disk probe. An isolated Gradle fixture
executes the same app signing resolver on Java 21. Production keys are never used.

Full device compilation still depends on the pinned Flutter host package, installed
Android API/build tools, native AAPT2, network/dependency availability and actual device
resources. A successful setup or fixture is not evidence that a production APK was built.

Verified in this session:

- 27 targeted tests passed, including five real Gradle 8.14.5 resolver cases on Java 21.
- 23 additional active quality/Termux contracts passed.
- The canonical local quality gate passed with `SKIP_FLUTTER_CHECK=1` (45 passed,
  3 optional Gradle cases skipped before the two extra fixtures were added).
- Wrapper JAR/distribution checksum pins, maintained Bash syntax and the
  self-hosted-only workflow configuration passed validation.
- Two pre-existing historical Phase 17 tests fail because a former test-support
  mock is absent and `lib/main.dart` exceeds the historical 1000-line limit.
  Neither file was changed; the canonical quality gate treats historical checks as opt-in.
- Flutter analyzer/tests and a complete APK build were not executed: Flutter and
  Android SDK are absent on the executor. Run the owner-device command above for
  production artifact verification. Production signing credentials were not accessed.
