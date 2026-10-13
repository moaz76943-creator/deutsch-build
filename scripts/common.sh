#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

ROOT="${ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
TOOLCHAIN_FILE="$ROOT/toolchain.lock"

# Standardized Exit Codes
ERR_ENV=10
ERR_DEP=11
ERR_COMP=12
ERR_SIGN=15
ERR_ARTIFACT=16

fatal() {
  local code=1
  if [[ "${1:-}" =~ ^[0-9]+$ ]]; then
    code="$1"
    shift
  fi
  printf '[ERROR] %s\n' "$*" >&2
  exit "$code"
}

log() { printf '[%s] %s\n' "$1" "$2"; }

redact_secrets() {
  sed -E -e 's/([pP]assword=)\S+/\1<REDACTED>/g' \
         -e 's/(--pass[A-Za-z0-9-]*[\ =])\S+/\1<REDACTED>/g'
}

run_with_retry() {
  local max_attempts=3
  local attempt=1
  local output_file
  output_file="$(mktemp)"

  while (( attempt <= max_attempts )); do
    if "$@" > "$output_file" 2>&1; then
      cat "$output_file" | redact_secrets
      rm -f "$output_file"
      return 0
    else
      local exit_code=$?
      if grep -Ei '(timeout|connection reset|network error|temporary failure)' "$output_file" >/dev/null; then
        log WARN "Transient error detected in '$1' (attempt $attempt/$max_attempts). Retrying..."
        ((attempt++))
        sleep 2
      else
        cat "$output_file" | redact_secrets
        rm -f "$output_file"
        return "$exit_code"
      fi
    fi
  done

  cat "$output_file" | redact_secrets
  rm -f "$output_file"
  log ERROR "Command '$1' failed after $max_attempts attempts."
  return 1
}

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
  available="$(df -Pk "$path" | awk 'NR==2 {print $4}')" || fatal "$ERR_ENV" "Cannot inspect disk space at $path"
  [[ "$available" =~ ^[0-9]+$ ]] || fatal "$ERR_ENV" "Cannot determine available disk space at $path"
  if (( available < MIN_FREE_KB )); then
    fatal "$ERR_ENV" "Free space at $path: $available KiB; minimum $MIN_FREE_KB KiB (1 GiB). Free space manually before building."
  elif (( available < RECOMMENDED_FREE_KB )); then
    log WARN "Free space at $path: $available KiB; recommended $RECOMMENDED_FREE_KB KiB (3 GiB). Continuing with preserved caches."
  else
    log OK "Free space at $path: $available KiB"
  fi
}

snapshot_lockfile() {
  [[ -f "$ROOT/pubspec.lock" ]] || fatal "$ERR_DEP" "pubspec.lock is missing; reproducible dependency resolution cannot start."
  LOCK_BEFORE="$(sha256sum "$ROOT/pubspec.lock" | awk '{print $1}')"
  export LOCK_BEFORE
}

assert_lockfile_unchanged() {
  [[ -f "$ROOT/pubspec.lock" ]] || fatal "$ERR_DEP" "pubspec.lock disappeared during dependency resolution."
  LOCK_AFTER="$(sha256sum "$ROOT/pubspec.lock" | awk '{print $1}')"
  export LOCK_AFTER
  if [[ "$LOCK_BEFORE" != "$LOCK_AFTER" ]]; then
    fatal "$ERR_DEP" "pubspec.lock changed during this build. Dependency updates must be deliberate and committed before building. Before=$LOCK_BEFORE After=$LOCK_AFTER"
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
