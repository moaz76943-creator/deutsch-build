#!/usr/bin/env bash
# Create a unique, private local build log without following a directory symlink.
set -Eeuo pipefail
umask 077
mode="${1:-}"
if [[ $# -ne 1 || ( "$mode" != debug && "$mode" != release ) ]]; then
  printf '[ERROR] Invalid build-log mode\n' >&2
  exit 10
fi
log_dir="${HOME:?HOME must be configured}/.deutsch_bilarabi_logs"
if [[ -L "$log_dir" || ( -e "$log_dir" && ! -d "$log_dir" ) ]]; then
  printf '[ERROR] Unsafe build-log directory\n' >&2
  exit 10
fi
mkdir -p -m 700 -- "$log_dir" || exit 10
chmod 700 -- "$log_dir" || exit 10
mktemp "$log_dir/build_${mode}_$(date +%Y%m%d_%H%M%S)_XXXXXXXX.log" || exit 10
