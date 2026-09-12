#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$ROOT/toolchain.lock"
PROJECT_ROOT="${PROJECT_ROOT:-$ROOT}"
LOG_FILE="${LOG_FILE:-$HOME/flutter_build_deutsch.log}"
APK="$PROJECT_ROOT/build/app/outputs/flutter-apk/app-debug.apk"

on_error() {
  local line="$1" command="$2" code="$3"
  printf '\nERROR: build stopped at line %s (exit %s)\nCommand: %s\nLog: %s\n' "$line" "$code" "$command" "$LOG_FILE" >&2
}
trap 'on_error "${LINENO}" "${BASH_COMMAND}" "$?"' ERR

log() { printf '[%s] %s\n' "$(date '+%H:%M:%S')" "$*"; }
fatal() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

main() {
  exec > >(tee -a "$LOG_FILE") 2>&1
  log 'Checking Flutter build environment'
  command -v flutter >/dev/null 2>&1 || fatal 'flutter is not installed/on PATH. Run install_flutter.sh first.'
  command -v dart >/dev/null 2>&1 || fatal 'dart is not installed/on PATH.'
  command -v java >/dev/null 2>&1 || fatal 'java is not installed/on PATH.'
  [[ -d "$PROJECT_ROOT" ]] || fatal "Project directory does not exist: $PROJECT_ROOT"
  cd "$PROJECT_ROOT"
  [[ -x "$PROJECT_ROOT/android/gradlew" ]] || fatal "Gradle Wrapper is missing or not executable: $PROJECT_ROOT/android/gradlew"
  chmod +x "$PROJECT_ROOT/android/gradlew"
  (cd "$PROJECT_ROOT/android" && ./gradlew --version)

  if [[ "$(uname -m)" == "aarch64" ]] && command -v aapt2 >/dev/null 2>&1; then
    mkdir -p "$HOME/.gradle"
    local gp="$HOME/.gradle/gradle.properties"
    if [[ -f "$gp" ]] && grep -Fq 'android.aapt2FromMavenOverride=' "$gp"; then
      log "Existing ARM64 aapt2 override preserved in $gp"
    else
      mkdir -p "$(dirname "$gp")"
      printf 'android.aapt2FromMavenOverride=%s\n' "$(command -v aapt2)" >> "$gp"
      log "Added native ARM64 aapt2 override to $gp without replacing existing content"
    fi
  elif [[ "$(uname -m)" == "aarch64" ]]; then
    fatal 'ARM64 build requires a native aapt2 binary. Install the Termux aapt2 package before building.'
  fi

  "$ROOT/scripts/build.sh" debug
}

main "$@"
