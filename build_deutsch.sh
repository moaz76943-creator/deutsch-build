#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$ROOT/toolchain.lock"
source "$ROOT/scripts/common.sh"
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

configure_aapt2_override() {
  case "$(uname -m)" in
    aarch64|arm64) ;;
    *) return 0 ;;
  esac
  command -v aapt2 >/dev/null 2>&1 || fatal "ARM64 build requires a native aapt2 binary. Install the Termux aapt package before building."

  mkdir -p "$HOME/.gradle"
  local gp="$HOME/.gradle/gradle.properties"
  local desired="android.aapt2FromMavenOverride=$(command -v aapt2)"

  if [[ -f "$gp" ]] && grep -Fq "android.aapt2FromMavenOverride=" "$gp"; then
    python3 - "$gp" "$desired" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
desired = sys.argv[2]
lines = path.read_text(encoding='utf-8').splitlines()
updated = []
replaced = False
for line in lines:
    if line.startswith('android.aapt2FromMavenOverride='):
        if not replaced:
            updated.append(desired)
            replaced = True
        continue
    updated.append(line)
if not replaced:
    updated.append(desired)
path.write_text('\n'.join(updated) + '\n', encoding='utf-8')
PY
    log "Reconciled ARM64 aapt2 override in $gp"
  else
    printf '%s\n' "$desired" >> "$gp"
    log "Added native ARM64 aapt2 override to $gp"
  fi
}

main() {
  if is_termux; then
    exec bash "$ROOT/scripts/local-release.sh" --debug
  fi
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

  configure_aapt2_override

  "$ROOT/scripts/build.sh" debug
}

main "$@"
