#!/usr/bin/env bash
# Local signed ARM64 release; no hosted runners, worker repository or billing.
set +x
set -Eeuo pipefail
IFS=$'\n\t'
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT/scripts/common.sh"
load_toolchain
source "$ROOT/scripts/release-signing.sh"

SETUP_ONLY=false
VERIFY=false
BOOTSTRAP=false
for argument in "$@"; do
  case "$argument" in
    --setup-only) SETUP_ONLY=true ;;
    --verify) VERIFY=true ;;
    --bootstrap) BOOTSTRAP=true ;;
    --help)
      printf 'Usage: bash scripts/local-release.sh [--setup-only] [--verify] [--bootstrap]\n'
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
    if [[ "$BOOTSTRAP" == true ]] || ! command -v flutter >/dev/null 2>&1 || ! command -v java >/dev/null 2>&1; then
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

log CHECK "Validate and persist release signing"
prepare_release_signing || fatal "Local release signing could not be prepared"
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
export PATH="$ANDROID_SDK_ROOT/build-tools/$ANDROID_BUILD_TOOLS_VERSION:$ANDROID_SDK_ROOT/platform-tools:$PATH"
python3 "$ROOT/tool/local_build_environment.py" "$FLUTTER_ROOT" "$ANDROID_SDK_ROOT"
bash "$ROOT/scripts/build_guard.sh"

snapshot_lockfile
flutter pub get --enforce-lockfile
assert_lockfile_unchanged
# Reuse tracked generated content; materialize it only in checkouts where it is absent.
if [[ ! -f "$ROOT/lib/data/generated/content_items_generated.dart" || ! -f "$ROOT/lib/data/generated/verb_conjugations_generated.dart" ]]; then
  python3 "$ROOT/tool/content_compiler.py" compile --output-dir "$ROOT/lib/data/generated"
fi
if [[ "$VERIFY" == true ]]; then
  bash "$ROOT/scripts/local_quality_gate.sh"
fi
bash "$ROOT/scripts/signing_guard.sh"

mkdir -p "$ROOT/build/symbols"
log BUILD "Signed ARM64 release (incremental build and Gradle/pub caches preserved)"
flutter build apk --release --no-pub \
  --target-platform android-arm64 \
  --dart-define="DEUTSCH_JSON_CONTENT=${DEUTSCH_JSON_CONTENT:-false}" \
  --obfuscate --split-debug-info="$ROOT/build/symbols"
assert_lockfile_unchanged

APK="$ROOT/build/app/outputs/flutter-apk/app-release.apk"
bash "$ROOT/scripts/apk_verify.sh" "$APK" release
{
  printf 'Git Commit: %s\n' "$(git_commit)"
  printf 'Version: %s+%s\n' "$(app_version)" "$(app_build_number)"
  printf 'APK: %s\n' "$APK"
  sha256sum "$APK"
} > "$ROOT/build/local-release-info.txt"
if [[ -d "$HOME/storage/downloads" && -w "$HOME/storage/downloads" ]]; then
  cp "$APK" "$HOME/storage/downloads/deutsch-bilarabi-release.apk"
fi
log OK "Signed release verified: $APK"
cat "$ROOT/build/local-release-info.txt"
