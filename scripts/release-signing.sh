#!/usr/bin/env bash
# Shared local/runner signing contract. Never trace credentials.
set +x
ROOT="${ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
# shellcheck disable=SC1091
source "$ROOT/scripts/common.sh"

prepare_release_signing() {
  # Local setup persists only private user properties; ephemeral runner setup
  # consumes canonical step environment values and never emits credentials.
  python3 "$ROOT/tool/release_signing.py" --prepare "$@"
}

check_release_signing() {
  python3 "$ROOT/tool/release_signing.py" "$@" 2>&1 | redact_secrets >&2
  return "${PIPESTATUS[0]}"
}
