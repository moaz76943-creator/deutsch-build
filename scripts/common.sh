#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

ROOT="${ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
TOOLCHAIN_FILE="$ROOT/toolchain.lock"

EXIT_ENV=10
EXIT_DEP=11
EXIT_COMP=12
EXIT_SIGN=13
EXIT_ART=14

fatal() {
  local msg="$1"
  local code="${2:-1}"
  printf '[ERROR] %s\n' "$msg" | redact_secrets >&2
  exit "$code"
}

log() {
  local level="$1"
  local msg="$2"
  printf '[%s] %s\n' "$level" "$msg" | redact_secrets
}

redact_secrets() {
  sed -E -e 's/(RELEASE_KEYSTORE_BASE64=)[^ ]*/\1[REDACTED]/g' \
         -e 's/(-----BEGIN (PRIVATE KEY|CERTIFICATE)-----).*(-----END \2-----)/[REDACTED_PEM]/g'
}

with_retry() {
  local retries=3
  local count=0
  local delay=2
  while true; do
    if "$@"; then
      return 0
    else
      count=$((count + 1))
      if (( count >= retries )); then
        log ERROR "Command failed after $retries attempts: $*"
        return 1
      fi
      log WARN "Transient failure; retrying ($count/$retries) in $delay seconds: $*"
      sleep "$delay"
    fi
  done
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
  available="$(df -Pk "$path" | awk 'NR==2 {print $4}')" || fatal "Cannot inspect disk space at $path"
  [[ "$available" =~ ^[0-9]+$ ]] || fatal "Cannot determine available disk space at $path"
  if (( available < MIN_FREE_KB )); then
    fatal "Free space at $path: $available KiB; minimum $MIN_FREE_KB KiB (1 GiB). Free space manually before building." "$EXIT_ENV"
  elif (( available < RECOMMENDED_FREE_KB )); then
    log WARN "Free space at $path: $available KiB; recommended $RECOMMENDED_FREE_KB KiB (3 GiB). Continuing with preserved caches."
  else
    log OK "Free space at $path: $available KiB"
  fi
}

snapshot_lockfile() {
  [[ -f "$ROOT/pubspec.lock" ]] || fatal "pubspec.lock is missing; reproducible dependency resolution cannot start." "$EXIT_DEP"
  LOCK_BEFORE="$(sha256sum "$ROOT/pubspec.lock" | awk '{print $1}')"
  export LOCK_BEFORE
}

assert_lockfile_unchanged() {
  [[ -f "$ROOT/pubspec.lock" ]] || fatal "pubspec.lock disappeared during dependency resolution." "$EXIT_DEP"
  LOCK_AFTER="$(sha256sum "$ROOT/pubspec.lock" | awk '{print $1}')"
  export LOCK_AFTER
  if [[ "$LOCK_BEFORE" != "$LOCK_AFTER" ]]; then
    fatal "pubspec.lock changed during this build. Dependency updates must be deliberate and committed before building. Before=$LOCK_BEFORE After=$LOCK_AFTER" "$EXIT_DEP"
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
