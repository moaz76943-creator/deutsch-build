#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$ROOT/scripts/common.sh"
load_toolchain
cd "$ROOT"

log TEST "Deutsch بالعربي test gate"
"$ROOT/scripts/build_guard.sh"
snapshot_lockfile

log TEST "Flutter analyze"
flutter analyze

log TEST "Flutter tests"
flutter test

log TEST "Project regression tests"
python -m pytest -q tests

log TEST "Content quality audit"
python tool/quality_audit.py

log TEST "Security audit"
python tool/security_audit.py

assert_lockfile_unchanged
log OK "All test and audit gates passed"
