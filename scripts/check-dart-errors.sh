#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT/scripts/common.sh"
cd "$ROOT"
command -v dart >/dev/null 2>&1 || fatal "Dart is not in PATH"
output="$(mktemp)"
trap 'python3 -c "import os,sys; os.unlink(sys.argv[1])" "$output"' EXIT
status=0
dart analyze --format=machine lib/ > "$output" 2>&1 || status=$?
cat "$output"
if grep -Eq '^ERROR\|' "$output"; then
  fatal "Dart analyzer found build-blocking errors in lib/"
fi
case "$status" in
  0|1|2)
    # A nonzero result must contain recognizable diagnostics, not an SDK crash.
    if [[ "$status" != 0 ]] && ! grep -Eq '^(WARNING|INFO)\|' "$output"; then
      fatal "Dart analyzer failed without recognized diagnostics (exit $status)"
    fi ;;
  *) fatal "Dart analyzer failed (exit $status)" ;;
esac
log OK "Dart analyzer: zero blocking errors in lib/"
