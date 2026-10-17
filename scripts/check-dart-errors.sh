#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT/scripts/common.sh"
cd "$ROOT"
<<<<<<< HEAD
command -v dart >/dev/null 2>&1 || fatal --code "$ERR_ENV" "Dart is not in PATH"
=======
command -v dart >/dev/null 2>&1 || fatal $ERR_COMPILE "Dart is not in PATH"
>>>>>>> origin/main
output="$(mktemp)"
trap 'python3 -c "import os,sys; os.unlink(sys.argv[1])" "$output"' EXIT
status=0
dart analyze --format=machine lib/ > "$output" 2>&1 || status=$?
cat "$output"
if grep -Eq '^ERROR\|' "$output"; then
<<<<<<< HEAD
  fatal --code "$ERR_COMP" "Dart analyzer found build-blocking errors in lib/"
=======
  fatal $ERR_COMPILE "Dart analyzer found build-blocking errors in lib/"
>>>>>>> origin/main
fi
case "$status" in
  0|1|2)
    # A nonzero result must contain recognizable diagnostics, not an SDK crash.
    if [[ "$status" != 0 ]] && ! grep -Eq '^(WARNING|INFO)\|' "$output"; then
<<<<<<< HEAD
      fatal --code "$ERR_COMP" "Dart analyzer failed without recognized diagnostics (exit $status)"
    fi ;;
  *) fatal --code "$ERR_COMP" "Dart analyzer failed (exit $status)" ;;
=======
      fatal $ERR_COMPILE "Dart analyzer failed without recognized diagnostics (exit $status)"
    fi ;;
  *) fatal $ERR_COMPILE "Dart analyzer failed (exit $status)" ;;
>>>>>>> origin/main
esac
log OK "Dart analyzer: zero blocking errors in lib/"
