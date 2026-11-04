#!/usr/bin/env bash
# Local signed ARM64 release; no hosted runners, worker repository or billing.
set +x
set -Eeuo pipefail
IFS=$'\n\t'
umask 077
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT/scripts/common.sh"
load_toolchain
source "$ROOT/scripts/release-signing.sh"

SETUP_ONLY=false
VERIFY=false
BOOTSTRAP=false
MODE=release
for argument in "$@"; do
  case "$argument" in
    --setup-only) SETUP_ONLY=true ;;
    --verify) VERIFY=true ;;
    --bootstrap) BOOTSTRAP=true ;;
    --debug) MODE=debug ;;
    --help)
      printf 'Usage: bash scripts/local-release.sh [--setup-only] [--verify] [--bootstrap] [--debug]\n'
      printf 'Reuses ~/.gradle/release-key.jks or decodes RELEASE_KEYSTORE_BASE64[_FILE].\n'
      exit 0 ;;
    *) fatal "Unknown option: $argument" ;;
  esac
done

cd "$ROOT"
case "${DEUTSCH_JSON_CONTENT:-false}" in
  true|false) ;;
  *) fatal "DEUTSCH_JSON_CONTENT must be true or false" ;;
esac
if [[ "$SETUP_ONLY" == false ]]; then
case "${PREFIX:-}" in
  /data/data/*/files/usr)
    # Source the existing bootstrap functions without invoking its debug-build main.
    source "$ROOT/termux_first_build.sh"
    if [[ "$BOOTSTRAP" == true ]] || ! command -v flutter >/dev/null 2>&1 || ! command -v java >/dev/null 2>&1 || ! command -v javac >/dev/null 2>&1; then
      bash "$ROOT/install_flutter.sh"
    fi
    if [[ -z "${FLUTTER_ROOT:-}" ]] && command -v flutter >/dev/null 2>&1; then
      FLUTTER_ROOT="$(cd "$(dirname "$(readlink -f "$(command -v flutter)")")/.." && pwd)"
    fi
    hydrate_environment ;;
  *) [[ "$BOOTSTRAP" == false ]] || fatal "--bootstrap installs Termux tools only; configure Flutter and Android SDK on this host." ;;
esac
fi

command -v python3 >/dev/null 2>&1 || fatal "python3 is required"
command -v java >/dev/null 2>&1 || fatal "Java 17 or 21 is required"
if [[ -z "${JAVA_HOME:-}" ]]; then
  export JAVA_HOME="$(dirname "$(dirname "$(readlink -f "$(command -v java)")")")"
fi
export PATH="$JAVA_HOME/bin:$PATH"

if [[ "$MODE" == release || "$SETUP_ONLY" == true ]]; then
  log CHECK "Validate local release signing"
  prepare_release_signing --interactive || fatal "Run scripts/setup_local_signing.sh once to configure the existing production key"
fi
if [[ "$SETUP_ONLY" == true ]]; then
  log OK "Signing configured; run cd android && ./gradlew assembleRelease in a prepared Flutter checkout"
  exit 0
fi

command -v flutter >/dev/null 2>&1 || fatal "Flutter is required; on Termux use --bootstrap"
FLUTTER_ROOT="${FLUTTER_ROOT:-$(cd "$(dirname "$(readlink -f "$(command -v flutter)")")/.." && pwd)}"
export ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-${ANDROID_HOME:-}}"
if [[ -z "$ANDROID_SDK_ROOT" ]]; then
  for candidate in "$HOME/Android/Sdk" "$HOME/Android/sdk" "$HOME/android-sdk"; do
    if [[ -d "$candidate" ]]; then ANDROID_SDK_ROOT="$candidate"; break; fi
  done
fi
[[ -d "$ANDROID_SDK_ROOT" ]] || fatal "Set ANDROID_SDK_ROOT to an installed Android SDK"
export ANDROID_HOME="$ANDROID_SDK_ROOT"
if is_termux && [[ ! -x "$PREFIX/bin/aapt" || ! -x "$PREFIX/bin/aapt2" ]]; then
  log CHECK "Install native Termux packaging tools"
  pkg install -y aapt || fatal "Could not install the native Termux aapt package"
fi
configure_android_build_path
build_exports="$(python3 "$ROOT/tool/local_build_environment.py" "$FLUTTER_ROOT" "$ANDROID_SDK_ROOT")"
eval "$build_exports"
bash "$ROOT/scripts/build_guard.sh"
(cd "$ROOT/android" && ./gradlew --version)

snapshot_lockfile
with_retry flutter pub get --enforce-lockfile || fatal --code "$ERR_DEP" "Failed to get dependencies"
assert_lockfile_unchanged
# Reuse tracked generated content; materialize it only in checkouts where it is absent.
if [[ ! -f "$ROOT/lib/data/generated/content_items_generated.dart" || ! -f "$ROOT/lib/data/generated/verb_conjugations_generated.dart" ]]; then
  python3 "$ROOT/tool/content_compiler.py" compile --output-dir "$ROOT/lib/data/generated"
fi
if [[ "$MODE" == "release" || "$VERIFY" == true ]]; then
  log CHECK "Mandatory local quality gate before release"
  bash "$ROOT/scripts/local_quality_gate.sh"
fi
bash "$ROOT/scripts/check-dart-errors.sh"
if [[ "$MODE" == release ]]; then bash "$ROOT/scripts/signing_guard.sh"; fi

mkdir -p "$ROOT/build/symbols"
log BUILD "ARM64 $MODE (incremental build and Gradle/pub caches preserved)"
build_options=()
if [[ "$MODE" == release ]]; then
  # Flutter 3.44 delegates Android stripping to a host NDK by default. Generate
  # a stripped AOT snapshot directly so native Termux packaging exposes no DWARF.
  build_options=(--obfuscate "--split-debug-info=$ROOT/build/symbols" --extra-gen-snapshot-options=--strip)
fi
flutter build apk "--$MODE" --no-pub \
  --target-platform android-arm64 \
  --dart-define="DEUTSCH_JSON_CONTENT=${DEUTSCH_JSON_CONTENT:-false}" \
  "${build_options[@]}" || fatal --code "$ERR_COMP" "Flutter build failed"
assert_lockfile_unchanged

APK="$ROOT/build/app/outputs/flutter-apk/app-${MODE}.apk"
bash "$ROOT/scripts/apk_verify.sh" "$APK" "$MODE"
{
  printf 'Git Commit: %s\n' "$(git_commit)"
  printf 'Version: %s+%s\n' "$(app_version)" "$(app_build_number)"
  printf 'APK: %s\n' "$APK"
  sha256sum "$APK"
} > "$ROOT/build/local-${MODE}-info.txt"
for downloads in "${DOWNLOAD_DIR:-/sdcard/Download}" "$HOME/storage/downloads"; do
  if [[ -d "$downloads" && -w "$downloads" ]]; then
    destination="$downloads/deutsch-bilarabi-${MODE}.apk"
    if cp "$APK" "$destination" && cmp -s "$APK" "$destination"; then
      log OK "Downloads: $destination"
    else
      log WARN "Could not copy to Downloads; verified APK remains at $APK"
    fi
    break
  fi
done
log OK "$MODE APK verified: $APK"
cat "$ROOT/build/local-${MODE}-info.txt"
