#!/usr/bin/env bash
set +x
set -Eeuo pipefail
umask 077
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT/scripts/common.sh"
source "$ROOT/scripts/release-signing.sh"
case "${1:-}" in
  '') prepare_release_signing --interactive ;;
  --non-interactive) prepare_release_signing ;;
  *) fatal --code "$ERR_SIGN" "Usage: scripts/setup_local_signing.sh [--non-interactive]" ;;
esac
log OK "Existing production signing identity verified; private local Gradle properties ready"
