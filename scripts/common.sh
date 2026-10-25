#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

ROOT="${ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
TOOLCHAIN_FILE="$ROOT/toolchain.lock"

export ERR_ENV=10
export ERR_COMP=12
export ERR_SIGN=15
export ERR_DEP=11

export EXIT_ENV=10
export EXIT_DEP=11
export EXIT_COMP=12
export EXIT_SIGN=15
export EXIT_ART=16
export ERR_COMPILE=11
export ERR_SIGNING=12
export ERR_DEPENDENCY=13


redact_secrets() {
  sed -E -e 's/([pP]assword=)\S+/\1<REDACTED>/g' \
         -e 's/(--pass[A-Za-z0-9-]*[\ =])\S+/\1<REDACTED>/g' \
         -e 's/(RELEASE_KEYSTORE_BASE64=)[^ ]*/\1[REDACTED]/g' \
         -e 's/(-----BEGIN (PRIVATE KEY|CERTIFICATE)-----).*(-----END \2-----)/[REDACTED_PEM]/g'
}

fatal() {
  local code=1
  local msg=""
  if [[ $# -gt 1 && "${1:-}" =~ ^(10|11|12|13|14|15|16)$ ]]; then
    code="$1"
    shift
    msg="$*"
  elif [[ $# -gt 1 && "${!#}" =~ ^(10|11|12|13|14|15|16)$ ]]; then
    code="${!#}"
    msg="${*:1:$(($#-1))}"
  elif [[ "${1:-}" == "--code" && $# -gt 2 && "${2:-}" =~ ^(10|11|12|13|14|15|16)$ ]]; then
    code="$2"
    shift 2
    msg="$*"
  else
    msg="$*"
  fi
  printf '[ERROR] %s\n' "$msg" | redact_secrets >&2
  builtin exit "$code"
}

log() {
  local level="$1"
  shift
  printf '[%s] %s\n' "$level" "$*" | redact_secrets
}

run_pub_get_with_retry() (
  local attempt=1 result=1 max_attempts=3 output_file
  output_file="$(mktemp)" || fatal "$ERR_ENV" 'Unable to create private dependency log'
  trap 'rm -f -- "$output_file"' EXIT
  trap 'builtin exit 130' INT
  trap 'builtin exit 143' TERM
  while (( attempt <= max_attempts )); do
    if flutter pub get --enforce-lockfile >"$output_file" 2>&1; then
      return 0
    else
      result=$?
    fi
    if (( attempt == max_attempts )) || ! grep -Eiq '(timed? out|timeout|connection reset|temporary failure|network error|connection refused|socketexception)' "$output_file"; then
      cat "$output_file" | redact_secrets >&2
      return "$result"
    fi
    log WARN "Transient dependency resolution failure (attempt $attempt/$max_attempts)"
    attempt=$((attempt + 1))
    sleep 1
  done
)

with_retry() {
  local max_attempts=3
  local attempt=1
  local interval=2
  while (( attempt <= max_attempts )); do
    local status=0
    local tmp_out
    tmp_out="$(mktemp)"
    if "$@" > "$tmp_out" 2>&1; then
      cat "$tmp_out" | redact_secrets
      rm -f "$tmp_out"
      return 0
    else
      status=$?
    fi

    if grep -q -iE "(SocketException|timeout|connection reset|network is unreachable|Connection refused)" "$tmp_out"; then
      if (( attempt == max_attempts )); then
        cat "$tmp_out" | redact_secrets >&2
        rm -f "$tmp_out"
        return "$status"
      fi
      log WARN "Transient failure detected. retrying ($attempt/$max_attempts) in $interval seconds..."
      rm -f "$tmp_out"
      sleep "$interval"
      attempt=$((attempt + 1))
      interval=$((interval * 2))
    else
      cat "$tmp_out" | redact_secrets >&2
      rm -f "$tmp_out"
      return "$status"
    fi
  done
}

run_with_retry() {
  with_retry "$@"
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
