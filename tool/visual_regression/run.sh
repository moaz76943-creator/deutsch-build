#!/usr/bin/env bash
# DEUTSCH-IMPROVE-08. No repository or user-data mutation.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

ACTION="--run"
if (( $# > 0 )); then
  ACTION="$1"
fi

case "$ACTION" in
  --dry-run)
    printf '%s\n' 'STATUS=NOT_RUN' \
      'REASON=DRY_RUN: execution intentionally disabled' \
      'COMMAND=flutter test --no-pub --reporter expanded test/visual_regression/'
    exit 0
    ;;
  --run) ;;
  *)
    printf '%s\n' 'Usage: bash tool/visual_regression/run.sh [--run|--dry-run]' >&2
    exit 64
    ;;
esac

if ! command -v flutter >/dev/null 2>&1; then
  printf '%s\n' 'STATUS=NOT_RUN' \
    'REASON=Flutter SDK not found in PATH; tests were not executed.'
  exit 2
fi

if [[ ! -f .dart_tool/package_config.json ]]; then
  printf '%s\n' 'STATUS=NOT_RUN' \
    'REASON=Local Flutter packages are unresolved.' \
    'ACTION=Run flutter pub get --offline from a permitted local SDK cache.'
  exit 2
fi

printf '%s\n' 'STATUS=RUNNING' \
  'SUITE=test/visual_regression/' \
  'NOTE=No golden baseline updates, no network commands, no lib/ modifications.'

if command -v timeout >/dev/null 2>&1; then
  timeout --signal=TERM --kill-after=10s 300s \
    flutter test --no-pub --reporter expanded test/visual_regression/
else
  flutter test --no-pub --reporter expanded test/visual_regression/
fi

printf '%s\n' 'STATUS=PASS' \
  'NOTE=PASS applies only to this local suite on the executing SDK.'
