#!/usr/bin/env bash
# Shared local/runner signing contract. Never trace credentials.
set +x

prepare_release_signing() {
  # Local setup persists only private user properties; ephemeral runner setup
  # consumes canonical step environment values and never emits credentials.
  python3 "$ROOT/tool/release_signing.py" --prepare "$@"
}

check_release_signing() {
  python3 "$ROOT/tool/release_signing.py" "$@"
}
