#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

ROOT="${ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
TOOLCHAIN_FILE="$ROOT/toolchain.lock"

fatal() { printf '[ERROR] %s\n' "$*" >&2; exit 1; }
log() { printf '[%s] %s\n' "$1" "$2"; }

load_toolchain() {
  [[ -f "$TOOLCHAIN_FILE" ]] || fatal "toolchain.lock is missing: $TOOLCHAIN_FILE"
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
  available="$(df -Pk "$path" | awk 'NR==2 {print $4}')" || fatal "Cannot inspect disk space at $path"
  [[ "$available" =~ ^[0-9]+$ ]] || fatal "Cannot determine available disk space at $path"
  if (( available < MIN_FREE_KB )); then
    fatal "Free space at $path: $available KiB; minimum $MIN_FREE_KB KiB (1 GiB). Free space manually before building."
  elif (( available < RECOMMENDED_FREE_KB )); then
    log WARN "Free space at $path: $available KiB; recommended $RECOMMENDED_FREE_KB KiB (3 GiB). Continuing with preserved caches."
  else
    log OK "Free space at $path: $available KiB"
  fi
}

snapshot_lockfile() {
  [[ -f "$ROOT/pubspec.lock" ]] || fatal "pubspec.lock is missing; reproducible dependency resolution cannot start."
  LOCK_BEFORE="$(sha256sum "$ROOT/pubspec.lock" | awk '{print $1}')"
  export LOCK_BEFORE
}

assert_lockfile_unchanged() {
  [[ -f "$ROOT/pubspec.lock" ]] || fatal "pubspec.lock disappeared during dependency resolution."
  LOCK_AFTER="$(sha256sum "$ROOT/pubspec.lock" | awk '{print $1}')"
  export LOCK_AFTER
  if [[ "$LOCK_BEFORE" != "$LOCK_AFTER" ]]; then
    fatal "pubspec.lock changed during this build. Dependency updates must be deliberate and committed before building. Before=$LOCK_BEFORE After=$LOCK_AFTER"
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

# Bounded retry only for transient failures (e.g. network/socket timeouts)
with_retry() {
  local max_attempts=3
  local attempt=1
  local interval=2
  while (( attempt <= max_attempts )); do
    # Run the command and capture output to check for transient errors
    local output
    local status=0
    # Store stderr and stdout in a temporary file to parse
    local tmp_out
    tmp_out="$(mktemp)"
    if "$@" > "$tmp_out" 2>&1; then
      cat "$tmp_out"
      rm -f "$tmp_out"
      return 0
    else
      status=$?
      cat "$tmp_out"
    fi

    # Check if the failure is transient (e.g., SocketException, Timeout)
    if grep -q -iE "(SocketException|timeout|connection reset|network is unreachable|Connection refused)" "$tmp_out"; then
      rm -f "$tmp_out"
      if (( attempt == max_attempts )); then
        return "$status"
      fi
      log WARN "Transient failure detected. retrying ($attempt/$max_attempts) in $interval seconds..."
      sleep "$interval"
      attempt=$((attempt + 1))
      interval=$((interval * 2))
    else
      # Not a transient error, fail immediately
      rm -f "$tmp_out"
      return "$status"
    fi
  done
}
