#!/usr/bin/env bash
# Shared local/runner signing contract. Never trace credentials.
set +x

prepare_release_signing() {
  # Local setup persists only private user properties; ephemeral runner setup
  # consumes canonical step environment values and never emits credentials.
  python3 "$ROOT/tool/release_signing.py" --prepare "$@" 2>&1 | redact_secrets
  return "${PIPESTATUS[0]}"
}

check_release_signing() {
  python3 "$ROOT/tool/release_signing.py" "$@" 2>&1 | redact_secrets
  return "${PIPESTATUS[0]}"
}
