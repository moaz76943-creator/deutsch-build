#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# Keep the common toolchain boundary visible to callers of this compatibility entrypoint.
# shellcheck disable=SC1091
source "$ROOT/scripts/common.sh"

exec bash "$ROOT/scripts/local_quality_gate.sh"
