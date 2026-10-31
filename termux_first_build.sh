#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$ROOT/toolchain.lock"

log() { printf '[%s] %s\n' "$(date '+%H:%M:%S')" "$*"; }
fatal() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

require_termux() {
  case "${PREFIX:-}" in
    /data/data/*/files/usr) ;;
    *) fatal "This entrypoint must run inside Termux. PREFIX=${PREFIX:-<unset>}" ;;
  esac
}

discover_android_sdk() {
  if [[ -n "${ANDROID_SDK_ROOT:-}" && -d "$ANDROID_SDK_ROOT" ]]; then
    return
  fi
  if [[ -n "${ANDROID_HOME:-}" && -d "$ANDROID_HOME" ]]; then
    ANDROID_SDK_ROOT="$ANDROID_HOME"
    return
  fi

  local candidate
  for candidate in \
    "$HOME/Android/Sdk" \
    "$HOME/Android/sdk" \
    "$HOME/android-sdk" \
    "$PREFIX/opt/android-sdk" \
    "$PREFIX/share/android-sdk"
  do
    if [[ -d "$candidate/platform-tools" || -d "$candidate/platforms" || -d "$candidate/cmdline-tools" ]]; then
      ANDROID_SDK_ROOT="$candidate"
      return
    fi
  done

  fatal "Android SDK was not found after install_flutter.sh completed."
}

discover_java_home() {
  if [[ -n "${JAVA_HOME:-}" && -x "$JAVA_HOME/bin/java" ]]; then
    return
  fi

  local candidate=""
  if command -v java >/dev/null 2>&1; then
    candidate="$(dirname "$(dirname "$(readlink -f "$(command -v java)")")")"
  fi
  [[ -n "$candidate" && -x "$candidate/bin/java" ]] || fatal "A supported JDK was not found after bootstrap."
  JAVA_HOME="$candidate"
}

hydrate_environment() {
  FLUTTER_ROOT="${FLUTTER_ROOT:-$PREFIX/opt/flutter}"
  discover_android_sdk
  discover_java_home

  export FLUTTER_ROOT
  export JAVA_HOME
  export ANDROID_HOME="$ANDROID_SDK_ROOT"
  export ANDROID_SDK_ROOT="$ANDROID_SDK_ROOT"
  export PATH="$FLUTTER_ROOT/bin:$FLUTTER_ROOT/bin/cache/dart-sdk/bin:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$PATH"

  [[ -x "$FLUTTER_ROOT/bin/flutter" ]] || fatal "Flutter is not usable at $FLUTTER_ROOT."
  command -v dart >/dev/null 2>&1 || fatal "Dart is not available from the selected Flutter SDK."
  command -v java >/dev/null 2>&1 || fatal "Java is not available after environment hydration."
}

main() {
  require_termux

  log "Bootstrapping/reusing the pinned Flutter + Android toolchain"
  "$ROOT/install_flutter.sh"

  log "Rehydrating the installed environment in this shell"
  hydrate_environment

  log "Running repository environment doctor"
  "$ROOT/scripts/doctor.sh"

  log "Running the canonical debug build pipeline"
  "$ROOT/build_deutsch.sh"

  APK="$ROOT/build/app/outputs/flutter-apk/app-debug.apk"
  [[ -s "$APK" ]] || fatal "Canonical build finished without a non-empty debug APK at $APK."

  log "First local APK build verified"
  sha256sum "$APK"
  printf 'APK: %s\n' "$APK"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
