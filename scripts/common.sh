#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

ROOT="${ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
TOOLCHAIN_FILE="$ROOT/toolchain.lock"

ERR_ENV=10
ERR_COMPILE=11
ERR_SIGNING=12
ERR_DEPENDENCY=13
ERR_ARTIFACT=14

fatal() {
  local exit_code=1
  if [[ "${1:-}" =~ ^[0-9]+$ ]]; then
    exit_code="$1"
    shift
  fi
  printf '[ERROR] %s\n' "$*" >&2
  exit "$exit_code"
}
log() { printf '[%s] %s\n' "$1" "$2"; }

with_retry() {
  local max_attempts=3
  local attempt=1
  local delay=2
  while true; do
    if "$@"; then
      return 0
    elif (( attempt >= max_attempts )); then
      fatal $ERR_DEPENDENCY "Command failed after $max_attempts attempts: $*"
    fi
    log WARN "Command failed: $* (attempt $attempt/$max_attempts). Retrying in ${delay}s..."
    sleep "$delay"
    ((attempt++))
    ((delay *= 2))
  done
}

load_toolchain() {
  [[ -f "$TOOLCHAIN_FILE" ]] || fatal $ERR_ENV "toolchain.lock is missing: $TOOLCHAIN_FILE"
  # shellcheck disable=SC1090
  source "$TOOLCHAIN_FILE"
}

is_termux() {
  [[ "${PREFIX:-}" == /data/data/*/files/usr ]]
}

configure_android_build_path() {
  local sdk_tools="$ANDROID_SDK_ROOT/build-tools/$ANDROID_BUILD_TOOLS_VERSION:$ANDROID_SDK_ROOT/platform-tools"
  if is_termux; then
    # SDK packaging executables target Linux/glibc; prefer native Android tools.
    export PATH="$JAVA_HOME/bin:$FLUTTER_ROOT/bin:$FLUTTER_ROOT/bin/cache/dart-sdk/bin:$PREFIX/bin:$sdk_tools:$PATH"
  else
    export PATH="$sdk_tools:$PATH"
  fi
}

check_disk_space() {
  local path="${1:-$ROOT}" available
  available="$(df -Pk "$path" | awk 'NR==2 {print $4}')" || fatal $ERR_ENV "Cannot inspect disk space at $path"
  [[ "$available" =~ ^[0-9]+$ ]] || fatal $ERR_ENV "Cannot determine available disk space at $path"
  if (( available < MIN_FREE_KB )); then
    fatal $ERR_ENV "Free space at $path: $available KiB; minimum $MIN_FREE_KB KiB (1 GiB). Free space manually before building."
  elif (( available < RECOMMENDED_FREE_KB )); then
    log WARN "Free space at $path: $available KiB; recommended $RECOMMENDED_FREE_KB KiB (3 GiB). Continuing with preserved caches."
  else
    log OK "Free space at $path: $available KiB"
  fi
}

snapshot_lockfile() {
  [[ -f "$ROOT/pubspec.lock" ]] || fatal $ERR_DEPENDENCY "pubspec.lock is missing; reproducible dependency resolution cannot start."
  LOCK_BEFORE="$(sha256sum "$ROOT/pubspec.lock" | awk '{print $1}')"
  export LOCK_BEFORE
}

assert_lockfile_unchanged() {
  [[ -f "$ROOT/pubspec.lock" ]] || fatal $ERR_DEPENDENCY "pubspec.lock disappeared during dependency resolution."
  LOCK_AFTER="$(sha256sum "$ROOT/pubspec.lock" | awk '{print $1}')"
  export LOCK_AFTER
  if [[ "$LOCK_BEFORE" != "$LOCK_AFTER" ]]; then
    fatal $ERR_DEPENDENCY "pubspec.lock changed during this build. Dependency updates must be deliberate and committed before building. Before=$LOCK_BEFORE After=$LOCK_AFTER"
  fi
}

app_version() {
  sed -nE 's/^version:[[:space:]]*([^+]+)\+([0-9]+).*$/\1/p' "$ROOT/pubspec.yaml" | head -1
}

app_build_number() {
  sed -nE 's/^version:[[:space:]]*[^+]+\+([0-9]+).*$/\1/p' "$ROOT/pubspec.yaml" | head -1
}

git_commit() {
  if command -v git >/dev/null 2>&1 && git -C "$ROOT" rev-parse HEAD >/dev/null 2>&1; then
    git -C "$ROOT" rev-parse HEAD
  else
    printf 'unknown\n'
  fi
}
