#!/usr/bin/env bash
set +x
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT/scripts/common.sh"
is_termux || fatal "Run this entrypoint inside Termux"
[[ "$(uname -m)" =~ ^(aarch64|arm64)$ ]] || fatal "Termux APK builds require ARM64"
exec bash "$ROOT/scripts/local-release.sh" "$@"
