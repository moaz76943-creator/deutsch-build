# Android build and delivery

Canonical source: `sali97m-cpu/deutsch-bilarabi`, branch `main`.
The Worker remains `sali97m-cpu/deutsch-bilarabi-worker`. Local compilation does
not need GitHub authentication after pulling source and does not dispatch Actions.

## One Termux release command

```bash
cd ~/deutsch-bilarabi && git switch main && git pull --ff-only origin main && ./scripts/termux_release.sh
```

Requires ARM64 Termux. The existing bootstrap installs the pinned toolchain when
Flutter/Java are absent; `--bootstrap` explicitly refreshes installation checks.
Java 17 and 21 are supported. Toolchain pins stay in `toolchain.lock`; Java/Kotlin
bytecode target 17 remains compatible with either JDK.

The lightweight release path is environment preflight → locked Pub resolution →
zero blocking Dart errors in `lib/` → production signing → ARM64 release → APK
verification → SHA256 → Downloads copy. Warnings/info do not fail the Dart gate;
analyzer crashes and unrecognized failures do. Tests requiring Flutter/FFI execution
on Android are not part of this path. Generated runtime content is reused, or
materialized if absent. No application ID, production database or SRS behavior changes.

Outputs:

- `build/app/outputs/flutter-apk/app-release.apk`
- `build/local-release-info.txt` with source commit, version and SHA256
- `build/symbols/` for the obfuscated release; retain alongside that APK
- `/sdcard/Download/deutsch-bilarabi-release.apk` when writable, otherwise
  `~/storage/downloads/deutsch-bilarabi-release.apk` when writable

The copy is byte-verified. If shared storage is unavailable or a copy fails, the
verified APK remains in the build directory. Run `termux-setup-storage` once if
Downloads permission is needed; the script does not change Android permissions.

## One-time signing setup

```bash
./scripts/setup_local_signing.sh
```

Reuses `$HOME/.gradle/release-key.jks`. If credentials are missing, prompts are
hidden, including alias input. If the key is missing, provide the Base64 of the
**existing production JKS**, never a new identity. Existing usable configuration
is verified without rewriting it; unusable stored credentials can be re-entered.

The bootstrap validates both passwords and the private-key alias via a certificate
request, without altering the key. It creates/updates only these canonical values
in `$GRADLE_USER_HOME/gradle.properties` (default `~/.gradle/gradle.properties`):

- `releaseStoreFile`
- `releaseStorePassword`
- `releaseKeyAlias`
- `releaseKeyPassword`

No passwords/alias defaults are embedded in Git. Unrelated properties and comments
are preserved; signing files use `umask 077` and permissions `0600`. Validations
finish before properties are published. A nonexistent historical runner path can
be repaired to the existing default key. Explicit paths are respected. A different
Base64 payload never replaces an existing destination key.

For unattended setup, securely supply `RELEASE_STORE_PASSWORD`,
`RELEASE_KEY_ALIAS`, `RELEASE_KEY_PASSWORD`, optionally `RELEASE_KEYSTORE_PATH`,
and either `RELEASE_KEYSTORE_BASE64` or `RELEASE_KEYSTORE_BASE64_FILE`, then run
`./scripts/setup_local_signing.sh --non-interactive`. Do not put secrets in command
history or tracked files. Canonical `ORG_GRADLE_PROJECT_release*` variables also
work and take precedence. During explicit setup, `RELEASE_*` values repair stale
profile entries; normal builds retain Gradle's priority order.

The app's existing `secureRelease` block uses the shared signing resolver. Priority:
CLI `-P` → canonical environment → Gradle properties → `RELEASE_*` environment →
private `android/key.properties` → existing local key path only. Relative paths
retain Android app-directory semantics; `~/` expands. A release never falls back to
debug signing. The verifier compares the APK signer certificate to the configured
production certificate, as well as checking package, version, ABI, size, manifest
and resources. Production preserves its existing no-INTERNET/no-POST_NOTIFICATIONS
artifact policy; a release overlay excludes a transitive plugin permission. Debug
can retain its development permissions.

Once Flutter dependencies, SDK and native Termux AAPT2 are prepared, the persisted
signing properties also support `cd android && ./gradlew assembleRelease`. On Termux,
the dedicated entrypoint supplies the AAPT2/resource overrides for you; direct Gradle
requires equivalent local overrides.

GitHub Secrets cannot be read back after installation. Keep a private backup of
production signing material. Older commits contained password defaults; deleting
current defaults cannot erase immutable Git history. Rotate exposed passwords on
the owner's JKS **without replacing its signing key**, and update local/GitHub
configuration. This task does not rewrite history or access the production key.

## Storage and phone resources

The shared policy checks source and home filesystems. Former 8 GiB hard requirement
is replaced with:

- below 1 GiB (`1048576 KiB`): fail with actionable diagnostic
- 1 GiB up to 3 GiB (`3145728 KiB`): warn and continue
- at least 3 GiB: pass

These are conservative preflight thresholds, not guarantees for a first installation.
Fresh downloads and APK compilation still require actual available space; caches
are never automatically deleted to make the check pass.

Termux-only process options: one Gradle worker, no parallel projects, caching on,
no persistent daemon, 1024 MiB heap, 384 MiB metaspace, Kotlin compiler in-process,
and native ARM64 AAPT2. `LOCAL_BUILD_WORKERS` / `LOCAL_BUILD_JVMARGS` are deliberate
owner overrides. Desktop/cloud retain repository Gradle defaults. These phone
settings are not written into user Gradle properties. Incremental outputs, Gradle,
Pub and Flutter artifact caches are preserved; no automatic `flutter clean`.
Flutter 3.44 injects an empty CMake project to obtain host NDK stripping tools.
On Termux, the app clears only this verified empty placeholder, keeps prebuilt JNI
payloads, and generates stripped Dart AOT directly (`--strip`), avoiding incompatible
Google Linux host CMake/NDK execution. Actual native CMake source builds fail with
an explicit host-toolchain diagnostic. Linux/cloud still use the locked NDK; app
Build Tools and NDK versions are read from `toolchain.lock`. R8/Dart obfuscation
and separate debug symbols remain enabled.

Machine paths and Flutter's generated plugin metadata/registrant stay untracked
and are regenerated normally by `flutter pub get`.

## Development and full validation

`build_deutsch.sh` uses the lightweight debug path on Termux, without release
credentials. Its capable-host validation behavior is preserved.
`termux_first_build.sh` retains the pinned bootstrap and debug-development path.

`bash scripts/local_quality_gate.sh` remains the broader engineering pipeline,
including content/security/audit tests. `bash scripts/local-release.sh --verify`
opts into that full gate before the release. `--setup-only` prepares signing without
Flutter downloads; `--debug` uses the lightweight host-neutral debug path.

## Worker cloud control plane

`bash scripts/export_build_worker.sh` exports canonical source without force-push,
checks enable/secrets configuration, and dispatches the manual Worker workflow at
most once. It prints source SHA, Worker repository and run URL/status when visible.
An existing active run for the same SHA is reused. Failed export/ref inspection
stops safely. Observation is bounded (default four checks, five-second intervals);
an accepted/queued dispatch is not reported as a completed APK. No infinite poll or
retry, and an ambiguous dispatch failure is never automatically redispatched.

When run annotations identify quota/billing rejection, the script distinguishes
successful source export from unavailable cloud compute and prints the Termux
fallback. A runner rejected before starting cannot execute its Telegram failure
step; the exporter supplies the local diagnostic. Other build failures retain their
run URL. No paid service or billing bypass is introduced.

The Worker stays dispatch-only with `cancel-in-progress: true`, pinned Actions,
secret-backed temporary signing, locked dependencies, Dart/content checks, complete
APK verification, checksum sidecar, short-lived artifacts and stable `worker-latest`
publication. Success/failure Telegram messages contain only source SHA and artifact
or run URL, never raw build logs. Signing passwords are step environment values;
the temporary key is removed in an always-run cleanup and credentials are not
persisted into cached user Gradle properties.

Hosted quota available: use the existing Worker. Quota exhausted: use Termux.
Zero additional billing cannot make GitHub allocate unavailable hosted compute.
This repair does not dispatch a hosted build or change billing/provider dependencies.
The live Worker receives the repaired source/workflow on the **next intentional
export**, not via a build launched by this task.

For a future trusted Linux x64 self-hosted Worker, install the Android SDK and its
licenses, Flutter prerequisites, Python and `gh`, then set Worker repository variable
`BUILD_WORKER_RUNNER_LABELS` to `["self-hosted","linux","x64","android-build"]`.
No redesign: signing, publishing and Telegram use the same workflow and secrets.
The explicit runner-label option disables hosted Gradle cache transfer in favor of
that machine's persistent cache. The separate `local_release.yml` self-hosted-only
workflow remains gated by `LOCAL_RELEASE_RUNNER_ENABLED=true` and keeps output
on its runner. Never execute untrusted PR code on a runner holding production keys.

## Verification scope

Regression tests use disposable real JKS material and real Gradle resolver/resource
fixtures on Java 21, plus subprocess doubles for dispatch outcomes and disk/analyzer
boundaries. They never generate, replace or publish the owner's signing identity.
Dart analysis runs on actual pinned Flutter/Dart. Workflow YAML and every shell
block are checked locally. Phone-native execution, production-key access, live
Telegram delivery and hosted execution require the owner's environments; local
validation alone does not claim those external operations succeeded.

The legacy security audit previously referenced retired `build-apk.yml` and
`quality.yml` files. It now validates the active Worker and manual quality workflows:
private repository/main release boundary, explicit enable gate, minimal publication
permissions, credential-free checkout, isolated quality caches, wrapper integrity,
and bounded artifacts. Existing application security checks remain enforced.

The pinned native Termux Flutter package endpoint currently returns HTTP 404. An
existing matching Termux SDK is reused. Fresh installation can use a trusted local
package via `TERMUX_FLUTTER_DEB_PATH` and its independently verified
`TERMUX_FLUTTER_DEB_SHA256`; checksum mismatch/missing checksum stops before
installation. No different vendor, version downgrade, or Linux/glibc binary is
substituted silently. Fully unattended fresh-device installation still needs a
reachable authenticated source for the pinned native host package.

Local verification also exercised a full incremental release with one worker, a
1024 MiB Gradle heap and in-process Kotlin: the 24.6 MB ARM64 APK passed signature,
configured certificate, permissions, native ELF/no-DWARF and byte-verified copy
checks. This used a disposable test JKS on Linux, never the production identity.
113 targeted/canonical Python tests, including the real Gradle fixtures, passed;
42 delivery tests passed again after the final native-tool PATH repair.
Actual Android Gradle configuration confirmed the Termux packaging policy; this
is configuration evidence on Linux, not execution on an Android phone.
The debug pipeline also built and verified an ARM64 APK with release credentials
removed. The owner's installed Flutter 3.44.9 stable matches the pin and is reused.
Termux keeps the selected Java/Flutter/Dart first in PATH, then native packaging
tools before Linux SDK executables. The AAPT2 override additionally checks ELF
architecture, rejecting an accidentally selected x86 binary before Gradle runs.
