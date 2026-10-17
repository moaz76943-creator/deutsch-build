#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

ROOT="${ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
TOOLCHAIN_FILE="$ROOT/toolchain.lock"

<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
export ERR_ENV=10
export ERR_DEP=11
export ERR_COMP=12
export ERR_SIGN=13
export ERR_VERIFY=14

fatal() {
  local code=1
  if [[ "${1:-}" == "--code" ]]; then
    code="$2"
    shift 2
=======
# Standardized Exit Codes
=======
# Deterministic local build failure categories. Old callers retain exit code 1.
>>>>>>> pr-179
ERR_ENV=10
ERR_DEP=11
ERR_COMP=12
ERR_SIGN=15
ERR_ARTIFACT=16

fatal() {
  local code=1
<<<<<<< HEAD
  if [[ "${1:-}" =~ ^[0-9]+$ ]]; then
    code="$1"
    shift
>>>>>>> pr-61
=======
  if [[ $# -gt 1 && "${1:-}" =~ ^(10|11|12|15|16)$ ]]; then
    code="$1"
    shift
>>>>>>> pr-179
  fi
  printf '[ERROR] %s\n' "$*" >&2
  exit "$code"
}
<<<<<<< HEAD

log() { printf '[%s] %s\n' "$1" "$2"; }
=======
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
>>>>>>> pr-188

<<<<<<< HEAD
with_retry() {
  local max_attempts=3
  local attempt=1
  local delay=2
  while true; do
    if "$@"; then
      return 0
    else
      if (( attempt >= max_attempts )); then
        log ERR "Command failed after $max_attempts attempts: $*"
        return 1
      fi
      log WARN "Command failed (attempt $attempt/$max_attempts). Retrying in $delay seconds: $*"
      sleep "$delay"
      (( attempt++ ))
      (( delay *= 2 ))
    fi
  done
=======
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
>>>>>>> pr-61
}
=======
log() { printf '[%s] %s\n' "$1" "$2"; }

# Retry only lockfile-constrained dependency resolution and only for transient
# connectivity errors. Never echo captured tool output: it may contain secrets.
run_pub_get_with_retry() (
  local attempt=1 result=1 max_attempts=3 output_file
  output_file="$(mktemp)" || fatal "$ERR_ENV" 'Unable to create private dependency log'
  trap 'rm -f -- "$output_file"' EXIT
  trap 'exit 130' INT
  trap 'exit 143' TERM
  while (( attempt <= max_attempts )); do
    if flutter pub get --enforce-lockfile >"$output_file" 2>&1; then
      return 0
    else
      result=$?
    fi
    if (( attempt == max_attempts )) || ! grep -Eiq '(timed? out|timeout|connection reset|temporary failure|network error|connection refused|socketexception)' "$output_file"; then
      return "$result"
    fi
    log WARN "Transient dependency resolution failure (attempt $attempt/$max_attempts)"
    attempt=$((attempt + 1))
    sleep 1
  done
)

>>>>>>> pr-179

=======
fatal() { printf '[ERROR] %s\n' "$*" >&2; exit 1; }
log() { printf '[%s] %s\n' "$1" "$2"; }

>>>>>>> origin/staging/v2-full-platform-1792367411258400957
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
<<<<<<< HEAD
<<<<<<< HEAD
    fatal --code "$ERR_ENV" "Free space at $path: $available KiB; minimum $MIN_FREE_KB KiB (1 GiB). Free space manually before building."
=======
    fatal "$ERR_ENV" "Free space at $path: $available KiB; minimum $MIN_FREE_KB KiB (1 GiB). Free space manually before building."
>>>>>>> pr-61
=======
    fatal "Free space at $path: $available KiB; minimum $MIN_FREE_KB KiB (1 GiB). Free space manually before building." "$EXIT_ENV"
>>>>>>> pr-188
  elif (( available < RECOMMENDED_FREE_KB )); then
    log WARN "Free space at $path: $available KiB; recommended $RECOMMENDED_FREE_KB KiB (3 GiB). Continuing with preserved caches."
  else
    log OK "Free space at $path: $available KiB"
  fi
}

snapshot_lockfile() {
<<<<<<< HEAD
<<<<<<< HEAD
  [[ -f "$ROOT/pubspec.lock" ]] || fatal --code "$ERR_ENV" "pubspec.lock is missing; reproducible dependency resolution cannot start."
=======
  [[ -f "$ROOT/pubspec.lock" ]] || fatal "$ERR_DEP" "pubspec.lock is missing; reproducible dependency resolution cannot start."
>>>>>>> pr-61
=======
  [[ -f "$ROOT/pubspec.lock" ]] || fatal "pubspec.lock is missing; reproducible dependency resolution cannot start." "$EXIT_DEP"
>>>>>>> pr-188
  LOCK_BEFORE="$(sha256sum "$ROOT/pubspec.lock" | awk '{print $1}')"
  export LOCK_BEFORE
}

assert_lockfile_unchanged() {
<<<<<<< HEAD
  [[ -f "$ROOT/pubspec.lock" ]] || fatal "$ERR_DEP" "pubspec.lock disappeared during dependency resolution."
  LOCK_AFTER="$(sha256sum "$ROOT/pubspec.lock" | awk '{print $1}')"
  export LOCK_AFTER
  if [[ "$LOCK_BEFORE" != "$LOCK_AFTER" ]]; then
<<<<<<< HEAD
    fatal --code "$ERR_DEP" "pubspec.lock changed during this build. Dependency updates must be deliberate and committed before building. Before=$LOCK_BEFORE After=$LOCK_AFTER"
=======
    fatal "$ERR_DEP" "pubspec.lock changed during this build. Dependency updates must be deliberate and committed before building. Before=$LOCK_BEFORE After=$LOCK_AFTER"
>>>>>>> pr-61
=======
  [[ -f "$ROOT/pubspec.lock" ]] || fatal "pubspec.lock disappeared during dependency resolution." "$EXIT_DEP"
  LOCK_AFTER="$(sha256sum "$ROOT/pubspec.lock" | awk '{print $1}')"
  export LOCK_AFTER
  if [[ "$LOCK_BEFORE" != "$LOCK_AFTER" ]]; then
    fatal "pubspec.lock changed during this build. Dependency updates must be deliberate and committed before building. Before=$LOCK_BEFORE After=$LOCK_AFTER" "$EXIT_DEP"
>>>>>>> pr-188
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
