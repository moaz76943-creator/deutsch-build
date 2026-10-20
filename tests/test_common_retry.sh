#!/usr/bin/env bash
# Regression contract: dependency retries must not repeat non-transient errors
# or echo arbitrary command arguments / captured output containing secrets.
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT/scripts/common.sh"

tmp="$(mktemp -d)"
trap 'rm -rf -- "$tmp"' EXIT
sleep() { :; }

count="$tmp/calls"
: > "$count"
permanent_failure() {
  printf 'call\n' >> "$count"
  printf 'configuration failure password=PRIVATE_TEST_SENTINEL\n' >&2
  return 19
}
if with_retry permanent_failure "token=PRIVATE_TEST_SENTINEL" > "$tmp/permanent.log" 2>&1; then
  echo "non-transient failure unexpectedly passed" >&2
  exit 1
else
  status=$?
fi
[[ "$status" -eq 19 ]]
[[ "$(wc -l < "$count")" -eq 1 ]]
! grep -q 'PRIVATE_TEST_SENTINEL' "$tmp/permanent.log"

: > "$count"
transient_then_success() {
  printf 'call\n' >> "$count"
  if [[ "$(wc -l < "$count")" -lt 3 ]]; then
    printf 'SocketException: temporary connection refused\n' >&2
    return 75
  fi
}
with_retry transient_then_success > "$tmp/transient.log" 2>&1
[[ "$(wc -l < "$count")" -eq 3 ]]
echo "common_retry=PASS nontransient=1 transient=3 redaction=PASS"
