#!/usr/bin/env bash
# Source this file; never trace signing credentials, even with bash -x.
set +x

prepare_release_signing() {
  local signing_exports
  signing_exports="$(python3 "$ROOT/tool/release_signing.py" --prepare)" || return 1
  # The helper emits only shell-quoted assignments with fixed variable names.
  eval "$signing_exports"
}

check_release_signing() {
  local signing_exports
  signing_exports="$(python3 "$ROOT/tool/release_signing.py")" || return 1
  eval "$signing_exports"
}
