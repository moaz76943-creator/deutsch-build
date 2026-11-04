#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

ROOT="${ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
TOOLCHAIN_FILE="$ROOT/toolchain.lock"

export ERR_ENV=10
export ERR_DEP=11
export ERR_COMP=12
export ERR_SIGN=13
export ERR_VERIFY=14

# Filters credential-shaped text. Callers pipe command output through this
# before it reaches a terminal or log. The function itself never prints secrets.
redact_secrets() {
  local keystore_name="RELEASE_KEYSTORE_BASE64"
  sed -E \
    -e "s/(${keystore_name}=)[^[:space:]]*/\\1[REDACTED]/g" \
    -e 's/(-----BEGIN (PRIVATE KEY|CERTIFICATE)-----).*(-----END \2-----)/[REDACTED_PEM]/g' \
    -e 's/([pP]assword=)[^[:space:]]+/\1[REDACTED]/g' \
    -e 's/(--pass[A-Za-z0-9-]*)(=|[[:space:]]+)[^[:space:]]+/\1\2[REDACTED]/g'
}

fatal() {
  local code=1
  if [[ "${1:-}" == "--code" ]]; then
    code="$2"
    shift 2
  elif [[ "${1:-}" =~ ^[0-9]+$ ]]; then
    code="$1"
    shift
  fi
  printf '[ERROR] %s\n' "$*" | redact_secrets >&2
  exit "$code"
}

log() { printf '[%s] %s\n' "$1" "$2" | redact_secrets; }

# Only retry proven transient transport faults. Capture output privately:
# command arguments and tool output can contain credentials or tokens.
with_retry() (
  umask 077
  local max_attempts=3 attempt=1 delay=1 status=1 output_file
  output_file="$(mktemp)" || return 1
  trap 'rm -f -- "$output_file"' EXIT
  while (( attempt <= max_attempts )); do
    if "$@" > "$output_file" 2>&1; then
      redact_secrets < "$output_file"
      return 0
    else
      status=$?
    fi
    if ! grep -Eiq '(timed? out|timeout|connection reset|connection refused|temporar(y|ily)|network error|socketexception|network is unreachable)' "$output_file"; then
      redact_secrets < "$output_file" >&2
      log ERR "Non-transient operation failure; no retry (exit $status)"
      return "$status"
    fi
    if (( attempt >= max_attempts )); then
      redact_secrets < "$output_file" >&2
      log ERR "Transient operation failed after $max_attempts attempts (exit $status)"
      return "$status"
    fi
    log WARN "Transient operation failure; retry $attempt/$max_attempts"
    sleep "$delay"
    attempt=$((attempt + 1))
    delay=$((delay * 2))
  done
  return "$status"
)

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
    fatal --code "$ERR_ENV" "Free space at $path: $available KiB; minimum $MIN_FREE_KB KiB (1 GiB). Free space manually before building."
  elif (( available < RECOMMENDED_FREE_KB )); then
    log WARN "Free space at $path: $available KiB; recommended $RECOMMENDED_FREE_KB KiB (3 GiB). Continuing with preserved caches."
  else
    log OK "Free space at $path: $available KiB"
  fi
}

snapshot_lockfile() {
  [[ -f "$ROOT/pubspec.lock" ]] || fatal --code "$ERR_ENV" "pubspec.lock is missing; reproducible dependency resolution cannot start."
  LOCK_BEFORE="$(sha256sum "$ROOT/pubspec.lock" | awk '{print $1}')"
  export LOCK_BEFORE
}

assert_lockfile_unchanged() {
  [[ -f "$ROOT/pubspec.lock" ]] || fatal "pubspec.lock disappeared during dependency resolution."
  LOCK_AFTER="$(sha256sum "$ROOT/pubspec.lock" | awk '{print $1}')"
  export LOCK_AFTER
  if [[ "$LOCK_BEFORE" != "$LOCK_AFTER" ]]; then
    fatal --code "$ERR_DEP" "pubspec.lock changed during this build. Dependency updates must be deliberate and committed before building. Before=$LOCK_BEFORE After=$LOCK_AFTER"
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
